#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Daniele Penza
"""Collect aggregate GitHub traffic and atomically publish its data-only branch."""

import base64
import csv
import datetime as dt
import io
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

BRANCH = "traffic-history"
COLUMNS = ["date", "views", "views_uniques", "clones", "clones_uniques"]


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise RuntimeError("Refusing an API redirect with credentials")


class GitHub:
    def __init__(self, token):
        if not token:
            raise ValueError("Required workflow credential is missing")
        self.token = token
        self.opener = urllib.request.build_opener(NoRedirect())

    def request(self, method, path, data=None, missing=False):
        if not path.startswith("/repos/") or ".." in path:
            raise ValueError("Invalid API path")
        payload = None if data is None else json.dumps(data).encode("utf-8")
        request = urllib.request.Request(
            "https://api.github.com" + path, data=payload, method=method,
            headers={"Authorization": "Bearer " + self.token,
                     "Accept": "application/vnd.github+json",
                     "X-GitHub-Api-Version": "2022-11-28",
                     "Content-Type": "application/json", "User-Agent": "FRTB-traffic-history"})
        for attempt in range(3):
            try:
                with self.opener.open(request, timeout=30) as response:
                    content = response.read(8 * 1024 * 1024 + 1)
                if len(content) > 8 * 1024 * 1024:
                    raise ValueError("API response exceeds the size limit")
                return json.loads(content)
            except urllib.error.HTTPError as error:
                if error.code == 404 and missing:
                    return None
                if method == "GET" and error.code in (429, 500, 502, 503, 504) and attempt < 2:
                    time.sleep(2 ** attempt)
                    continue
                # Never echo response bodies, headers, or token values.
                raise RuntimeError(f"GitHub {method} failed with HTTP {error.code}") from None


def count(value):
    if isinstance(value, bool) or not isinstance(value, int) or value < 0:
        raise ValueError("Traffic counts must be nonnegative integers")
    return value


def pair(item):
    total, uniques = count(item["count"]), count(item["uniques"])
    if uniques > total:
        raise ValueError("Unique count exceeds total")
    return total, uniques


def day(value):
    parsed = dt.datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ")
    if parsed.time() != dt.time():
        raise ValueError("Daily traffic timestamps must be UTC midnight")
    return parsed.date().isoformat()


def validate_traffic(payload):
    for metric, key in (("views", "views"), ("clones", "clones")):
        obj = payload[metric]
        pair(obj)
        if not isinstance(obj[key], list):
            raise ValueError("Daily traffic must be a list")
        seen = set()
        for row in obj[key]:
            date = day(row["timestamp"])
            if date in seen:
                raise ValueError("Duplicate day in traffic response")
            seen.add(date)
            pair(row)
    for key, name in (("referrers", "referrer"), ("paths", "path")):
        if not isinstance(payload[key], list):
            raise ValueError("Popular traffic entries must be a list")
        for row in payload[key]:
            if not isinstance(row[name], str):
                raise ValueError("Popular traffic identifier must be text")
            pair(row)


def merge_daily(previous, payload):
    """Replace each overlapping metric/day; never add overlapping 14-day windows."""
    validate_traffic(payload)
    rows = {}
    if previous is not None:
        reader = csv.DictReader(io.StringIO(previous))
        if reader.fieldnames != COLUMNS:
            raise ValueError("Unexpected daily history CSV header")
        for raw in reader:
            if set(raw) != set(COLUMNS) or any(value is None for value in raw.values()):
                raise ValueError("Unexpected daily history CSV row width")
            date = dt.date.fromisoformat(raw["date"]).isoformat()
            if date in rows or raw["date"] != date:
                raise ValueError("Duplicate or noncanonical history date")
            row = {"date": date}
            for key in COLUMNS[1:]:
                value = raw[key]
                if value == "":
                    row[key] = ""
                elif re.fullmatch(r"0|[1-9][0-9]*", value):
                    row[key] = int(value)
                else:
                    raise ValueError("Invalid history count")
            for metric in ("views", "clones"):
                if (row[metric] == "") != (row[metric + "_uniques"] == ""):
                    raise ValueError("Incomplete history count pair")
                if row[metric] != "" and row[metric + "_uniques"] > row[metric]:
                    raise ValueError("Invalid history unique count")
            rows[date] = row
    for metric in ("views", "clones"):
        for item in payload[metric][metric]:
            date = day(item["timestamp"])
            row = rows.setdefault(date, dict.fromkeys(COLUMNS, ""))
            row["date"] = date
            row[metric], row[metric + "_uniques"] = pair(item)
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=COLUMNS, lineterminator="\n")
    writer.writeheader()
    writer.writerows(rows[key] for key in sorted(rows))
    return output.getvalue()


