# SPDX-License-Identifier: MIT
"""Offline contract and publication tests; no GitHub credentials or network."""
import base64
import csv
import importlib.util
import io
import json
import tempfile
import shlex
import re
from pathlib import Path
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location(
    "traffic_history", Path(__file__).resolve().parents[2] / "tools/traffic_history.py")
traffic = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(traffic)


def fixture():
    return {"views": {"count": 5, "uniques": 3, "views": [
        {"timestamp": "2026-10-17T00:00:00Z", "count": 5, "uniques": 3}]},
        "clones": {"count": 2, "uniques": 1, "clones": [
        {"timestamp": "2026-10-17T00:00:00Z", "count": 2, "uniques": 1}]},
        "referrers": [], "paths": []}


class Writer:
    def __init__(self, previous=None, race=False):
        self.previous, self.race, self.calls = previous, race, []

    def request(self, method, path, data=None, missing=False):
        self.calls.append((method, path, data))
        if method == "GET" and "/git/ref/" in path:
            return {"object": {"sha": "a" * 40}}
        if method == "GET" and "/git/commits/" in path:
            return {"tree": {"sha": "b" * 40}}
        if method == "GET" and "/contents/" in path:
            if self.previous is None:
                return None
            return {"content": base64.b64encode(self.previous.encode()).decode()}
        if method == "POST":
            return {"sha": "c" * 40}
        if method == "PATCH":
            if self.race:
                raise RuntimeError("non-fast-forward")
            return {}
        raise AssertionError((method, path))


