# Repository setup and local verification

This guide supports the setup repository, not installation of a calculation
engine. The universal check requires Git, Node.js with built-in fetch, Python
3.12 or newer and the pinned parser in `.github/requirements.txt`. No npm
packages, Excel or PowerShell are required. Local verification used Linux,
Git 2.51.1, Node.js 24.19.0 and Python 3.12.14; hosted CI uses Ubuntu 24.04.

## Check out the active work

```sh
git clone --branch release/v0.0.1 https://github.com/danielep71/MKT-FTRB-SA.git
cd MKT-FTRB-SA
git branch --show-current
git rev-parse HEAD
git --version
node --version
```

The selected branch should be `release/v0.0.1`; record the source commit
when reporting results. Main remains the stable default. Create focused task
branches from the integration branch following [Governance](docs/GOVERNANCE.md).

Use a Git clone for development and checks. The inherited archive attributes
exclude repository-control files and `.github/` from Git-produced source
archives, so such an archive is not a complete maintenance checkout.

## Verify the setup

From the repository root:

```sh
python3 -m venv .venv-ci
.venv-ci/bin/python -m pip install -r .github/requirements.txt
.venv-ci/bin/python tools/check_repository.py
git diff --check
git diff --cached --check
git status --short
```

Use `.venv-ci\Scripts\python` on Windows. The universal command must exit 0;
it includes the existing label commands, maintenance fixtures, JSON/YAML,
tracked whitespace and local Markdown target checks. Stage new files first
so they appear in its tracked-file inventory. No GitHub credentials are used.
The additional diff checks inspect local changes; the universal command also
inspects unchanged tracked files. A fresh checkout should be clean.

Read the purpose of `src/`, `tests/`, `docs/`, and `tools/` in
[Repository structure](docs/REPOSITORY_STRUCTURE.md). Track new source,
fixtures, manifests, and reviewed documentation deliberately. Keep caches and
generated output local. For policy changes, probe representative paths with
`git check-ignore --no-index` and `git check-attr`.

See [Repository checks](docs/CI.md) for hosted branch coverage, Dependabot,
failure behavior and the #2 protection handoff. These checks do not execute
an engine or Excel, test a workbook, or establish verified capital results.

## Before functional development

The owner created
[v0.1.0 - SA prototype](https://github.com/danielep71/MKT-FTRB-SA/milestone/2)
for the next stage. Its existence does not change the current integration
branch or resolve the platform and coverage decisions in [Scope](docs/SCOPE.md).
Record those decisions before adding a runtime, build procedure, packages,
or real workbook. The allowed template path is a reservation only.
