# 🧩 Production Source

`src/` holds the production VBA source: the only input from which the
K-FRTB-SA workbook is built. The layout follows VBA-SACCR-Toolkit and is
described in the [workbook guide](../docs/workbook-guide.md#source-of-truth).

- `core/CORE_Config.bas`: product name, sheet names, layout, palette and the
  risk class, component and scenario codes;
- `core/CORE_Util.bas`: sheet access, tagged parameter tables, conversions,
  table formatting and the run log;
- `core/CORE_Params.bas`: loading of the Control settings and `P_*`
  parameters, and the risk weight and correlation accessors;
- `core/CORE_SBM.bas`: the sensitivities-based method (delta, vega,
  curvature) under the three correlation scenarios;
- `core/CORE_DRC.bas`: the default risk charge for non-securitizations;
- `core/CORE_RRAO.bas`: the residual risk add-on;
- `workbook/M_Main.bas`: the sheet-button macros and automation entry points,
  and the Results and Out_Summary reports;
- `workbook/M_Setup.bas`: the workbook builder (sheets, palette, parameters,
  sample portfolio, expected results);
- `workbook/M_Dev.bas`: the export of the modules back to the repository.

Core modules declare `Option Private Module`. The engine does not yet keep
core free of worksheet access: `CORE_Util`, `CORE_SBM`, `CORE_DRC` and
`CORE_RRAO` read the input sheets and write the output sheets, as the engine
of VBA-SACCR-Toolkit did when it was imported from its prototype.

Do not place tests, examples, built workbooks or generated output here.
