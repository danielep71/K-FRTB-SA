# Changelog

Record user-visible and maintainer-visible changes here. Entries under
Unreleased describe integrated work, not a published version.

## [Unreleased]

### Fixed

- Required numeric parameters fail with key/source context instead of using
  zero for invalid text. Validation and conversion share a full invariant
  dot-decimal/scientific grammar; comma/grouped/junk/overflow text is rejected
  while actual numeric cells retain their value (#41, PR #39 review).

- Label pruning now checks issue/PR associations against the validated,
  policy-resolved reconciliation plan, respecting selected overlays and
  `prune: false`. Used-label protection also applies to direct CLI runs;
  offline regression fixtures cover the guard without live deletions, including
  exact matching and bounded association scans for comma-containing names (#25).
- Prototype documentation consistency: the v0.1.0 roadmap table renders as
  one table, the repository settings describe both integration branches, and
  the source, template, validation and workbook guides match the lint rules,
  CI triggers, build-time window settings and core worksheet access. Module
  comments in `M_Main`, `M_Setup` and `CORE_Util` were corrected; no code
  changed (#40).

### Added

- Excel/VBA SA prototype (#20/#22): SBM for five risk classes, DRC
  non-securitization and RRAO; independent Python reference, LibreOffice
  reconciliation and methodology/workbook/validation documentation. Excel
  host evidence remains pending (#28).
- Committed macro-free template and template-based builds; production and
  workbook modules under `src/modules`, with test modules under
  `tests/modules` (#30/#34). Generated `.xlsm` workbooks remain local.
- Owner-approved prototype integration branch `release/v0.1.0` alongside
  `release/v0.0.1` for setup.


- Universal Repository integrity check for ordinary PRs and pushes to main
  and release branches; one local entry point for configuration, tracked
  whitespace, local documentation targets and existing maintenance tests.
  Weekly Dependabot version updates cover Actions on both integration lines,
  the CI parser and the existing prototype test packages (#7).

- Owner-requested persistent traffic-history branch, daily/manual main-only
  collection, offline tooling checks, operational documentation, and an
  explicit analytics credential/first-run prerequisite (#23). The collector
  rejects malformed rows and existing empty history before publication.

- Bug, feature, and documentation issue forms with owner/type/priority defaults;
  one PR merge checklist; conduct and security policies with reporting routes;
  default-branch activation and manual milestone triage guidance (#6).
- Navigation glyphs and descriptive MIT/setup/development badges on the
  project entry points and new participation policies.

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

- Synchronized main setup controls into the prototype line, preserving its
  template and module layout. Shared guidance and forms describe both active
  milestones; prototype tests install the separate CI parser dependency (#31).


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

No functional release has been published. Prototype LibreOffice results and
independent reconciliation are recorded; Excel execution and regulatory
certification are not claimed.
