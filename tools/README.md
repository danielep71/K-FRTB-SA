# 🛠️ Tools

| Tool | Purpose |
| --- | --- |
| `Build-Workbook.ps1` | Builds `dist\K-FRTB-SA.xlsm` from the VBA source through Excel COM (Windows) |
| `lo_runner.py` | Runs the VBA modules headless in LibreOffice Calc and saves the result as `.xlsx` |
| `vba_lint.py` | Static checks approximating Excel's compile checks and the module conventions |
| `update_expected.py` | Regenerates (or `--check`s) the expected values embedded in `M_Setup` from the reference |

None of the tools holds calculation logic; see [validation](../docs/validation.md)
for how they are used together.
