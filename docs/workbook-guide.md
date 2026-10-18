# 🗂️ Workbook Guide

## Numeric cells and numeric text

Use actual Excel numeric cells for amounts and parameters; values entered
with Excel's local decimal separator retain their numeric value. Text cells
have a locale-independent contract: optional sign, decimal point and optional
`E` exponent (for example `0.5`, `.5`, `-1.25e2`). The entire trimmed text
must match and fit a VBA Double. Commas, grouping, currency/type suffixes,
embedded whitespace, trailing junk and overflow are rejected rather than
partly converted. Thus text `0,5` is rejected on every host; a numeric cell
containing one half is supported on every host. Required key/value numeric
parameters reject blank, error and nonnumeric values with key/sheet context.
Every numeric value in a `P_*` table (risk weights, correlation matrices,
liquidity horizons, DRC and RRAO weights, bucket numbers) and every entry of
a `P_General` vertex list is required as well: a blank or nonnumeric value,
an empty list or a blank list entry (`0.25,,1`, a trailing comma) stops the
run and the `Log` names the sheet, table, data row and column, or the list.
Tagged parameter tables reject blank keys in populated rows and completely
blank rows followed by more data before the next tag; blank separator rows
between tables remain valid (#48).
Every run clears the output sheets first and again when it fails, so a
failed run shows "Run failed" on `Results` and leaves neither earlier nor
partial capital behind (#45).

Validation and conversion use the same parser. Blank/error optional values
still use the caller's explicit default; this does not relax required-key
validation. The runtime regression suite covers these contracts (#41).

[![Model: template plus source](https://img.shields.io/badge/model-template%20%2B%20source-0969da)](#source-of-truth)
[![Build: Excel COM](https://img.shields.io/badge/build-Excel%20COM-217346)](#building-the-workbook-windows-excel)
[![Layout: workbook frame](https://img.shields.io/badge/layout-workbook%20frame-1f3864)](#sheets)

This document is authoritative for **how the workbook is built, laid out and
used**. What it calculates is owned by the [methodology](methodology.md);
what is checked by the [validation record](validation.md).

<a id="source-of-truth"></a>

## 🧩 Source of truth

The exported VBA modules are the source of truth. The macro-free template
`src/workbook/FRTB_Template.xlsx` holds the sheets, styles, default
parameters, sample portfolio and expected results that `M_Setup.BuildWorkbook`
produces, without a VBA project, buttons or personal document properties.
The `.xlsm` workbook is a build output: it is not committed (`/dist/` is
ignored) and is built from the template plus the modules, following the
[template-based build](REPOSITORY_STRUCTURE.md#conditional-excelvba-policy).

The template is generated, never edited by hand: `python3
tools/build_template.py` rebuilds it headless in LibreOffice, and
`tools/update_expected.py` rebuilds it whenever the expected values change.
`tests/test_template.py` fails when the committed template differs from a
fresh build of the modules, in values or layout, or carries VBA, controls or
personal properties.
`tools/Build-Workbook.ps1 -Template` produces the same template through Excel.

```text
src/
  modules/     VBA modules: engine (CORE_*, Option Private Module) and workbook macros (M_*)
  workbook/    macro-free template FRTB_Template.xlsx
tests/
  modules/     VBA test modules imported into development builds (TEST_*)
  *.py         independent reference, reconciliation and tooling tests
tools/         build script, template builder, LibreOffice runner, VBA lint, expected-value generator
docs/          methodology, workbook guide, validation, assets
```

| Module | Responsibility |
| --- | --- |
| `src/modules/CORE_Config` | Product name, sheet names, layout, palette, risk class codes, components, scenarios |
| `src/modules/CORE_Util` | Sheet access, tagged parameter tables, conversions, table formatting, run log |
| `src/modules/CORE_Params` | Control settings and `P_*` parameters; risk weight and correlation accessors |
| `src/modules/CORE_SBM` | Delta, vega and curvature: validation, netting, bucket and cross-bucket aggregation |
| `src/modules/CORE_DRC` | Default risk charge for non-securitizations |
| `src/modules/CORE_RRAO` | Residual risk add-on |
| `src/modules/M_Main` | `RunFRTB`, `RunFRTB_Silent`, `ClearOutputs`; Results and Out_Summary |
| `src/modules/M_Setup` | `BuildWorkbook`, `FinishWorkbook`, `ResetParameters`, `LoadSampleData` |
| `src/modules/M_Dev` | `Dev_ExportModules`: export the modules back to their folders |
| `tests/modules/TEST_Regression` | `Test_RunRegression`, `Test_RunRegression_Silent` |
| `tests/modules/TEST_Numeric` | `Test_NumericContracts_Silent`: numeric validation and conversion contracts |

Each module opens with a banner (purpose, public surface, dependencies, state
ownership, error policy, compatibility); `tools/vba_lint.py` checks the banner,
the `CORE_`, `M_` and `TEST_` prefixes and `Option Private Module` in `CORE_`
modules.

<a id="building-the-workbook-windows-excel"></a>

## 🏗️ Building the workbook (Windows, Excel)

1. In Excel, enable **File > Options > Trust Center > Trust Center Settings >
   Macro Settings > Trust access to the VBA project object model**.
2. From the repository root:

   ```powershell
   powershell -ExecutionPolicy Bypass -File tools\Build-Workbook.ps1 -RunTests
   ```

   The script opens a copy of `src\workbook\FRTB_Template.xlsx`, imports
   `src\modules` and `tests\modules`, runs `FinishWorkbook` (sheet buttons
   and window settings), the calculation and the regression test, and saves
   `dist\K-FRTB-SA.xlsm`. `-FromSource` builds every sheet from the modules
   (`BuildWorkbook`) instead of the template; `-Production` leaves out the
   test modules; `-Template` saves a source-built, macro-free template as
   `dist\FRTB_Template.xlsx` for comparison with the committed one; `-Force`
   overwrites an existing file.
3. Open the workbook and run **Debug → Compile VBAProject**.

Manual alternative: open a copy of `src\workbook\FRTB_Template.xlsx`, open
the VBA editor (Alt+F11), use **File > Import File** for every `.bas` file of
`src\modules` and `tests\modules`, run `FinishWorkbook` (Alt+F8), then save
as `.xlsm`.

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
2. Run `Dev_ExportModules` to write them back to `src\modules` and
   `tests\modules` (the workbook must sit in the repository root or in
   `dist\`).
3. On a machine with LibreOffice and Python, run the checks in
   [validation](validation.md). If the sample portfolio, parameters or engine
   logic changed, regenerate the expected values with
   `python3 tools/update_expected.py` (which also rebuilds the template) and
   review the diff. A layout change needs `python3 tools/build_template.py`.
