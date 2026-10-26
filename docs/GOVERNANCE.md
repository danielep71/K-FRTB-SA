# Repository governance

Owner and maintainer: **@danielep71**.

Explicit approvals and requests for integration, publication or settings
changes in these documents must come from this repository maintainer.

This document owns branch, issue, review, and milestone procedures.
[CONTRIBUTING.md](../CONTRIBUTING.md) provides the contributor walkthrough;
[labels and triage](LABELS.md) owns label definitions, and
[repository settings](REPOSITORY_SETTINGS.md) records effective GitHub controls.

## Branches

The active integration branch is **`release/v0.1.0`** for the SA prototype
and repository maintenance. Maintenance was approved on this branch
and milestone 2 on October 18, 2026 ([decision in #51](https://github.com/danielep71/K-FRTB-SA/issues/51#issuecomment-6254417218)),
until a later explicitly approved transition. It was originally approved for
the prototype on October 17 and created from main at
`d150d3822d5d50f69aabfca153bf6d302e80f2e4` (the integration of #18).

The v0.0.1 setup milestone is closed. The integration branch
**`release/v0.0.1`** was deleted on October 18, 2026 (#62). Its closeout head
`b4d6c02` is on main, so no history was lost; the closed milestone and the
[setup closeout record](evidence/2026-10-18-setup-closeout.md) remain the
setup baseline. Do not recreate or target the branch.

| Branch | Purpose and allowed changes |
| --- | --- |
| `release/v0.1.0` | Active integration branch for the SA prototype and repository maintenance, milestone 2 |
| `main` | Stable default branch; receives an integration branch only through a separate explicitly requested PR |
| Short-lived task branches | Branch from the integration branch of the issue's milestone; use focused names such as `feat/<issue>-<slug>`, `fix/<issue>-<slug>`, `docs/<issue>-<slug>` or `chore/<issue>-<slug>` |

Current prototype and maintenance task PRs target **`release/v0.1.0`**,
including Dependabot version updates. Future milestone work needs its own
explicitly approved integration branch. Task PRs are squash-merged after applicable
checks pass and review findings are resolved. Do not commit development work
directly to main or the release branch. Check the base explicitly when opening
a PR: GitHub's default branch remains main.

Do not open or merge a release-to-main integration PR merely to report progress.
When integration is explicitly requested, open a PR from the applicable integration branch into
`main`, verify its diff, applicable checks and review findings, then merge with
a **merge commit** to preserve ancestry. Integration does not by itself publish
a version tag, release, workbook or website.

After integration, an authorized maintainer may fast-forward the active
integration branch to the main merge commit if work continues, using the
existing administrator maintenance bypass and an expected-head check. At a
milestone transition, create the next explicitly approved integration branch and
update this document, contribution guidance and automated PR targets together.

### Release-branch lifecycle

A release branch is active while its milestone accepts work. Both release
rulesets protect it, including a separate deletion rule with no bypass. Once
it is **obsolete**, it is deleted (decision of October 18, 2026, #66).
A release branch is obsolete when all of these hold:

1. its milestone is closed;
2. its head is an ancestor of main, integrated through the explicitly requested
   merge-commit PR;
3. no open PR, Dependabot entry or workflow targets it;
4. a repository-wide search finds no current document that names it as
   active or tells contributors to use it. The search covers README,
   INSTALLATION, CONTRIBUTING, SECURITY, SCOPE, this document and the
   other `docs/` pages, the PR template and the issue forms. Dated evidence
   records and historical CHANGELOG entries are excluded.

To delete an obsolete branch:

1. The milestone closeout issue, or a follow-up issue, records the branch
   head, the check of each condition and the search used for the fourth.
2. The maintainer temporarily excludes the branch from ruleset 25319621, deletes
   it using the administrator bypass of ruleset 25319604, and then removes
   the exclusion.
3. The issue records the readback: the branch is absent, its head is on
   main, and ruleset 25319621 matches its earlier configuration.

`release/v0.0.1` was deleted this way (#62). Never delete an active release
branch, force-push or reset shared history, or recreate a deleted release
branch name; later work uses a new explicitly approved branch.

### Integration verification

Before integration, record the release head and main head. After the
explicitly requested merge, inspect the resulting commit: its first parent must
be the previous main head and its second parent the reviewed release head.
Fast-forward the active release branch only if it still points to that
reviewed head and the merge commit descends from it. If it moved, inspect
the new work before proceeding; never reset or force an update.

Record the PR, merge commit, branch readback, and applicable post-merge checks.
PR [#13](https://github.com/danielep71/K-FRTB-SA/pull/13) demonstrates this
lifecycle: merge commit `c01f2ad6c71ea2d6f23eac2b5a07fcdd430456a4`
preserved both parents and the retained release branch was fast-forwarded to
it. [CodeQL passed](https://github.com/danielep71/K-FRTB-SA/actions/runs/39071612077).
Later task PRs advance the release branch again; branches need match only at
the integration checkpoint.

## Issue metadata and completion

Every issue has assignee **danielep71**, exactly one priority label and a
milestone. P1 is reserved for confirmed calculation bugs; setup improvements
normally use P3. Record the objective, acceptance checklist, dependencies and
required evidence. The [label guide](LABELS.md) owns the detailed taxonomy and
triage queries; these metadata requirements are manual triage rules.

Close an issue only when its criteria have linked evidence. Mark checkboxes
complete only when the corresponding work is verified. Keep blocked work
open with named dependencies. Static repository checks, actual runtime tests,
independent expected-value comparisons and methodology review are distinct
forms of evidence; do not claim one establishes the others.

### Synchronizing integration branches

Bring shared main changes into another active release through a task branch
and reviewed task PR. Resolve shared documents against both source heads,
preserving current requirements and replacing superseded statements. Record
both heads, the resulting commit and a content comparison. A squash merge
preserves the release's existing history but does not make the synchronized
main head an ancestor; never use that merge to claim ancestry advancement.

### Issue forms and template activation

The bug form defaults to `bug` and `P2`; feature and documentation forms
default to their type label and `P3`. All forms assign `danielep71`.
Forms cannot assign a milestone, so maintainers must select it and confirm
exactly one priority before completing triage. P1 remains limited to confirmed
calculation bugs. API/CLI-created issues and PRs bypass form defaults and need
explicit metadata. Disabling ordinary blank issues does not enforce metadata
or prevent maintainers from creating blank issues.

GitHub serves the issue chooser and PR template from the default branch.
Files merged into a release branch need a separate explicitly requested main
integration before default-branch activation. Initial forms and policies were
activated and verified through #21/#6; the prototype-aware updates
reached main through #58. The
[PR template](../.github/PULL_REQUEST_TEMPLATE.md) contains the single merge
checklist; this document owns its detailed procedures.

### Triage and closeout procedure

1. Inspect the title, objective, acceptance criteria, dependencies, labels,
   milestone, assignee, and discussion. Use the repository-wide searches in
   [Labels](LABELS.md), including closed issues and issues without milestones.
2. Assign `danielep71`, exactly one priority, and the milestone that owns the
   work. Apply the same metadata to development PRs. Do not create a new
   milestone or infer authorization for functional scope from a version number.
3. Keep blocked criteria unchecked and name their dependency. Split unrelated
   scope into linked issues while retaining traceability.
4. Before merging, inspect the candidate diff, applicable hosted checks,
   review submissions, inline threads, and automated-review progress. Wait for
   any running review, address valid findings, and explain dismissals with
   evidence before resolving threads. Resolve stale findings against the
   current source. An author's self-check is not independent review.
5. After merging, link the PR, commit, successful applicable checks, and any
   required runtime or settings evidence in the issue. Mark only verified
   criteria complete. If validation failed or could not run, record it and
   keep the affected work open.
6. Close as completed only when the full acceptance scope is verified.
   For a duplicate, link its authoritative replacement and close as duplicate
   where supported, otherwise as not planned with the reason recorded.
   Declined or invalid work closes as not planned with a concrete explanation;
   its implementation checkboxes remain unchecked. Preserve required metadata.

### Milestone management

[v0.0.1 — Repo setup](https://github.com/danielep71/K-FRTB-SA/milestone/1)
closed on October 18, 2026; its [detailed guide](Milestones/v0.0.1.md) and
[closeout record](evidence/2026-10-18-setup-closeout.md) remain the setup
baseline. [v0.1.0 — SA prototype](https://github.com/danielep71/K-FRTB-SA/milestone/2)
is active: prototype closeout and its milestone guide are tracked in #32, and
#28 owns Excel evidence. The methodology decisions (#29) belong to v0.2.0 in
the [milestone plan](ROADMAP.md). The live issue tracker
owns progress; a guide is not a substitute for completed acceptance criteria.

Milestone scope and any next integration branch require explicit approval. Before a
milestone closes, its closeout issue must reconcile all associated work,
including closed issues and PRs, confirm metadata and evidence, and record
adopted and deferred maintenance practices. For v0.0.1, issue #8 owns that record.
A genuine gap stays open or is explicitly respecified by the maintainer; moving it
elsewhere does not make the original acceptance criterion pass.

Closing a milestone does not authorize integration into main, a tag, a GitHub
release, a workbook, a website, or a visibility change. Those decisions are
separate. [Releasing](../RELEASING.md) defines the release procedure and
version convention (#8).

## Current controls and maintenance

[Repository settings](REPOSITORY_SETTINGS.md) records the live rulesets,
bypass actors, security features and current limitations. PRs and resolved
conversations are required; main allows merge commits, release branches allow
squash merges. Required approvals are zero. The universal integrity workflow
(#7) is a required check on main and release branches (#2). The ChatGPT Codex
Connector reviews every PR automatically when it is opened; later pushes are
re-reviewed only on request (`@codex review`).

| Requirement | Enforcement or working procedure |
| --- | --- |
| PRs, merge methods, conversation resolution, shared-history and deletion protection | Active rulesets, with the bypass modes recorded in the settings baseline |
| Release-branch deletion protection | Separate active ruleset with no bypass actors; an obsolete branch is deleted only through the lifecycle procedure above (#66) |
| Independent approval | No required approvals configured; maintainer procedure must not claim independent review occurred |
| Successful universal integrity check | Required `Repository integrity` check on main (strict) and release branches (#7, #2) |
| Review coverage for every PR | Automatic Codex review when a PR is opened, on main and release targets (#2); maintainer review of later pushes |
| Issue/PR assignee, priority, milestone, acceptance evidence | Manual triage and completion procedure |
| Explicitly requested main integration and controlled release-branch fast-forward | Maintainer procedure using the documented branch protections and expected-head guard |

Issue #6 recorded initial default-branch activation of forms and the PR
template; later changes follow the same activation procedure. [Conduct](../CODE_OF_CONDUCT.md) and [security](../SECURITY.md)
policies define the reporting routes.
Dependabot targets Actions, the CI parser and prototype test packages at
`release/v0.1.0`, milestone 2, as detailed in [Repository checks](CI.md).
Issue #8 completed the v0.0.1 closeout; its record is
[Setup closeout](evidence/2026-10-18-setup-closeout.md).

The procedures fit this project's prototype stage and release-branch
protections. This document records maintenance procedures, not Excel execution or
regulatory certification. Prototype source and LibreOffice evidence are
tracked separately from setup closeout.
