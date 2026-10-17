# Roadmap

This roadmap separates the existing setup milestone from proposed functional
phases. Phases below v0.0.1 have no assigned version, date, or release promise;
create their milestones only after the owner approves scope and dependencies.

## v0.0.1 — Repository setup

[Live milestone](https://github.com/danielep71/MKT-FTRB-SA/milestone/1).
The [detailed milestone guide](Milestones/v0.0.1.md) explains purpose,
dependencies, entry/exit criteria, and evidence. The issue tracker is
authoritative for current progress.

| Issue | Deliverable |
| --- | --- |
| [#1](https://github.com/danielep71/MKT-FTRB-SA/issues/1) | Canonical labels, safe reconciliation, drift detection, and triage rules |
| [#2](https://github.com/danielep71/MKT-FTRB-SA/issues/2) | Effective GitHub settings, protection, security, and verification |
| [#3](https://github.com/danielep71/MKT-FTRB-SA/issues/3) | Project identity, accurate scope, navigation, and starting instructions |
| [#4](https://github.com/danielep71/MKT-FTRB-SA/issues/4) | Governance, active integration branch, contribution rules, and milestone guide |
| [#5](https://github.com/danielep71/MKT-FTRB-SA/issues/5) | Minimal source, test, documentation, and tooling structure |
| [#6](https://github.com/danielep71/MKT-FTRB-SA/issues/6) | Issue forms, PR template, and contribution/security policies |
| [#7](https://github.com/danielep71/MKT-FTRB-SA/issues/7) | Universal repository-integrity checks and dependency updates |
| [#8](https://github.com/danielep71/MKT-FTRB-SA/issues/8) | Release baseline and evidence-based setup closeout |

Exit criteria belong to #8. Closing this milestone does not publish a release,
create a version tag, establish an approved engine platform, or certify an
FRTB-SA implementation.

## v0.1.0 — SA prototype

[Live milestone](https://github.com/danielep71/MKT-FTRB-SA/milestone/2),
integration branch `release/v0.1.0`.

| Issue | Deliverable |
| --- | --- |
| [#20](https://github.com/danielep71/MKT-FTRB-SA/issues/20) | Excel VBA workbook prototype: SBM (delta, vega, curvature) for five risk classes, DRC non-securitization, RRAO, independent Python reference and reconciliation |

The prototype explores phases 1-4 below in one pass to inform the
architecture decision; it does not complete their gates.

## Proposed functional phases

| Sequence | Intended result | Gate before completion |
| --- | --- | --- |
| 1. Architecture and methodology baseline | Approved platform, regulatory profile, initial coverage, and data contracts | Recorded decisions and independently specified benchmark cases |
| 2. First complete calculation slice | A narrowly specified product/risk-class scope through inputs, computation, intermediate results, and outputs | Actual runtime execution and independent expected-value comparison |
| 3. Incremental SBM coverage | Extend approved risk-class coverage and applicable delta, vega, and curvature treatment | Explicit coverage matrix, edge cases, and regression evidence per increment |
| 4. DRC and RRAO | Implement separately scoped default-risk and residual-risk workstreams | Source mappings, eligibility/netting decisions, and independent benchmarks |
| 5. Reconciliation and release readiness | Reproducible execution, diagnostics, user guidance, packaging, and stated limitations | Reviewed methodology, exact-source evidence, green checks, and owner release decision |

Independent expected values and validation begin with phase 1 and accompany
every calculation increment; phase 5 consolidates the evidence rather than
postponing validation until the end. Sequence and boundaries remain proposals
until functional issues are approved. There is no committed implementation
schedule.
