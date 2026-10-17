# 🧩 Production source

This directory is the production-source boundary. It holds the exported VBA
of the v0.1.0 prototype (issue #20) and the [workbook reservation](workbook/README.md).
The prototype uses Excel/VBA to evaluate the approach; it is not the platform
decision, which stays open in [Scope](../docs/SCOPE.md).

[Repository structure](../docs/REPOSITORY_STRUCTURE.md) owns placement and the
source-of-truth policy; the [workbook guide](../docs/workbook-guide.md) owns
the module layout, build and sheet conventions.

| Path | Content |
| --- | --- |
| `core/CORE_Config.bas` | Product name, sheet names, layout, palette and the risk class, component and scenario codes |
| `core/CORE_Util.bas` | Sheet access, tagged parameter tables, conversions, table formatting and the run log |
| `core/CORE_Params.bas` | Loading of the Control settings and `P_*` parameters; risk weight and correlation accessors |
| `core/CORE_SBM.bas` | Sensitivities-based method (delta, vega, curvature) under the three correlation scenarios |
| `core/CORE_DRC.bas` | Default risk charge for non-securitizations |
| `core/CORE_RRAO.bas` | Residual risk add-on |
| `workbook/M_Main.bas` | Sheet-button macros and automation entry points; Results and Out_Summary reports |
| `workbook/M_Setup.bas` | Workbook builder: sheets, palette, parameters, sample portfolio, expected results |
| `workbook/M_Dev.bas` | Export of the modules back to the repository |

Core modules declare `Option Private Module`. Known deviation: `CORE_Util`,
`CORE_SBM`, `CORE_DRC` and `CORE_RRAO` read the input sheets and write the
output sheets, so core is not yet free of worksheet access.

Keep test code under `tests/` and maintenance logic under `tools/` or the
existing `.github/scripts/`. Workbook binaries must never be the only source
record.
