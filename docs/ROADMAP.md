# Roadmap

This roadmap records the milestone plan the owner approved on October 18, 2026,
from the repository setup to the first certified release. Milestones carry no
dates or release promises. Each milestone after v0.2.0 is created on GitHub
when its predecessor has fixed its scope, as [governance](GOVERNANCE.md)
requires; the issue tracker is authoritative for current progress.

## 🗺️ Milestone plan

| Milestone | Objective | Exit condition |
| --- | --- | --- |
| ✅ v0.0.1 — Repo setup | Repository foundations: governance, protections, CI, issue management and the release procedure | Required checks active and release procedure verified; analytics kept separate from the certification path. Closed October 18, 2026 |
| 🧪 v0.1.0 — SA prototype | Consolidate the existing prototype: SBM for the five implemented risk classes, non-securitization DRC and RRAO | Excel build and run documented, sample reconciliation, source round trip verified and limits stated explicitly |
| 📐 v0.2.0 — Regulatory baseline and certification scope | Fix exactly what will be certified: standard and version, any CRR profile, included products, exclusions and interpretations | Approved requirement → source → formula → parameter → test matrix; the methodology decisions the scope needs are resolved; the meaning of certification, the validator's role, the target platform and the supported Excel environments are recorded |
| ⚙️ v0.3.0 — Calculation engine completion | Complete and correct the engine for the approved scope, progressively separating calculation from worksheet access | Every included requirement implemented with independently derived expected values, input/output contracts defined and no known calculation defect open |
| 🗂️ v0.4.0 — Workbook and user workflow | Guided workbook use: inputs, parameters, default restore, run, diagnostics and results | Full flow verified in Excel; understandable errors, no stale results, safe application state and documented handling of confidential portfolio data |
| 🔍 v0.5.0 — Independent validation | Validate formulas, parameters and results through a review independent of the implementation | Intermediate and final results reconciled, official cases where available, independently derived cases, and anomalies resolved or formally excluded from scope |
| 🛡️ v0.6.0 — Operational hardening | Robustness, performance and compatibility on the supported Excel environments | Malformed inputs, representative portfolios, repeated runs, error recovery and agreed run times all pass |
| 📦 v0.9.0 — Release candidate and certification dossier | Freeze the candidate and prepare the certification dossier | Rebuildable package, updated manual and limits, full regression suite on the candidate and final review complete; any later change needs the relevant checks again |
| 🏁 v1.0.0 — First certified release | Approve and publish the first certified version | Methodological, numerical and technical approval on the same commit and workbook; tag, package (rebuildable from template and sources, with recorded digests), evidence and release notes consistent |

v0.7.0 and v0.8.0 are reserved for iterations the hardening or validation
work may require. Independent expected values accompany every calculation
increment from v0.3.0 onward; v0.5.0 is the formal review by someone other than
the implementer, not the first check. Every milestone names its own Excel
evidence, which only a Windows desktop Excel host can produce. Versions,
tags and release evidence follow [Releasing](../RELEASING.md).

## ✅ v0.0.1 — Repo setup (closed)

[Milestone](https://github.com/danielep71/MKT-FTRB-SA/milestone/1) ·
[milestone guide](Milestones/v0.0.1.md) ·
[closeout record](evidence/2026-10-18-setup-closeout.md)

| Issue | Deliverable |
| --- | --- |
| [#1](https://github.com/danielep71/MKT-FTRB-SA/issues/1) | Canonical labels, safe reconciliation, drift detection, and triage rules |
| [#2](https://github.com/danielep71/MKT-FTRB-SA/issues/2) | Effective GitHub settings, protection, security, required check and review verification |
| [#3](https://github.com/danielep71/MKT-FTRB-SA/issues/3) | Project identity, accurate scope, navigation, and starting instructions |
| [#4](https://github.com/danielep71/MKT-FTRB-SA/issues/4) | Governance, integration branches, contribution rules, and milestone guide |
| [#5](https://github.com/danielep71/MKT-FTRB-SA/issues/5) | Minimal source, test, documentation, and tooling structure |
| [#6](https://github.com/danielep71/MKT-FTRB-SA/issues/6) | Issue forms, PR template, and contribution/security policies |
| [#7](https://github.com/danielep71/MKT-FTRB-SA/issues/7) | Universal repository-integrity checks and dependency updates |
| [#8](https://github.com/danielep71/MKT-FTRB-SA/issues/8) | Release procedure and evidence-based setup closeout |
| [#23](https://github.com/danielep71/MKT-FTRB-SA/issues/23) | Traffic history: protected data branch and daily collection |
| [#25](https://github.com/danielep71/MKT-FTRB-SA/issues/25) | Label pruning guard |

The milestone closed without a tag or release. No main commit is both
setup-only and complete, so the closed milestone and the closeout record are
the setup baseline.

## 🧪 v0.1.0 — SA prototype

[Live milestone](https://github.com/danielep71/MKT-FTRB-SA/milestone/2),
integration branch `release/v0.1.0`.

| Issue | State | Deliverable |
| --- | --- | --- |
| [#20](https://github.com/danielep71/MKT-FTRB-SA/issues/20) | Open | Excel VBA workbook prototype: SBM (delta, vega, curvature) for five risk classes, DRC non-securitization, RRAO, independent Python reference and reconciliation |
| [#28](https://github.com/danielep71/MKT-FTRB-SA/issues/28) | Open | Excel host build, compile, execution and evidence |
| [#30](https://github.com/danielep71/MKT-FTRB-SA/issues/30) | Open | Committed template and modules layout; remaining Excel round trip |
| [#32](https://github.com/danielep71/MKT-FTRB-SA/issues/32) | Open | Milestone guide, evaluation and evidence closeout |
| [#59](https://github.com/danielep71/MKT-FTRB-SA/issues/59) | Open | Post-closeout documentation consistency |
| [#31](https://github.com/danielep71/MKT-FTRB-SA/issues/31) | Closed | Bring `release/v0.1.0` up to date with main and reconcile governance |
| [#40](https://github.com/danielep71/MKT-FTRB-SA/issues/40) | Closed | Remaining prototype documentation inconsistencies |
| [#41](https://github.com/danielep71/MKT-FTRB-SA/issues/41) | Closed | Reject invalid required parameters; consistent numeric-text parsing |
| [#45](https://github.com/danielep71/MKT-FTRB-SA/issues/45) | Closed | Reject blank or invalid parameter-table values and vertex lists; clear outputs on failure |
| [#48](https://github.com/danielep71/MKT-FTRB-SA/issues/48) | Closed | Reject blank keys and gaps in required parameter tables |
| [#51](https://github.com/danielep71/MKT-FTRB-SA/issues/51) | Closed | Retire the setup line: Dependabot targets and branch guidance |
| [#55](https://github.com/danielep71/MKT-FTRB-SA/issues/55) | Closed | This milestone plan |

States were read back on October 18, 2026; the live milestone is authoritative.

The open methodology interpretations are documented as limits in the
[methodology](methodology.md); deciding them ([#29](https://github.com/danielep71/MKT-FTRB-SA/issues/29))
belongs to v0.2.0. The prototype informs the v0.2.0 scope and platform
decisions; it does not complete the later milestones' exit conditions.
