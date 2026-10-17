# Workbook guide

## Source of truth

The VBA modules in [`src/vba`](../src/vba) are the source of truth. The
`.xlsm` workbook is a build output: it is not committed (`/dist/` is
ignored) and is rebuilt from the modules. `modSetup` creates every sheet,
writes the default parameters and the synthetic sample portfolio, and embeds
the expected results of the regression test.

| Module | Responsibility |
| --- | --- |
| `modConfig` | Sheet names, risk class codes, components, scenarios |
| `modUtil` | Sheet access, tagged parameter tables, conversions, run log |
| `modParams` | Loads Control settings and `P_*` parameters; risk weight and correlation accessors |
| `modSBM` | Delta, vega and curvature: validation, netting, bucket and cross-bucket aggregation |
| `modDRC` | Default risk charge for non-securitizations |
| `modRRAO` | Residual risk add-on |
| `modMain` | `RunAll`, `RunAllSilent`, `ClearOutputs`, Results and Out_Summary |
| `modSetup` | `Setup_BuildWorkbook`, `Setup_ResetParameters`, `Setup_LoadSampleData` |
| `modTest` | `RunRegressionTest`, `RunRegressionTestSilent` |
| `modDev` | `Dev_ExportModules`: export the modules back to `src/vba` |

## Building the workbook (Windows, Excel)

1. In Excel, enable **File > Options > Trust Center > Trust Center Settings >
   Macro Settings > Trust access to the VBA project object model**.
2. From the repository root:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tools\Build-Workbook.ps1 -RunTests
   ```

   The script imports the modules into a new workbook, runs
   `Setup_BuildWorkbook`, runs the calculation and the regression test, and
   saves `dist\FRTB-SA-Prototype.xlsm`. Add `-Force` to overwrite.

Manual alternative: in a new workbook open the VBA editor (Alt+F11), use
**File > Import File** for every `.bas` file in `src\vba`, run
`Setup_BuildWorkbook` (Alt+F8), then save as `.xlsm`.

## Sheets

| Sheet | Content |
| --- | --- |
| `README` | Short usage notes |
| `Control` | Run settings (`[SETTINGS]`) and buttons: run, regression test, clear outputs |
| `Results` | Formatted summary by risk class, component and scenario; SBM, DRC, RRAO, total |
| `In_Delta`, `In_Vega`, `In_Curvature` | Sensitivity inputs (see [methodology](methodology.md#inputs)) |
| `In_DRC` | Positions: obligor, bucket (`CORP`, `SOV`, `LGM`), credit quality, seniority, notional, market value, maturity, optional LGD |
| `In_RRAO` | Category (`EXOTIC`, `OTHER`) and gross notional |
| `Out_Summary` | Key/value results used by tests |
| `Out_RiskClass` | Capital per risk class, component and scenario; `AltSbUsed` flag |
| `Out_Buckets` | `Kb`, `Sb`, risk factor count and notes (`ALT_SB`, `UP`/`DOWN`, `OTHER`) per bucket |
| `Out_DRC` | Net long/short per obligor; HBR and charge per bucket |
| `Log` | Every rejected input row with the reason, warnings and run status |
| `P_*` | Regulatory parameters in tagged tables (`[TAG]`, header row, data rows) |
| `Test_Expected` | Expected sample results, actual values and PASS/FAIL per item |

Input sheets are read from row 2 down to the first row whose `ID` and second
column are both blank. Invalid rows are skipped and logged on `Log`; check
the error count on `Results` after every run.

## Running

* **Run calculation** (`RunAll`) recalculates everything and rewrites the
  output sheets and the log.
* **Run regression test** (`RunRegressionTest`) compares the last run with
  `Test_Expected`. It is meaningful only with the sample data and default
  parameters and settings: run `Setup_LoadSampleData` and `RunAll` first.
* `Setup_ResetParameters` rewrites the `P_*` sheets with the defaults.

## Changing the VBA

1. Edit the modules in the VBA editor of a built workbook.
2. Run `Dev_ExportModules` to write them back to `src\vba` (the workbook must
   sit in the repository root or in `dist\`).
3. On a machine with LibreOffice and Python, run the checks in
   [validation](validation.md). If the sample portfolio, parameters or
   engine logic changed, regenerate the expected values with
   `python3 tools/update_expected.py` and review the diff.
