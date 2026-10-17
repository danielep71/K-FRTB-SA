# 🧪 Validation

[![Reconciliation: LibreOffice vs reference](https://img.shields.io/badge/reconciliation-LibreOffice%20vs%20reference-2ea44f)](#automated-checks)
[![Excel evidence: pending](https://img.shields.io/badge/Excel%20evidence-pending-6E7781)](#not-validated)
[![Parameters: BIS checked](https://img.shields.io/badge/parameters-BIS%20checked-1f3a5f)](methodology.md#bis-check)

This document states what is checked automatically, how, and what is not
checked. Treat any result as unvalidated for regulatory use.

<a id="automated-checks"></a>

## ✅ Automated checks

| Check | Command | What it shows |
| --- | --- | --- |
| VBA static lint | `python3 tools/vba_lint.py` | Module banner, `Option Explicit` and `VB_Name` in every module, `CORE_`/`TEST_` prefixes, `Option Private Module` in core, no undeclared identifiers, no duplicate declarations, no cross-module use of private procedures, ASCII-only source |
| Hand-calculated tests | `python3 -m pytest tests/test_reference.py` | The reference reproduces small examples worked out from the MAR21-MAR23 formulas: correlation scenarios, GIRR tenor/curve/inflation/basis correlations, alternative `Sb`, other-sector buckets, CSR cross-bucket correlations, FX crosses, vega and curvature correlations and risk factors, curvature selection and `psi`, DRC JTD, maturity scaling, seniority netting, HBR, RRAO |
| Parameter spot check | `tests/test_vba_engine.py::test_parameter_sheets_match_regulatory_defaults` | The `P_*` sheets written by `M_Setup` equal an independently typed list in `tests/regulatory_defaults.py` |
| VBA engine reconciliation | `python3 -m pytest tests/test_vba_engine.py` | The VBA modules, executed headless in LibreOffice, reproduce every `Out_RiskClass`, `Out_Buckets`, `Out_Summary` and `Out_DRC` value of the independent Python reference, on the sample portfolio and on a variant with all discretions enabled and invalid rows, each of which must be logged; empty inputs give zero capital |
| In-workbook regression test | run inside the reconciliation tests | `Test_RunRegression` passes all 52 items embedded by `M_Setup` |
| Expected values current | `python3 tools/update_expected.py --check` | The values embedded in `M_Setup` equal the reference results for the sample |
| Template current | `python3 tools/build_template.py --check`, `tests/test_template.py` | The committed template equals a fresh build of the modules in values and layout (cell styles, number formats, column widths, row heights, merged ranges, tab colors, frozen panes, gridlines, autofilters), carries no VBA project, controls or personal properties, and a build from it passes the regression test and reconciles with the reference |

Run everything with:

```sh
python3 -m pip install -r tests/requirements.txt
python3 tools/vba_lint.py
REQUIRE_LIBREOFFICE=1 python3 -m pytest -v tests
```

LibreOffice Calc and the Python UNO bridge (`python3-uno` on Debian/Ubuntu)
are required for the reconciliation tests; without them those tests are
skipped unless `REQUIRE_LIBREOFFICE=1` is set. The `Prototype checks`
workflow runs the same commands on pull requests.

### How the LibreOffice run works

[`tools/lo_runner.py`](../tools/lo_runner.py) inserts the modules of
`src/modules` and `tests/modules` into an empty Calc document (or the
template) with `Option VBASupport 1`, calls a probe function appended to every module
(LibreOffice does not report compile errors otherwise), runs the requested
macros and saves the result as `.xlsx`.

<a id="not-validated"></a>

## ⚠️ Not validated

* **Excel compilation and runtime.** No check here runs Excel.
  LibreOffice's VBA support is not Excel's, and the lint is a heuristic, not
  a compiler. Build the workbook with `tools\Build-Workbook.ps1 -RunTests`,
  run **Debug → Compile VBAProject**, and record the result as manual
  evidence.
* **The build script** `tools/Build-Workbook.ps1` has not been executed.
* **Excel-only presentation**: buttons, autofilters, frozen panes, tab
  colors and conditional styling were checked only as rendered by
  LibreOffice; `Dev_ExportModules` and the message boxes were not run.
* **Regulatory correctness.** The reference and the VBA share the same
  reading of MAR21-MAR23, so their agreement does not prove that reading is
  right. The [BIS check](methodology.md#bis-check), the hand-calculated
  tests and the parameter spot checks tie both to the regulatory text as
  transcribed; the
  [open interpretations](methodology.md#interpretations-and-simplifications-to-review)
  still need a decision.
* **Real portfolios and performance.** Only the synthetic sample and small
  test cases have been run; the engine uses simple loops and has not been
  timed on large inputs.