def collect(reader, repository):
    base = "/repos/" + repository + "/traffic/"
    payload = {"views": reader.request("GET", base + "views?per=day"),
               "clones": reader.request("GET", base + "clones?per=day"),
               "referrers": reader.request("GET", base + "popular/referrers"),
               "paths": reader.request("GET", base + "popular/paths")}
    validate_traffic(payload)
    return payload


def publish(writer, repository, snapshot):
    validate_traffic(snapshot)
    base = "/repos/" + repository
    ref = writer.request("GET", base + "/git/ref/heads/" + BRANCH)
    parent = ref["object"]["sha"]
    commit = writer.request("GET", base + "/git/commits/" + parent)
    old = writer.request("GET", base + "/contents/data/daily.csv?ref=" + parent, missing=True)
    previous = None if old is None else base64.b64decode(old["content"]).decode("utf-8")
    merged = merge_daily(previous, snapshot)
    date = dt.datetime.fromisoformat(snapshot["collected_at_utc"]).date().isoformat()
    text = json.dumps(snapshot, ensure_ascii=False, indent=2) + "\n"
    # All responses validate before writing any Git object or ref.
    entries = [{"path": path, "mode": "100644", "type": "blob", "content": content}
               for path, content in [("data/daily.csv", merged),
                                     ("data/latest.json", text),
                                     ("data/snapshots/" + date + ".json", text)]]
    tree = writer.request("POST", base + "/git/trees", {
        "base_tree": commit["tree"]["sha"], "tree": entries})
    new = writer.request("POST", base + "/git/commits", {
        "message": "analytics: collect traffic " + snapshot["collected_at_utc"],
        "tree": tree["sha"], "parents": [parent]})
    # A competing update yields a non-fast-forward rejection; never force or reset.
    writer.request("PATCH", base + "/git/refs/heads/" + BRANCH,
                   {"sha": new["sha"], "force": False})
    return new["sha"]


def main():
    if os.environ.get("GITHUB_REF") != "refs/heads/main":
        raise ValueError("Privileged collection is restricted to main")
    repository = os.environ.get("GITHUB_REPOSITORY", "")
    if not re.fullmatch(r"[A-Za-z0-9_-][A-Za-z0-9_.-]*/[A-Za-z0-9_-][A-Za-z0-9_.-]*", repository):
        raise ValueError("Invalid repository identity")
    source = os.environ.get("GITHUB_SHA", "")
    if not re.fullmatch(r"[a-f0-9]{40}", source):
        raise ValueError("A full workflow source SHA is required")
    token = os.environ.get("TRAFFIC_TOKEN", "")
    if not token:
        raise ValueError("Configure analytics environment secret TRAFFIC_TOKEN with Administration: read")
    payload = collect(GitHub(token), repository)
    snapshot = {"schema_version": 1, "repository": repository,
                "collected_at_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
                "source_commit_sha": source, **payload}
    sha = publish(GitHub(os.environ.get("GITHUB_TOKEN", "")), repository, snapshot)
    print("Published aggregate traffic snapshot to " + BRANCH + " at " + sha)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as output:
            output.write("## 📈 Traffic collection\n\nPublished snapshot: [" + sha[:7] +
                         "](https://github.com/" + repository + "/tree/" + sha + ")\n\n"
                         "Daily rows replace overlapping samples. Daily uniques are not summed across dates.\n")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, RuntimeError, KeyError, TypeError, urllib.error.URLError) as error:
        print("Traffic collection failed: " + str(error), file=sys.stderr)
        sys.exit(1)
