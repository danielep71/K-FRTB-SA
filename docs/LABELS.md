# Issue labels and triage

The versioned catalogue in [labels.json](../.github/labels.json) is the source
of truth for the names, descriptions and colors of the 20 core labels. [label-policy.json](../.github/label-policy.json) selects the
application profile with no domain overlays.

## Metadata rules

Every development issue, including issues opened through the API and closed
issues, must have:

- Assignee `danielep71`.
- Exactly one priority: `P1`, `P2` or `P3`.
- The milestone that owns its work; setup work belongs to **v0.0.1 - Repo setup**.
- An objective, acceptance checklist, dependencies and required evidence.

The owner's triage convention reserves **P1 for confirmed calculation bugs**.
P2 covers material defects in correctness, robustness or maintainability. P3
covers setup, documentation, testing and other non-blocking quality work.
The shared P1 catalogue description is retained verbatim for cross-repository
alignment; it does not override this narrower assignment rule.

| Label | Use |
| --- | --- |
| `bug` | Confirmed defect in behavior or a documented contract |
| `enhancement` | New capability or meaningful improvement |
| `documentation` | User or maintainer documentation |
| `tests` | Test coverage, fixtures or manual validation |
| `refactor` | Internal restructuring that preserves behavior |
| `behavior-change` | Intentional externally observable behavior change |
| `ci` | Automated checks, workflows or certification |
| `repository` | Structure, governance, metadata or tooling |
| `release` | Release preparation, evidence or packaging |
| `security` | Disclosed security work or supply-chain hardening |
| `blocked` | Work cannot proceed until a named dependency is resolved |
| `question` | Information or a maintainer decision is needed |
| `help wanted` | External contributions or investigation are welcome |
| `good first issue` | A bounded task suitable for a first contribution |
| `duplicate` | Another issue or PR already covers the work |
| `invalid` | The report is unsupported, incomplete or not actionable |
| `wontfix` | Maintainer has decided not to proceed |

Type and status labels may be combined; priority labels may not. Setup issues
normally carry `repository` and `P3`, plus applicable type labels. A blocked
issue must name its dependency in the body. Before closing, link the merged PR,
applicable green checks and any required runtime evidence; only mark acceptance
checkboxes complete when that evidence exists.

These are **manual triage rules**, not automatic issue-metadata enforcement.
The label workflows manage the catalogue only: they do not assign issues,
choose priorities or milestones, or close issues. The bug form defaults to
P2, and feature/documentation forms to P3; all assign danielep71. Milestones
and metadata confirmation remain manual, and API-created issues bypass form
defaults. [Governance](GOVERNANCE.md) explains default-branch activation and
the contribution workflow; issue #6 tracks live activation verification.

## Reusable triage searches

Run these repository-wide, without `is:open` or a milestone filter, so closed
issues and orphaned issues remain visible. Every search should return no issues.

| Check | GitHub search query |
| --- | --- |
| Missing assignee | `repo:danielep71/MKT-FTRB-SA is:issue no:assignee` |
| Wrong owner | `repo:danielep71/MKT-FTRB-SA is:issue -assignee:danielep71` |
| Missing milestone | `repo:danielep71/MKT-FTRB-SA is:issue no:milestone` |
| Missing priority | `repo:danielep71/MKT-FTRB-SA is:issue -label:P1 -label:P2 -label:P3` |
| Conflicting priorities | `repo:danielep71/MKT-FTRB-SA is:issue label:P1 label:P2` |
| Conflicting priorities | `repo:danielep71/MKT-FTRB-SA is:issue label:P1 label:P3` |
| Conflicting priorities | `repo:danielep71/MKT-FTRB-SA is:issue label:P2 label:P3` |

Review P1 issues individually to confirm a calculation bug is established;
a search cannot verify the substance of that decision.

## Validation and reconciliation

Requires Node.js with built-in `fetch` support; no npm dependencies are needed.
Run from the repository root:

```sh
node .github/scripts/labels-sync.mjs --self-test
node .github/scripts/labels-sync.mjs --mode validate
node .github/scripts/labels-drift.mjs --self-test
```

**Sync issue labels** validates PRs into `main` and `release/**` without write
permissions. A relevant push to `main`, or a manual dispatch, runs trusted
reconciliation with `issues: write`. It records the live catalogue before
changes, a plan, the resulting catalogue and an independent drift report.
Reconciliation verifies the exact final match; it is not best effort.

**Detect issue-label drift** runs offline fixtures on relevant PRs. Scheduled
runs (05:17 UTC daily) and manual runs read the live catalogue without mutation
and retain JSON/Markdown evidence for 30 days. Drift fails the run and requires
review; detection does not silently repair it. Scheduled workflows use the
default branch, so they become active after bootstrap integration into `main`.

The manifest uses `prune: true`: labels outside the selected catalogue are
deleted, which also removes their issue/PR associations. Before any change to
the catalogue or manual reconciliation, review the plan and inspect affected
issue/PR associations; migrate those associations before removing a used label.
The reconciler refuses all mutations if any planned deletion still has an
open or closed issue/PR association, or if that lookup fails. This guard uses
the same validated, policy-resolved plan as the mutations: selected profile
and domain overlays are retained, and `prune: false` performs no deletion
association checks. The workflow retains its read-only preview; the script
rechecks current live labels and associations before applying its actual plan.
The offline self-test covers retained used overlays, disabled pruning, used
and unused deletion candidates, and failed or malformed association lookups.
For comma-containing label names, the script scans actual issue/PR labels
instead of GitHub's comma-separated filter. The scan includes closed items,
matches complete names case-insensitively, and fails closed on malformed data
or after 100 pages of 100 items; it never assumes a truncated scan is empty.

Keep deliberate catalogue changes in a reviewed PR. Do not run unreviewed
workflow code with a write token.

For a read-only preview against a saved JSON label array:

```sh
node .github/scripts/labels-sync.mjs --mode plan --live labels-before.json
```

With `GITHUB_TOKEN` set securely in the environment and an explicit reviewed
checkout, a maintainer can run live verification or reconciliation:

```sh
node .github/scripts/labels-drift.mjs --repository danielep71/MKT-FTRB-SA
node .github/scripts/labels-sync.mjs --mode reconcile --dry-run --repository danielep71/MKT-FTRB-SA
node .github/scripts/labels-sync.mjs --mode reconcile --repository danielep71/MKT-FTRB-SA
```

The scripts use bounded pagination and retries. Workflow actions are pinned to
full commit SHAs, checkout credentials are not persisted, and PR validation
never receives a write token.
