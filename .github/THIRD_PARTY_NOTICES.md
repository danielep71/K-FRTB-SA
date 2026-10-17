# Repository configuration and label tooling provenance and license

The following files are copied or adapted from
[danielep71/VBA-SACCR-Toolkit](https://github.com/danielep71/VBA-SACCR-Toolkit/tree/54fc4812ac8c4698ec44a0aebfe8a1c319dd1ffe)
at commit `54fc4812ac8c4698ec44a0aebfe8a1c319dd1ffe`:

- `.editorconfig`
- `.gitignore`
- `.gitattributes`
- `.github/labels.json`
- `.github/label-policy.json`
- `.github/scripts/labels-sync.mjs`
- `.github/scripts/labels-drift.mjs`
- `.github/workflows/labels-sync.yml`
- `.github/workflows/labels-drift.yml`

These files remain covered by the **Mozilla Public License 2.0**. The full
license is available in [LICENSE-MPL-2.0.txt](LICENSE-MPL-2.0.txt). Source and
modifications are available in this repository. The root MIT license continues
to apply to the project's original files; it does not relicense these files.

Changes: the script defaults select this repository's label-policy file;
workflow path filters cover both scripts; trusted reconciliation retains
before/after snapshots and a post-sync drift report. The catalogue is unchanged.

The root `.editorconfig` and `.gitattributes` are copied unchanged. The root
`.gitignore` replaces the SACCR-specific workbook exception and its issue #58
reference with the approved `/src/workbook/FRTB_Template.xlsx` exception;
all other ignore rules are unchanged.
