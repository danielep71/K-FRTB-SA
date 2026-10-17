# 🧪 Repository checks and dependency updates

[![Scope: maintenance](https://img.shields.io/badge/checks-repository_maintenance-1D76DB)](../tools/check_repository.py)

## Run the same check locally

Use a Git clone, Python 3.12 or newer, Node.js with built-in fetch, and Git.
Install the one pinned configuration-parser package in a local environment:

```sh
python3 -m venv .venv-ci
.venv-ci/bin/python -m pip install -r .github/requirements.txt
.venv-ci/bin/python tools/check_repository.py
```

On Windows use `.venv-ci\Scripts\python` instead of `.venv-ci/bin/python`.
Run from the repository root. Stage new source and documentation before running
the command: it inspects paths returned by `git ls-files`, using their current
working-tree contents. It checks committed files even when the diff is empty.
It does not stage, commit, change labels, read secrets, or contact GitHub.
Installing the package requires access to the package registry; validation
after installation and all maintenance fixtures are offline.

## What the gate checks

- All tracked JSON and YAML parse successfully, with duplicate keys rejected.
  GitHub's YAML `on` key remains text. Workflow files have basic structural
  checks and external step actions use full commit SHAs. This is not complete
  GitHub Actions or issue-form schema validation.
- Tracked text has a final newline and no accidental trailing whitespace or
  extra EOF blank lines. Intentional Markdown hard breaks are allowed. VBA
  exports may use CRLF and Windows-1252; binary assets are excluded from text
  checks by the documented extensions in the checker.
- Common inline Markdown links/images and reference definitions outside code
  fences point to tracked repository files or directories. Anchors and remote
  URLs are not fetched or validated; this is not a complete Markdown parser.
- The universal workflow keeps its unconditional stable check and branch
  coverage. Dependabot covers the inspected ecosystems and intended branches.
- The existing label self-tests, manifest validation and read-only drift
  fixtures run once through their authoritative scripts. The path-filtered
  label workflows remain responsible for their own live evidence and trusted
  reconciliation; this runner does not duplicate their implementations.
- Offline maintenance tests under `tests/tooling` cover malformed/duplicate
  configuration, broken links, whitespace, unpinned actions, narrowed trigger
  coverage, incorrect update targets, and the traffic collector's safeguards.

A failed prerequisite, validation error or failed child command exits nonzero.
The fixture suite includes clean input as well as deliberate failures. It
never deletes a live label or exports real traffic.

## Hosted check and protection handoff

Workflow: [Repository integrity](../.github/workflows/integrity.yml).
The job ID is `integrity`; the exact check name is **Repository integrity**.
The producer is **GitHub Actions** (app slug `github-actions`, app ID `15368`).
There is no matrix, job condition, path filter or changed-file shortcut.
PRs targeting `main` or `release/**`, and pushes to those branches, run the
same command on Ubuntu 24.04. Manual dispatch is also available after
default-branch activation. Checkout is pinned to the existing reviewed SHA,
credentials are not persisted, permissions are `contents: read`, timeout is
10 minutes, and newer runs cancel older runs for the same workflow/ref.

Issue #2 owns attaching that check name and app identity to the main/release
rulesets, requiring main to be up to date, and verifying effective enforcement.
Adding this workflow does not itself change those settings. A task PR proves
the hosted command; release-to-main integration and synchronization into the
prototype branch (#31) install the workflow on the respective branch lines.
Do not require a check on a line before installing it there.

## 🔄 Dependabot policy

The configuration must reach the default branch before GitHub schedules
version updates. It follows the two existing workstreams:

| Ecosystem and manifest location | Version-update PR target | Milestone |
| --- | --- | --- |
| GitHub Actions, `/` | `release/v0.0.1` | v0.0.1 |
| GitHub Actions, `/` | `release/v0.1.0` | v0.1.0 |
| pip, `/.github/requirements.txt` (PyYAML configuration parser) | `release/v0.0.1` | v0.0.1 |
| pip, `/tests/requirements.txt` (prototype NumPy, openpyxl, pytest) | `release/v0.1.0` | v0.1.0 |

The prototype dependency file was inspected on `7f6f15a`; those packages are
not copied into the setup branch. Both lines use GitHub Actions. There is no
npm package manifest: the label scripts use Node built-ins. No npm updater or
other absent ecosystem is configured. Each entry runs weekly, limits open
PRs to five, assigns `danielep71`, and sets exactly P3 plus type labels and the
target milestone. Maintainers must still verify all metadata during triage.

Non-default `target-branch` settings govern version updates, not security
update PRs. The existing Dependabot alerts stay enabled; automatic security
update PRs remain off under the recorded settings baseline. Enabling or
retargeting them is a separate settings decision under #2, not an assertion
made by this file. See the [official options reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference).

## Evidence boundaries

This gate checks repository maintenance. It does not execute Excel, run the
FRTB engine, validate formulas, certify regulation, or substitute for runtime
and independent numerical evidence. The prototype's separate checks already
cover VBA lint, Python reference tests and LibreOffice reconciliation on its
branch. Excel build/compile/runtime evidence is tracked in #28, methodology
decisions in #29, and prototype synchronization in #31. Future engine gates
must retain independently derived expectations and name the actual host and
commit, following [Scope](SCOPE.md) and the [structure policy](REPOSITORY_STRUCTURE.md).
