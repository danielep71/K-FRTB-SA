#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Offline, tracked-file repository checks; no Excel or regulatory validation."""

import json
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit

import yaml


class ConfigLoader(yaml.SafeLoader):
    """Reject duplicate keys and preserve GitHub's YAML `on` key as text."""


ConfigLoader.yaml_implicit_resolvers = {
    key: [(tag, pattern) for tag, pattern in values if tag != "tag:yaml.org,2002:bool"]
    for key, values in yaml.SafeLoader.yaml_implicit_resolvers.items()
}
ConfigLoader.add_implicit_resolver(
    "tag:yaml.org,2002:bool", re.compile(r"^(?:true|false)$", re.IGNORECASE), list("tTfF")
)


def unique_pairs(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate key: {key}")
        result[key] = value
    return result


def yaml_mapping(loader, node):
    return unique_pairs((loader.construct_object(key), loader.construct_object(value)) for key, value in node.value)


ConfigLoader.add_constructor("tag:yaml.org,2002:map", yaml_mapping)


def load_yaml(text):
    return yaml.load(text, Loader=ConfigLoader)


def reject_json_constant(value):
    raise ValueError(f"non-standard JSON constant: {value}")


def binary_paths(root, paths):
    result = subprocess.check_output(
        ["git", "check-attr", "-z", "--stdin", "text"],
        input=("\0".join(paths) + "\0").encode(), cwd=root,
    ).decode().rstrip("\0").split("\0")
    return {result[index] for index in range(0, len(result), 3) if result[index + 2] == "unset"}


def markdown_targets(text):
    # Common inline links/images and reference definitions outside fenced code.
    lines = []
    fence = None
    for line in text.splitlines():
        match = re.match(r"^\s*(`{3,}|~{3,})", line)
        if match:
            marker = match[1][0]
            fence = None if fence == marker else marker if fence is None else fence
            continue
        if fence is None:
            lines.append(re.sub(r"`[^`]*`", "", line))
    body = "\n".join(lines)
    targets = re.findall(r"\]\(\s*(<[^>]+>|[^\s)]+)(?:\s+[^)]*)?\)", body)
    targets += re.findall(r"^\s*\[[^\]]+\]:\s*(<[^>]+>|\S+)", body, re.MULTILINE)
    return [target.strip("<>") for target in targets]


def validate_files(root, paths, binary=frozenset()):
    errors = []
    tracked = set(paths)
    for name in paths:
        path = root / name
        try:
            data = path.read_bytes()
        except OSError as error:
            errors.append(f"{name}: {error}")
            continue
        if name in binary:
            continue
        if b"\0" in data:
            errors.append(f"{name}: unexpected NUL in text")
            continue
        try:
            text = data.decode("utf-8")
        except UnicodeDecodeError:
            if path.suffix.lower() in {".bas", ".cls", ".frm"}:
                text = data.decode("cp1252")
            else:
                errors.append(f"{name}: text must be UTF-8")
                continue
        for number, line in enumerate(text.splitlines(), 1):
            trailing = line[len(line.rstrip(" \t")):]
            hard_break = path.suffix == ".md" and len(trailing) >= 2 and set(trailing) == {" "}
            if trailing and not hard_break:
                errors.append(f"{name}:{number}: trailing whitespace")
        if text and not text.endswith("\n"):
            errors.append(f"{name}: missing final newline")
        if re.search(r"\n[\r\n]+\Z", text):
            errors.append(f"{name}: extra blank line at EOF")
        try:
            if path.suffix == ".json":
                json.loads(text, object_pairs_hook=unique_pairs, parse_constant=reject_json_constant)
            elif path.suffix in {".yml", ".yaml"}:
                document = load_yaml(text)
                if not isinstance(document, dict):
                    raise ValueError("configuration must be a mapping")
                if name.startswith(".github/workflows/"):
                    validate_workflow(document)
            elif path.suffix == ".md":
                for target in markdown_targets(text):
                    parsed = urlsplit(target)
                    if parsed.scheme or parsed.netloc or not parsed.path:
                        continue
                    destination = (root / parsed.path.lstrip("/")) if parsed.path.startswith("/") else path.parent / unquote(parsed.path)
                    destination = destination.resolve()
                    if not destination.is_relative_to(root.resolve()):
                        raise ValueError(f"link escapes repository: {target}")
                    relative = destination.relative_to(root.resolve()).as_posix()
                    if relative not in tracked and not any(item.startswith(relative.rstrip("/") + "/") for item in tracked):
                        raise ValueError(f"link target is not tracked: {target}")
        except (ValueError, TypeError, yaml.YAMLError) as error:
            errors.append(f"{name}: {error}")
    return errors


def validate_workflow(document):
    if not document.get("name") or not document.get("on") or not isinstance(document.get("jobs"), dict):
        raise ValueError("workflow requires name, on, and jobs")
    for job in document["jobs"].values():
        if not isinstance(job, dict):
            raise ValueError("workflow job must be a mapping")
        for step in job.get("steps", []):
            action = step.get("uses", "")
            if action and not action.startswith("./") and not re.fullmatch(r"[^\s@]+@[0-9a-f]{40}", action):
                raise ValueError(f"action must use a full commit SHA: {action}")


def validate_controls(root):
    milestone_workflow = load_yaml((root / ".github/workflows/pr-milestones.yml").read_text())
    validate_milestone_workflow(milestone_workflow)
    workflow = load_yaml((root / ".github/workflows/integrity.yml").read_text())
    for event in ("pull_request", "push"):
        config = workflow["on"][event]
        if set(config) != {"branches"} or set(config["branches"]) != {"main", "release/**"}:
            raise ValueError(f"integrity {event} must cover main and release/** without path filters")
    job = workflow["jobs"]["integrity"]
    if job["name"] != "Repository integrity" or "if" in job or "strategy" in job:
        raise ValueError("integrity must provide one unconditional stable Repository integrity check")
    if workflow["permissions"] != {"contents": "read"} or job["permissions"] != {"contents": "read"}:
        raise ValueError("integrity must use read-only contents permission")
    updates = load_yaml((root / ".github/dependabot.yml").read_text())
    if updates["version"] != 2:
        raise ValueError("Dependabot requires version 2")
    expected = {
        ("github-actions", "/", "release/v0.1.0"),
        ("pip", "/.github", "release/v0.1.0"),
        ("pip", "/tests", "release/v0.1.0"),
    }
    actual = [(item["package-ecosystem"], item["directory"], item["target-branch"]) for item in updates["updates"]]
    if set(actual) != expected or len(actual) != len(expected):
        raise ValueError("Dependabot must cover Actions, CI parser and prototype packages once each on release/v0.1.0")
    for item in updates["updates"]:
        if "milestone" in item:
            raise ValueError("Dependabot PRs must have no milestone setting")
        if item["assignees"] != ["danielep71"] or [label for label in item["labels"] if label in {"P1", "P2", "P3"}] != ["P3"]:
            raise ValueError("Dependabot requires owner and exactly P3")


def validate_milestone_workflow(document):
    events = document["on"]
    if set(events) != {"push", "pull_request_target", "schedule", "workflow_dispatch"} or events["push"] != {"branches": ["main"], "paths": [".github/workflows/pr-milestones.yml"]} or events["pull_request_target"] != {"types": ["opened", "reopened", "edited", "milestoned"]} or events["schedule"] != [{"cron": "17 3 * * *"}]:
        raise ValueError("PR milestone workflow requires event and full-scan coverage")
    job = document["jobs"]["reconcile"]
    if document["permissions"] != {} or job["permissions"] != {"pull-requests": "write"}:
        raise ValueError("PR milestone workflow permissions must be limited to metadata")
    steps = job["steps"]
    if len(steps) != 1 or set(steps[0]) != {"name", "env", "run"} or steps[0]["env"] != {"GH_TOKEN": "${{ github.token }}"} or "${{" in steps[0]["run"]:
        raise ValueError("PR milestone workflow must use trusted inline code without checkout or event interpolation")


def main():
    root = Path(__file__).resolve().parents[1]
    paths = subprocess.check_output(["git", "ls-files", "-z"], cwd=root).decode().rstrip("\0").split("\0")
    errors = validate_files(root, paths, binary_paths(root, paths))
    try:
        validate_controls(root)
    except (OSError, KeyError, TypeError, ValueError, yaml.YAMLError) as error:
        errors.append(f"CI controls: {error}")
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"PASS: configuration, tracked whitespace and local Markdown targets ({len(paths)} files)", flush=True)
    commands = [
        ["node", ".github/scripts/labels-sync.mjs", "--self-test"],
        ["node", ".github/scripts/labels-sync.mjs", "--mode", "validate"],
        ["node", ".github/scripts/labels-drift.mjs", "--self-test"],
        [sys.executable, "-m", "unittest", "discover", "-s", "tests/tooling", "-p", "test_*.py", "-v"],
    ]
    for command in commands:
        subprocess.run(command, cwd=root, check=True)
    print("PASS: repository integrity (maintenance only; no Excel or regulatory certification)")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"Repository integrity failed: {error}", file=sys.stderr)
        sys.exit(1)
