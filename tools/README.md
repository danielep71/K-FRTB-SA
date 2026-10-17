# 🛠️ Repository tooling

This directory indexes maintenance tools and the helpers of the v0.1.0
prototype (issue #20). None of them holds calculation logic.

| Tool | Purpose |
| --- | --- |
| `Build-Workbook.ps1` | Builds `dist\K-FRTB-SA.xlsm` (or, with `-Template`, the macro-free `dist\FRTB_Template.xlsx`) from the VBA source through Excel COM on Windows |
| `lo_runner.py` | Runs the VBA modules headless in LibreOffice Calc and saves the result as `.xlsx` |
| `vba_lint.py` | Static checks approximating Excel's compile checks and the module conventions |
| `update_expected.py` | Regenerates (or `--check`s) the expected values embedded in `M_Setup` from the independent reference |

[Validation](../docs/validation.md) lists their prerequisites (Python 3,
LibreOffice Calc with the Python UNO bridge, the pinned packages in
`tests/requirements.txt`) and how they are used together.

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

The universal validation entry point, hosted integrity workflow, and dependency
update configuration are pending issue #7. No `tools/check.py` or other
universal runner exists yet. Do not report an absent gate as green.
Generated output and durable evidence follow
[Repository structure](../docs/REPOSITORY_STRUCTURE.md).
