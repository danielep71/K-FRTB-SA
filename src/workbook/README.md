# 🧾 Workbook template

`FRTB_Template.xlsx` is the macro-free template of the K-FRTB-SA prototype,
at the owner-approved path. It is the workbook that `M_Setup.BuildWorkbook`
produces from [`src/modules`](../modules), saved without a VBA project,
sheet buttons or personal document properties. Other workbook names, paths,
and macro-enabled variants remain ignored.

| Content | Detail |
| --- | --- |
| Sheets | README, Control, Results, In_Delta, In_Vega, In_Curvature, In_DRC, In_RRAO, Out_Summary, Out_RiskClass, Out_Buckets, Out_DRC, Log, P_General, P_GIRR, P_CSR, P_EQ, P_COM, P_FX, P_DRC, P_RRAO, Test_Expected |
| Formulas and names | None: every value is written by `M_Setup`; the engine reads tagged tables, not workbook names |
| Data | Default Basel MAR21-MAR23 parameters, the synthetic sample portfolio and the expected regression results; no real portfolio data |
| Not included | VBA, calculation results, and the buttons, tab colors, frozen panes and hidden gridlines that `M_Setup.FinishWorkbook` adds at build time |

Never edit the template by hand. Change `src/modules` and regenerate it with
`python3 tools/build_template.py` (LibreOffice, used for the committed file)
or compare with `tools\Build-Workbook.ps1 -Template` (Excel).
`tests/test_template.py` fails when the committed file differs from a fresh
build. See the [workbook guide](../../docs/workbook-guide.md) and
[repository structure](../../docs/REPOSITORY_STRUCTURE.md).
