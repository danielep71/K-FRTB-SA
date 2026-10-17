# Scope and project decisions

## Current stage

FRTB-SA is at the repository setup stage. Existing files provide label tooling,
documentation, and repository controls. They do not contain a market risk
calculation engine. v0.0.1 is a setup milestone, not a functional release or
an implementation of a regulatory framework.

The intended outcome is a transparent, testable implementation that supports
market risk analysis and independent validation. Proposed users include risk
practitioners, developers, validators, researchers, and educators.

## Planned functional coverage

| Workstream | Intended scope | Current boundary |
| --- | --- | --- |
| SBM | Sensitivity inputs, risk classification, weighting, correlations, and aggregation, including delta, vega, and curvature where applicable | No formulas, risk-class coverage, or input conventions implemented |
| DRC | Explicit default-risk inputs, classification, netting, weighting, and aggregation | Instrument coverage and treatment decisions remain to be specified |
| RRAO | Explicit eligibility/classification rules, input data, and add-on calculation | No eligibility rules or calculation implemented |
| Reconciliation and validation | Traceable intermediate results, independent expected values, and reproducible evidence | No engine outputs or benchmark claims |

This table describes intentions, not promised coverage. Each workstream must
be decomposed into issues with observable input/output contracts and evidence
requirements before implementation. Instrument and risk-class coverage must
be documented incrementally rather than presented as complete from the start.

## Platform and environment

**Decision pending: the engine implementation platform has not been approved.**
Do not infer Excel/VBA support from repository file-type conventions or the
reserved workbook-template path. Excel/VBA, operating-system support, workbook/add-in packaging, and
any other engine runtime remain uncommitted until an architecture decision is
recorded. There is currently no supported engine environment or distributable.

The maintenance scripts already in the repository run with Node.js and its
built-in fetch support. They have no npm dependencies. These scripts manage
repository labels; they are not a prototype of the calculation engine.

| Decision needed before functional implementation | Required record |
| --- | --- |
| Engine language, runtime, and supported platforms | Architecture decision with rationale and setup instructions |
| Basel baseline and initial jurisdiction profile | Versioned applicability/source register |
| Initial products and risk classes | Explicit coverage matrix and excluded cases |
| Inputs, units, signs, identifiers, and outputs | Reviewed data contract and validation behavior |
| Expected-value provenance and tolerances | Independently derived benchmark catalogue |
| Runtime evidence and release packaging | Reproducible execution and release procedure |

The [setup structure](REPOSITORY_STRUCTURE.md) defines source/test/tool
boundaries without selecting a runtime. [Governance](GOVERNANCE.md) establishes
`release/v0.0.1` as the integration branch and owns the contribution model.
The owner created [v0.1.0 - SA prototype](https://github.com/danielep71/MKT-FTRB-SA/milestone/2)
for subsequent prototype work; its platform and coverage decisions remain open.
Until they are made, structure work must not imply unsupported runtime capability.

At the owner's request, the v0.1.0 prototype (issue #20) is written in
Excel/VBA, built from exported source, to evaluate that approach. It covers
SBM for GIRR, CSR non-securitization, equity, commodity and FX, DRC for
non-securitizations and RRAO, following the Basel MAR21-MAR23 baseline
recorded in the [methodology](methodology.md). This is a prototype scope,
not the architecture decision: Excel runtime evidence is still missing, and
the open interpretations listed in the methodology still need decisions.

## Source and validation policy

Start from primary sources and distinguish their roles:

- The [BIS Basel Framework market risk standard](https://www.bis.org/committees/bcbs/basel-framework/standard/mar)
  provides the Basel reference structure. MAR20 covers the standardized
  approach structure, MAR21 the sensitivities-based method, MAR22 default
  risk, and MAR23 the residual risk add-on.
- [EUR-Lex's January 1, 2026 consolidated CRR text](https://eur-lex.europa.eu/eli/reg/2013/575/2026-01-01/eng)
  is an initial EU research reference, not a selected implementation baseline
  or a statement that all provisions apply on the same date. Review the
  underlying Official Journal acts, amendments, delegated/implementing acts,
  and applicable transition dates when defining an EU profile.

These reference entry points were checked on October 17, 2026. Their presence
does not establish the project's regulatory applicability or completeness.

Before implementing a rule, record its issuer, title, direct URL, chapter or
article, publication/version date, effective/application date, retrieval date,
profile, and interpretation assumptions. Retain amendment history and map
implemented behavior to specific source provisions. Keep Basel and
jurisdiction profiles explicit; do not silently mix parameters or assumptions
from different versions or regimes. Resolve material interpretation questions
before marking the corresponding calculation complete.

Expected results must come from published examples or a separately derived
calculation with documented independence. Never obtain the expected value by
running the implementation under test. Define intermediate checks, units,
tolerances, edge cases, rejected inputs, and provenance before asserting a
benchmark passes. Tie execution evidence to the exact reviewed source.

Distinguish static checks, actual runtime execution, independent numerical
comparison, and methodology review. A passing repository workflow does not
establish correct capital calculations. Future releases must state which of
these activities were performed and which remain incomplete.

## Data and use boundaries

Use synthetic datasets and examples only. Do not commit client portfolios,
real counterparty identifiers, confidential positions, credentials, or
production exports. Future fixtures must document their origin and usage
rights. A regulatory example must be cited and its redistribution conditions
respected.

The current setup provides no calculation service and supports no regulatory
reporting or production capital determination. Internal-model calculations,
pricing engines, live market-data ingestion, regulatory reporting templates,
and website publication are outside the present setup scope. Additional
capabilities require their own explicit scope and validation work.
