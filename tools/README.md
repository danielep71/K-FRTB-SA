# 🛠️ Repository tooling

This directory indexes maintenance tools and the helpers of the SA
prototype, milestone v0.2.0 (issue #20). None of them holds calculation logic.

| Tool | Purpose |
| --- | --- |
| `Build-Workbook.ps1` | Builds `dist\K-FRTB-SA.xlsm` from the template and the VBA modules through Excel COM on Windows (`-FromSource` without the template; `-Template` saves a source-built template) |
| `Build-Workbook.cmd` | Double-click launcher for `Build-Workbook.ps1`: asks for a production or development build and whether to overwrite |
| `Sync-FRTB-VBA.ps1` | Replaces the standard modules of an existing `.xlsm` through Excel COM, from the checkout (`-Mode Production` or `Development`) or from a folder (`-SourceDir`), with a safety copy; never writes cells or sheets |
| `Sync-FRTB-VBA.cmd`, `Sync-FRTB-VBA-Downloads.cmd` | Drag-and-drop launchers for `Sync-FRTB-VBA.ps1`: from the checkout, or from a folder that defaults to `%USERPROFILE%\Downloads` |
| `Export-FRTB-VBA.ps1` | Exports every VBA component of a workbook, read-only and with macros disabled, to an empty folder with `export-manifest.json` (workbook and file SHA-256) |
| `compare_vba_export.py` | Compares an export with the source of a commit, read from Git, and checks its binding to the workbook; never runs Excel |
| `build_template.py` | Rebuilds (or `--check`s) the macro-free template `src/workbook/FRTB_Template.xlsx` headless in LibreOffice |
| `lo_runner.py` | Runs the VBA modules headless in LibreOffice Calc and saves the result as `.xlsx` |
| `vba_lint.py` | Static checks approximating Excel's compile checks and the module conventions |
| `check_excel_evidence.py` | Validates an Excel evidence record and its logs against the exact commit (`--evidence`), prints the source digests (`--inventory`) and checks the policy against `M_Setup` (`--check-policy`); never runs Excel. See [Excel evidence](../docs/EXCEL_EVIDENCE.md) |
| `build_market_diagrams.py` | Renders the five market risk and CVA method maps of `docs/assets/market-risk/` as SVG and PNG; needs CairoSVG 2.9.1, which is not a pinned test dependency |
| `update_expected.py` | Regenerates (or `--check`s) the expected values embedded in `M_Setup` from the independent reference, and rebuilds the template when they change |

[Validation](../docs/validation.md) lists their prerequisites (Python 3,
LibreOffice Calc with the Python UNO bridge, the pinned packages in
`tests/requirements.txt` and `.github/requirements.txt`) and how they are used
together. The [workbook guide](../docs/workbook-guide.md#updating-an-existing-workbook)
describes building and updating a workbook on Windows, and
[verifying the round trip](../docs/workbook-guide.md#verifying-the-round-trip).

## Label tooling

Run these from the repository root with Node.js providing built-in fetch
support:

```sh
node .github/scripts/labels-sync.mjs --self-test
node .github/scripts/labels-sync.mjs --mode validate
node .github/scripts/labels-drift.mjs --self-test
```

They run offline fixtures or validate the label catalogue; these commands do
not change live GitHub labels. The scripts stay at their existing authoritative
paths under `.github/scripts/`; do not duplicate them here.
[Labels](../docs/LABELS.md) owns live verification and trusted reconciliation.

## 🧪 Universal maintenance check

Install `.github/requirements.txt`, then run `python tools/check_repository.py`.
It checks tracked configuration, whitespace and local Markdown targets, and
calls the existing label scripts and offline maintenance tests. Coverage and
dependency-update policy are in [Repository checks](../docs/CI.md).

## 📈 Traffic tooling

`traffic_history.py` collects aggregate traffic only from trusted main in the
analytics environment; [Traffic history](../docs/TRAFFIC_HISTORY.md) owns the
contract and credential readiness. Its offline tests run without credentials
through the universal gate. The credentialed daily collection has been active
since October 18, 2026 (#23).
Generated output and durable evidence follow
[Repository structure](../docs/REPOSITORY_STRUCTURE.md).
