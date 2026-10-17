# Changelog

Record user-visible and maintainer-visible changes here. Entries under
Unreleased describe integrated work, not a published version.

## [Unreleased]

### Added

- Excel VBA workbook prototype of the FRTB standardized approach (Basel
  MAR21-MAR23): SBM delta, vega and curvature for GIRR, CSR
  non-securitization, equity, commodity and FX under three correlation
  scenarios; DRC for non-securitizations; RRAO. Exported source under
  `src/core`, `src/workbook` and `tests/modules`, a code-built workbook with
  editable parameter sheets checked against the BIS text, an independent
  Python reference reconciled with the VBA run in LibreOffice, a static VBA
  lint, the `Prototype checks` workflow, methodology, workbook guide and
  validation record. Not yet compiled or run in Excel (#20).

- Integration branch `release/v0.1.0` for the SA prototype milestone (#20).

- Macro-free workbook template `src/workbook/FRTB_Template.xlsx`, generated
  from the modules by `tools/build_template.py` and checked by
  `tests/test_template.py`; Excel builds start from it and
  `M_Setup.FinishWorkbook` adds buttons and window settings (#30).

### Changed

- All prototype VBA modules moved from `src/core` and `src/workbook` to
  `src/modules`; `src/workbook` now holds only the template (#30).

- Purposeful source, tests, documentation, tooling, and workbook-reservation
  READMEs; repository structure, source/generated-file and evidence policies,
  conditional VBA round-trip requirements, and local setup instructions (#5).

- Contribution walkthrough, detailed v0.0.1 milestone guide, triage and
  closeout procedures, integration verification, and a distinction between
  enforced controls and maintainer procedures (#4).

- Repository editing, ignore, and Git attribute policies, including the approved
  `src/workbook/FRTB_Template.xlsx` path (#5).

- Owner-selected integration branch `release/v0.0.1`, branch governance and
  agent instructions: all task PRs target the release branch; integration
  into main uses a separate owner-requested merge-commit PR (#4).

- Canonical 20-label catalogue, trusted synchronization, read-only drift
  detection, retained evidence, and issue-triage guidance (#1, PR #9).
- Documented repository settings baseline and pending setup dependencies
  (#2, PR #10).
- Project purpose, implementation-status table, scope and decision register,
  source/validation policy, roadmap, and current getting-started commands (#3).

### Changed

- Repository files consistently use the MIT license; removed external-project
  references and superseded license files at the owner's request (#5).

- GitHub About description and topics identify the FRTB-SA project and its
  setup-stage maturity (#3).
- Main, release branches, and version tags have active protection rules;
  workflow action SHA pinning and the available public-repository security
  controls are enabled. The required integrity gate and remaining dependencies
  stay tracked in #2.
- Documentation uses the correct display name FRTB-SA while retaining the
  existing MKT-FTRB-SA repository identifier and URLs (#3).

No functional release has been published. SBM, DRC, and RRAO remain planned;
no engine results or regulatory certification are claimed.
