# SPDX-License-Identifier: MIT
"""Synthetic failures for the universal maintenance gate, without network."""

import copy
from pathlib import Path
import sys
import subprocess
import tempfile
import unittest

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "tools"))
import check_repository as checker


class RepositoryIntegrityTests(unittest.TestCase):
    def check_fixture(self, files):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, content in files.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)
            return checker.validate_files(root, list(files))

    def test_valid_links_and_markdown_hard_breaks(self):
        self.assertEqual(self.check_fixture({"guide.md": "# Guide\n\n[Child](docs/child.md#scope)  \n[Site](https://example.com)\n", "docs/child.md": "# Scope\n"}), [])

    def test_invalid_and_duplicate_configurations(self):
        for name, text in [("a.json", '{"a":1,"a":2}\n'), ("a.json", "\0\n"), ("a.yml", "a: 1\na: 2\n"), ("a.yml", "a: [\n")]:
            with self.subTest(name=name, text=text):
                self.assertTrue(self.check_fixture({name: text}))
        self.assertIn("on", checker.load_yaml("on:\n  push: null\n"))
        for constant in ["NaN", "Infinity", "-Infinity"]:
            with self.subTest(constant=constant):
                errors = self.check_fixture({"a.json": '{"value":' + constant + '}\n'})
                self.assertTrue(any("non-standard JSON constant" in error for error in errors))

    def test_binary_formats_follow_git_attributes(self):
        source = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / ".gitattributes").write_text((source / ".gitattributes").read_text() + "\n*.fixture opaque\n")
            names = ["preview.png", "screenshot.jpeg", "bundle.zip", "K-FRTB-SA.xlsm", "template.xlsx", "custom.fixture"]
            for name in names + ["bad.txt"]:
                (root / name).write_bytes(b"\x00\xff\x10")
            binary = checker.binary_paths(root, names + ["bad.txt"])
            self.assertEqual(binary, set(names))
            self.assertEqual(checker.validate_files(root, names, binary), [])
            self.assertTrue(checker.validate_files(root, ["bad.txt"], binary))

    def test_broken_links_and_tracked_whitespace(self):
        for text in ["[Missing](missing.md)\n", "[Outside](../outside.md)\n", "bad \n", "no newline", "extra\n\n"]:
            with self.subTest(text=text):
                self.assertTrue(self.check_fixture({"guide.md": text}))
        self.assertEqual(self.check_fixture({"guide.md": "```md\n[Example](absent.md)\n```\n"}), [])

    def test_unpinned_actions_are_rejected(self):
        workflow = {"name": "Fixture", "on": {"push": None}, "jobs": {"test": {"steps": [{"uses": "actions/checkout@main"}]}}}
        with self.assertRaisesRegex(ValueError, "full commit SHA"):
            checker.validate_workflow(workflow)
        good = copy.deepcopy(workflow)
        good["jobs"]["test"]["steps"][0]["uses"] = "actions/checkout@" + "a" * 40
        checker.validate_workflow(good)

    def test_path_filters_and_wrong_dependabot_target_fail(self):
        source = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in [".github/workflows/integrity.yml", ".github/workflows/pr-milestones.yml", ".github/dependabot.yml"]:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text((source / name).read_text())
            checker.validate_controls(root)
            workflow_path = root / ".github/workflows/integrity.yml"
            workflow = checker.load_yaml(workflow_path.read_text())
            workflow["on"]["pull_request"]["paths"] = ["tools/**"]
            workflow_path.write_text(yaml.safe_dump(workflow))
            with self.assertRaisesRegex(ValueError, "without path filters"):
                checker.validate_controls(root)
            workflow_path.write_text((source / ".github/workflows/integrity.yml").read_text())
            dependabot_path = root / ".github/dependabot.yml"
            dependabot_path.write_text(dependabot_path.read_text().replace("target-branch: release/v0.1.0", "target-branch: main", 1))
            with self.assertRaisesRegex(ValueError, "Dependabot must cover"):
                checker.validate_controls(root)

    def test_dependabot_retirement_and_coverage_regressions(self):
        source = Path(__file__).resolve().parents[2]
        baseline = checker.load_yaml((source / ".github/dependabot.yml").read_text())
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            workflow_path = root / ".github/workflows/integrity.yml"
            workflow_path.parent.mkdir(parents=True)
            workflow_path.write_text((source / ".github/workflows/integrity.yml").read_text())
            milestone_path = root / ".github/workflows/pr-milestones.yml"
            milestone_path.write_text((source / ".github/workflows/pr-milestones.yml").read_text())
            dependabot_path = root / ".github/dependabot.yml"

            def validate(document):
                dependabot_path.write_text(yaml.safe_dump(document))
                checker.validate_controls(root)

            validate(baseline)
            for index, entry in enumerate(baseline["updates"]):
                with self.subTest(ecosystem=entry["package-ecosystem"], directory=entry["directory"]):
                    missing = copy.deepcopy(baseline)
                    del missing["updates"][index]
                    duplicate = copy.deepcopy(baseline)
                    duplicate["updates"].append(copy.deepcopy(entry))
                    retired = copy.deepcopy(baseline)
                    retired["updates"][index]["target-branch"] = "release/v0.0.1"
                    for broken in [missing, duplicate, retired]:
                        with self.assertRaisesRegex(ValueError, "Dependabot must cover"):
                            validate(broken)
                    wrong_milestone = copy.deepcopy(baseline)
                    wrong_milestone["updates"][index]["milestone"] = 1
                    with self.assertRaisesRegex(ValueError, "no milestone setting"):
                        validate(wrong_milestone)


if __name__ == "__main__":
    unittest.main()
