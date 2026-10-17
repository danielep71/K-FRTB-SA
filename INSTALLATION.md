# Repository setup and local verification

This guide supports the setup repository, not installation of a calculation
engine. Git and Node.js with built-in fetch support are the only prerequisites
for the existing commands; no npm packages, Python packages, Excel, or
PowerShell are required. The setup commands were verified on Linux with
Git 2.51.1 and Node.js 24.19.0. Other hosts have not been runtime-certified.

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
node .github/scripts/labels-sync.mjs --self-test
node .github/scripts/labels-sync.mjs --mode validate
node .github/scripts/labels-drift.mjs --self-test
git diff --check
git diff --cached --check
git status --short
```

All three Node commands must exit successfully. They validate label
configuration and offline fixtures, without GitHub credentials or label
mutation. Whitespace checks inspect local changes; an empty diff does not
validate all committed content. A fresh checkout should be clean.

Read the purpose of `src/`, `tests/`, `docs/`, and `tools/` in
[Repository structure](docs/REPOSITORY_STRUCTURE.md). Track new source,
fixtures, manifests, and reviewed documentation deliberately. Keep caches and
generated output local. For policy changes, probe representative paths with
`git check-ignore --no-index` and `git check-attr`.

The universal local command and ordinary-PR integrity workflow are pending
issue #7. The commands above do not execute an engine or Excel, test a
workbook, or establish independently verified capital results.

## SA prototype (v0.1.0)

The [v0.1.0 - SA prototype](https://github.com/danielep71/MKT-FTRB-SA/milestone/2)
work integrates on `release/v0.1.0` (issue #20). It does not resolve the
platform and coverage decisions in [Scope](docs/SCOPE.md).

- Checks on Linux: Python 3, LibreOffice Calc with the Python UNO bridge
  (`python3-uno`) and the pinned packages in `tests/requirements.txt`; run
  `python3 tools/vba_lint.py` and `REQUIRE_LIBREOFFICE=1 python3 -m pytest tests`
  as described in [Validation](docs/validation.md).
- Workbook on Windows: desktop Excel and PowerShell; run
  `tools\Build-Workbook.ps1 -RunTests` as described in the
  [workbook guide](docs/workbook-guide.md#building-the-workbook-windows-excel).

The allowed template path remains a reservation until a reviewed template is
committed.