class TrafficTests(unittest.TestCase):
    def test_app_credentials_stay_in_their_steps(self):
        workflow = (Path(__file__).resolve().parents[2] /
            ".github/workflows/traffic-export.yml").read_text()
        blocks = re.split(r"^      - name: ", workflow, flags=re.MULTILINE)
        self.assertNotIn("TRAFFIC_APP_PRIVATE_KEY", blocks[0])
        self.assertNotIn("steps.app-token.outputs.token", blocks[0])
        key_blocks = [b for b in blocks[1:] if "secrets.TRAFFIC_APP_PRIVATE_KEY" in b]
        self.assertEqual(len(key_blocks), 2)
        check = next(b for b in key_blocks if b.startswith("Check the traffic App configuration"))
        self.assertEqual(check.count("secrets.TRAFFIC_APP_PRIVATE_KEY"), 1)
        self.assertIn("${{ secrets.TRAFFIC_APP_PRIVATE_KEY != '' }}", check)
        token = next(b for b in key_blocks if b.startswith("Create the traffic App token"))
        self.assertIn("private-key: ${{ secrets.TRAFFIC_APP_PRIVATE_KEY }}", token)
        self.assertIn("permission-administration: read", token)
        self.assertIn("actions/create-github-app-token@64ab729a6294000f5aa4a4bc0b73d1f32bc45510", token)
        fetches = [b for b in blocks[1:] if "steps.app-token.outputs.token" in b]
        self.assertEqual(len(fetches), 1)
        fetch = fetches[0]
        self.assertTrue(fetch.startswith("Fetch traffic from the GitHub API"))
        run = fetch.split("        run: |\n", 1)[1]
        run = "\n".join(line for line in run.splitlines() if not line.lstrip().startswith("#"))
        commands = run.replace("\\\n", " ").strip().splitlines()
        self.assertEqual(len(commands), 4)
        for command in commands:
            words = shlex.split(command)
            self.assertEqual(words[0], "curl")
            self.assertFalse(set(words) & {";", "&&", "||", "--location", "-L"})
            self.assertNotIn("$(", command)
            self.assertNotIn("`", command)
        self.assertNotIn("secrets.TRAFFIC_TOKEN", workflow)

    def test_response_files_validate_before_api_access(self):
        with tempfile.TemporaryDirectory() as directory:
            for name, value in fixture().items():
                (Path(directory) / (name + ".json")).write_text(json.dumps(value))
            self.assertEqual(traffic.load_responses(directory), fixture())
            (Path(directory) / "paths.json").write_text("invalid")
            with self.assertRaises(ValueError):
                traffic.load_responses(directory)
            (Path(directory) / "paths.json").unlink()
            with self.assertRaises(FileNotFoundError):
                traffic.load_responses(directory)

    def test_overlap_replaces_counts_and_preserves_older_days(self):
        old = "date,views,views_uniques,clones,clones_uniques\n2026-10-01,7,4,0,0\n2026-10-17,3,2,1,1\n"
        rows = list(csv.DictReader(io.StringIO(traffic.merge_daily(old, fixture()))))
        self.assertEqual([r["date"] for r in rows], ["2026-10-01", "2026-10-17"])
        self.assertEqual(rows[1]["views"], "5")
        self.assertEqual(rows[0]["views"], "7")

    def test_empty_window_is_valid_but_not_missing_historical_days(self):
        data = fixture()
        data["views"] = {"count": 0, "uniques": 0, "views": []}
        old = "date,views,views_uniques,clones,clones_uniques\n2026-10-17,9,4,1,1\n"
        row = list(csv.DictReader(io.StringIO(traffic.merge_daily(old, data))))[0]
        self.assertEqual((row["views"], row["clones"]), ("9", "2"))

    def test_bad_counts_timestamps_and_duplicate_samples_fail(self):
        for value in (-1, True, 1.5, "5"):
            data = fixture()
            data["views"]["views"][0]["count"] = value
            with self.subTest(value=value), self.assertRaises(ValueError):
                traffic.validate_traffic(data)
        for timestamp in ("2026-02-30T00:00:00Z", "2026-10-17T12:00:00Z", "bad"):
            data = fixture()
            data["views"]["views"][0]["timestamp"] = timestamp
            with self.subTest(timestamp=timestamp), self.assertRaises(ValueError):
                traffic.validate_traffic(data)
        data = fixture()
        data["views"]["views"] *= 2
        with self.assertRaises(ValueError):
            traffic.validate_traffic(data)

    def test_unique_counts_and_corrupt_history_fail_before_mutation(self):
        data = fixture()
        data["clones"]["clones"][0]["uniques"] = 3
        writer = Writer()
        with self.assertRaises(ValueError):
            traffic.publish(writer, "owner/repo", data)
        self.assertEqual(writer.calls, [])
        writer = Writer("date,unexpected\n2026-10-17,1\n")
        data = {**fixture(), "collected_at_utc": "2026-10-18T00:00:00+00:00"}
        with self.assertRaises(ValueError):
            traffic.publish(writer, "owner/repo", data)
        self.assertTrue(all(method == "GET" for method, _, _ in writer.calls))

    def test_extra_or_missing_history_columns_fail_before_writes(self):
        header = "date,views,views_uniques,clones,clones_uniques\n"
        for row in ("2026-10-17,5,3,2,1,unexpected\n", "2026-10-17,5,3,2\n"):
            writer = Writer(header + row)
            snapshot = {**fixture(), "collected_at_utc": "2026-10-18T00:00:00+00:00"}
            with self.subTest(row=row), self.assertRaisesRegex(ValueError, "row width"):
                traffic.publish(writer, "owner/repo", snapshot)
            self.assertTrue(all(method == "GET" for method, _, _ in writer.calls))

    def test_empty_existing_history_is_not_treated_as_missing(self):
        writer = Writer("")
        snapshot = {**fixture(), "collected_at_utc": "2026-10-18T00:00:00+00:00"}
        with self.assertRaisesRegex(ValueError, "CSV header"):
            traffic.publish(writer, "owner/repo", snapshot)
        self.assertTrue(all(method == "GET" for method, _, _ in writer.calls))
        self.assertTrue(traffic.merge_daily(None, fixture()).startswith("date,views,"))

    def test_atomic_snapshot_and_expected_parent(self):
        writer = Writer()
        snapshot = {**fixture(), "collected_at_utc": "2026-10-18T00:00:00+00:00"}
        traffic.publish(writer, "owner/repo", snapshot)
        writes = [(method, path, data) for method, path, data in writer.calls if method != "GET"]
        self.assertEqual([m for m, _, _ in writes], ["POST", "POST", "PATCH"])
        self.assertEqual(writes[1][2]["parents"], ["a" * 40])
        self.assertEqual(writes[-1][2], {"sha": "c" * 40, "force": False})
        self.assertTrue(writes[-1][1].endswith("/refs/heads/traffic-history"))
        entries = writes[0][2]["tree"]
        self.assertEqual({x["path"] for x in entries}, {
            "data/daily.csv", "data/latest.json", "data/snapshots/2026-10-18.json"})

    def test_concurrent_history_update_is_not_forced_or_retried(self):
        writer = Writer(race=True)
        snapshot = {**fixture(), "collected_at_utc": "2026-10-18T00:00:00+00:00"}
        with self.assertRaisesRegex(RuntimeError, "non-fast-forward"):
            traffic.publish(writer, "owner/repo", snapshot)
        self.assertEqual(sum(m == "PATCH" for m, _, _ in writer.calls), 1)

    def test_non_main_and_missing_secret_fail_before_api_access(self):
        with patch.dict(traffic.os.environ, {"GITHUB_REF": "refs/pull/1/merge"}, clear=True):
            with self.assertRaisesRegex(ValueError, "restricted to main"):
                traffic.main()
        environment = {"GITHUB_REF": "refs/heads/main", "GITHUB_REPOSITORY": "owner/repo",
                       "GITHUB_SHA": "a" * 40}
        with patch.dict(traffic.os.environ, environment, clear=True), patch.object(traffic, "GitHub") as api:
            with self.assertRaisesRegex(ValueError, "TRAFFIC_RAW"):
                traffic.main()
            api.assert_not_called()


if __name__ == "__main__":
    unittest.main()
