# 🗂️ Workbook Guide

[![Model: source first](https://img.shields.io/badge/model-source--first-0969da)](#source-of-truth)
[![Build: Excel COM](https://img.shields.io/badge/build-Excel%20COM-217346)](#building-the-workbook-windows-excel)
[![Layout: workbook frame](https://img.shields.io/badge/layout-workbook%20frame-1f3864)](#sheets)

This document is authoritative for **how the workbook is built, laid out and
used**. What it calculates is owned by the [methodology](methodology.md);
what is checked by the [validation record](validation.md).

<a id="source-of-truth"></a>

## 🧩 Source of truth

The exported VBA modules are the source of truth. The `.xlsm` workbook is a
build output: it is not committed (`/dist/` is ignored) and is rebuilt from
the modules. `M_Setup` creates every sheet, writes the default parameters and
the synthetic sample portfolio, and embeds the expected results of the
regression test. Building from source is a documented deviation from the
[template-based build](REPOSITORY_STRUCTURE.md#conditional-excelvba-policy):
`tools/Build-Workbook.ps1 -Template` saves the macro-free template for review.

```text
src/
  core/        calculation engine, Option Private Module (CORE_*)
  workbook/    sheet-button macros, workbook builder, developer export (M_*)
tests/
  modules/     VBA test modules imported into development builds (TEST_*)
  *.py         independent reference, reconciliation and tooling tests
tools/         build script, LibreOffice runner, VBA lint, expected-value generator
docs/          methodology, workbook guide, validation, assets
```

| Module | Responsibility |
| --- | --- |
| `src/core/CORE_Config` | Product name, sheet names, layout, palette, risk class codes, components, scenarios |
| `src/core/CORE_Util` | Sheet access, tagged parameter tables, conversions, table formatting, run log |
| `src/core/CORE_Params` | Control settings and `P_*` parameters; risk weight and correlation accessors |
| `src/core/CORE_SBM` | Delta, vega and curvature: validation, netting, bucket and cross-bucket aggregation |
| `src/core/CORE_DRC` | Default risk charge for non-securitizations |
| `src/core/CORE_RRAO` | Residual risk add-on |
| `src/workbook/M_Main` | `RunFRTB`, `RunFRTB_Silent`, `ClearOutputs`; Results and Out_Summary |
| `src/workbook/M_Setup` | `BuildWorkbook`, `ResetParameters`, `LoadSampleData` |
| `src/workbook/M_Dev` | `Dev_ExportModules`: export the modules back to their folders |
| `tests/modules/TEST_Regression` | `Test_RunRegression`, `Test_RunRegression_Silent` |

Each module opens with a banner (purpose, public surface, dependencies, state
ownership, error policy, compatibility); `tools/vba_lint.py` checks the banner, the `CORE_`/`TEST_` prefixes and
`Option Private Module` in core.

<a id="building-the-workbook-windows-excel"></a>

## 🏗️ Building the workbook (Windows, Excel)

1. In Excel, enable **File > Options > Trust Center > Trust Center Settings >
   Macro Settings > Trust access to the VBA project object model**.
2. From the repository root:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tools\Build-Workbook.ps1 -RunTests
   ```

   The script imports `src\core`, `src\workbook` and `tests\modules` into a
   new workbook, runs `BuildWorkbook`, the calculation and the regression
   test, and saves `dist\K-FRTB-SA.xlsm`. `-Production` leaves out the test
   modules; `-Template` saves the freshly built, macro-free workbook as
   `dist\FRTB_Template.xlsx` instead; `-Force` overwrites an existing file.
3. Open the workbook and run **Debug → Compile VBAProject**.

Manual alternative: in a new workbook open the VBA editor (Alt+F11), use
**File > Import File** for every `.bas` file of the three folders, run
`BuildWorkbook` (Alt+F8), then save as `.xlsm`.

<a id="sheets"></a>

## 🎨 Sheets

Every sheet carries the same frame: the product name in gold (`FFC000`) on
a black bar, the title in white on a blue bar (`265A99`), an italic grey
subtitle and tables from column C. Input tables have navy headers (`1F3864`)
and cream input cells (`FFF2CC`); output tables have blue headers
(`2E75B6`); PASS and FAIL use green (`E2EFDA`) and red (`FFC7CE`). The font
is Aptos and gridlines are hidden. The palette is defined once in
`CORE_Config`.

| Tab | Sheet | Content |
| --- | --- | --- |
| Navy | `README` | How to use, input conventions, sheet map |
| Gold | `Control` | Run settings (`[SETTINGS]`) and the buttons Run FRTB-SA, Clear outputs, Run regression test |
| Gold | `In_Delta`, `In_Vega`, `In_Curvature` | Sensitivity inputs (see [methodology](methodology.md#-inputs)) |
| Gold | `In_DRC` | Positions: obligor, bucket (`CORP`, `SOV`, `LGM`), credit quality, seniority, notional, market value, maturity, optional LGD |
| Gold | `In_RRAO` | Category (`EXOTIC`, `OTHER`) and gross notional |
| Gold | `P_General`, `P_GIRR`, `P_CSR`, `P_EQ`, `P_COM`, `P_FX`, `P_DRC`, `P_RRAO` | Regulatory parameters in tagged tables (`[TAG]` heading, header row, data rows), with MAR references |
| Blue | `Results` | Capital by risk class, component and scenario; SBM, DRC, RRAO, total; run note |
| Blue | `Out_Summary` | Key/value results used by tests |
| Blue | `Out_RiskClass` | Capital per risk class, component and scenario; `AltSbUsed` flag |
| Blue | `Out_Buckets` | `Kb`, `Sb`, risk factor count and notes (`ALT_SB`, `UP`/`DOWN`, `OTHER`) per bucket |
| Blue | `Out_DRC` | Net long/short per obligor; HBR and charge per bucket |
| Blue | `Log` | Every rejected input row with the reason, warnings and run status |
| Green | `Test_Expected` | Expected sample results, actual values and PASS/FAIL per item |

Input sheets are read from row 6 down to the first row whose `ID` and
`RiskClass` (or second) column are both blank. Invalid rows are skipped and
logged on `Log`; check the error count on `Results` after every run.

## ▶️ Running

* **Run FRTB-SA** (`RunFRTB`) recalculates everything and rewrites the output
  sheets and the log.
* **Run regression test** (`Test_RunRegression`) compares the last run with
  `Test_Expected`. It is meaningful only with the sample data and default
  parameters and settings: run `LoadSampleData` and `RunFRTB` first.
* `ResetParameters` rewrites the `P_*` sheets with the defaults.

## 🔁 Changing the VBA

1. Edit the modules in the VBA editor of a development build.
2. Run `Dev_ExportModules` to write them back to `src\core`, `src\workbook`
   and `tests\modules` (the workbook must sit in the repository root or in
   `dist\`).
3. On a machine with LibreOffice and Python, run the checks in
   [validation](validation.md). If the sample portfolio, parameters or engine
   logic changed, regenerate the expected values with
   `python3 tools/update_expected.py` and review the diff.
