# Validation

This page states what is checked automatically, how, and what is not
checked. Treat any result as unvalidated for regulatory use.

## Automated checks

| Check | Command | What it shows |
| --- | --- | --- |
| VBA static lint | `python3 tools/vba_lint.py` | `Option Explicit` and `VB_Name` in every module, no undeclared identifiers, no duplicate declarations, no cross-module use of private procedures, ASCII-only source |
| Hand-calculated tests | `python3 -m pytest tests/test_reference.py` | The reference reproduces small examples worked out from the MAR21-MAR23 formulas (correlation scenarios, GIRR tenor/curve/inflation/basis correlations, alternative `Sb`, other-sector buckets, vega maturity correlations, curvature selection and `psi`, DRC JTD, maturity scaling, seniority netting, HBR, RRAO) |
| Parameter spot check | `tests/test_vba_engine.py::test_parameter_sheets_match_regulatory_defaults` | The `P_*` sheets written by `modSetup` equal an independently typed list in `tests/regulatory_defaults.py` |
| VBA engine reconciliation | `python3 -m pytest tests/test_vba_engine.py` | The VBA modules, executed headless in LibreOffice, reproduce every `Out_RiskClass`, `Out_Buckets`, `Out_Summary` and `Out_DRC` value of the independent Python reference, on the sample portfolio and on a variant with all discretions enabled and invalid rows, each of which must be logged |
| In-workbook regression test | run inside the reconciliation tests | `RunRegressionTest` passes all 52 items embedded by `modSetup` |
| Expected values current | `python3 tools/update_expected.py --check` | The values embedded in `modSetup` equal the reference results for the sample |

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

[`tools/lo_runner.py`](../tools/lo_runner.py) inserts the modules into an
empty Calc document with `Option VBASupport 1`, calls a probe function
appended to every module (LibreOffice does not report compile errors
otherwise), runs the requested macros and saves the result as `.xlsx`.

## Not validated

* **Excel compilation and runtime.** No check here runs Excel.
  LibreOffice's VBA support is not Excel's, and the lint is a heuristic, not
  a compiler. Build the workbook with `tools\Build-Workbook.ps1 -RunTests`
  and record the result as manual evidence.
* **The build script** `tools/Build-Workbook.ps1` has not been executed.
* **Excel-only features**: buttons on `Control`, cell formatting,
  `Dev_ExportModules`, message boxes.
* **Regulatory correctness.** The reference and the VBA share the same
  reading of MAR21-MAR23, so their agreement does not prove that reading is
  right. The hand-calculated tests and parameter spot checks tie both to the
  formulas and values as transcribed; review those transcriptions and the
  [interpretations](methodology.md#interpretations-and-simplifications-to-review)
  against the applicable regulatory text.
* **Real portfolios and performance.** Only the synthetic sample and small
  test cases have been run; the engine uses simple loops and has not been
  timed on large inputs.
