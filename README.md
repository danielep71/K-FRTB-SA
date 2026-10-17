# FTRB-SA-
Market risk FRTB standardised approach

## Prototype workbook

An Excel VBA prototype of the FRTB standardized approach (Basel MAR21-MAR23):

* sensitivities-based method (delta, vega, curvature) for GIRR, CSR
  non-securitization, equity, commodity and FX, under the low, medium and
  high correlation scenarios;
* default risk charge for non-securitizations;
* residual risk add-on.

CSR securitization, the correlation trading portfolio and securitization DRC
are not implemented. Parameters are editable defaults for review; results
are not validated for regulatory use.

The VBA modules in `src/vba` are the source of truth; the `.xlsm` is built
from them with `tools/Build-Workbook.ps1` on Windows with Excel.

* [Methodology](docs/methodology.md): formulas, parameters, interpretations to review
* [Workbook guide](docs/workbook-guide.md): build, sheets, inputs, running
* [Validation](docs/validation.md): automated checks and what is not validated
