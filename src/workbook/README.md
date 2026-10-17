# 🧾 Workbook source

This directory holds the workbook glue of the v0.1.0 prototype: `M_Main`
(sheet-button macros), `M_Setup` (workbook builder) and `M_Dev` (export back
to the repository). See the [workbook guide](../../docs/workbook-guide.md).

## Template reservation

The owner approved the exact trackable path
`src/workbook/FRTB_Template.xlsx`. The file does not exist yet.
Other workbook names, paths, and macro-enabled variants remain ignored.

The prototype builds every sheet from source (`M_Setup.BuildWorkbook`), a
documented deviation from the template-based build in
[Repository structure](../../docs/REPOSITORY_STRUCTURE.md#conditional-excelvba-policy).
`tools/Build-Workbook.ps1 -Template` saves a macro-free template built in
Excel; committing it here needs an issue explaining its sheets, names,
formulas, synthetic content, and build/synchronization role.
