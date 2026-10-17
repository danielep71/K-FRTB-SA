# FRTB-SA

A market risk project intended to support transparent implementation,
benchmarking, and validation of the **Fundamental Review of the Trading Book
standardized approach (FRTB-SA)**.

**Status: repository setup in progress.** The current milestone,
[v0.0.1 — Repo setup](https://github.com/danielep71/MKT-FTRB-SA/milestone/1),
prepares the repository and its development controls. There is no calculation
engine, supported workbook, or published functional release yet.

## Purpose and audience

The project is intended for market risk practitioners, model developers,
validators, researchers, and educators who need calculations that can be
traced to their inputs, assumptions, source provisions, and independent tests.
The immediate objective is to establish a maintainable foundation before
implementing those calculations.

| Area | Current status |
| --- | --- |
| Label catalogue, reconciliation, and drift detection | Implemented |
| Repository protection and security baseline | Configured; remaining dependencies tracked in issue #2 |
| Source/test structure, contribution workflow, and universal integrity gate | Setup work in progress |
| Sensitivities-based method (SBM) | Planned; not implemented |
| Default risk charge (DRC) | Planned; not implemented |
| Residual risk add-on (RRAO) | Planned; not implemented |
| Independent calculation benchmarks and runtime evidence | Planned; no engine results available |

See [scope and decisions](docs/SCOPE.md) for boundaries and
[the roadmap](docs/ROADMAP.md) for the proposed development sequence.

## Getting started

Clone the repository and read the current documentation:

```sh
git clone https://github.com/danielep71/MKT-FTRB-SA.git
cd MKT-FTRB-SA
```

The existing label tools use Node.js with built-in fetch support and require
no npm packages. These local checks validate the label configuration and
exercise offline fixtures; they do not change GitHub labels:

```sh
node .github/scripts/labels-sync.mjs --self-test
node .github/scripts/labels-sync.mjs --mode validate
node .github/scripts/labels-drift.mjs --self-test
```

There is currently no engine installation or calculation command. The engine's
implementation platform and supported runtime environment remain to be
approved. The Node.js maintenance tools do not determine that platform.
All development targets **`release/v0.0.1`**. Create a task branch from it and
open the task PR against it; main remains the stable default branch.
See [branch governance](docs/GOVERNANCE.md) for the integration procedure.

## Documentation and project tracking

| Need | Start here |
| --- | --- |
| Functional scope, platform decisions, and validation policy | [Scope](docs/SCOPE.md) |
| Setup work and proposed functional phases | [Roadmap](docs/ROADMAP.md) |
| Label usage, issue priorities, and metadata checks | [Labels and triage](docs/LABELS.md) |
| How to contribute | [Contributing](CONTRIBUTING.md) |
| Detailed setup purpose and completion criteria | [v0.0.1 guide](docs/Milestones/v0.0.1.md) |
| Development branches and integration | [Governance](docs/GOVERNANCE.md) |
| Effective repository controls and outstanding settings work | [Settings baseline](docs/REPOSITORY_SETTINGS.md) |
| Recorded changes | [Changelog](CHANGELOG.md) |
| Setup backlog | [v0.0.1 milestone](https://github.com/danielep71/MKT-FTRB-SA/milestone/1) |
| Privately report a potential vulnerability | [Private vulnerability reporting](https://github.com/danielep71/MKT-FTRB-SA/security/advisories/new) |

Every issue must have **one priority label**, a milestone, and an assignee.
Setup work normally uses P3; P1 is reserved for confirmed calculation bugs.
Keep examples and contributed datasets synthetic. Do not submit client,
counterparty, position, or credential data in issues, PRs, or repository files.

## Regulatory basis and evidence

The planned methodology will distinguish the Basel standard from any
jurisdiction-specific implementation. Each implemented rule will need a
versioned source reference and explicit applicability assumptions. A link to
a regulation is not proof that an implementation matches it.

[Scope](docs/SCOPE.md#source-and-validation-policy) defines the source and
independent-validation policy. Current automated checks cover repository
maintenance only. This setup stage makes no claim of regulatory compliance,
verified capital calculations, or production readiness.

## Project name

The documentation uses **FRTB-SA**, with the standard acronym FRTB. The existing
GitHub repository identifier is **MKT-FTRB-SA**, which transposes the letters
in FRTB. That identifier is retained for URL and clone-path continuity; no
repository rename is part of this setup work.

## License and provenance

Original project material is distributed under the [MIT License](LICENSE).
The label configuration, scripts, and workflows adapted from
[VBA-SACCR-Toolkit](https://github.com/danielep71/VBA-SACCR-Toolkit) retain
Mozilla Public License 2.0 coverage as listed in
[third-party notices](.github/THIRD_PARTY_NOTICES.md), with the
[license text](.github/LICENSE-MPL-2.0.txt) included.

Maintained by [Daniele Penza](https://github.com/danielep71).
