# Repository governance

Owner and maintainer: **@danielep71**.

This document owns branch, issue, review, and milestone procedures.
[CONTRIBUTING.md](../CONTRIBUTING.md) provides the contributor walkthrough;
[labels and triage](LABELS.md) owns label definitions, and
[repository settings](REPOSITORY_SETTINGS.md) records effective GitHub controls.

## Branches

Two integration branches are active, each selected by the owner for one
milestone:

- **`release/v0.0.1`** for the v0.0.1 repository setup. It was created from
  main at `96a3b44312fd0f6beb000a06d2a43ac46b0551ef`, so it includes all
  setup work already integrated through PRs #9, #10 and #11. Those earlier
  commits remain in main; shared history is preserved.
- **`release/v0.1.0`** for the v0.1.0 SA prototype, approved by the owner on
  2026-10-17 and created from main at
  `d150d3822d5d50f69aabfca153bf6d302e80f2e4` (the integration of #18).

| Branch | Purpose and allowed changes |
| --- | --- |
| `release/v0.0.1` | Integration branch for all ongoing v0.0.1 development, including documentation, tooling, tests and configuration |
| `release/v0.1.0` | Integration branch for the v0.1.0 SA prototype |
| `main` | Stable default branch; receives an integration branch only through a separate owner-requested PR |
| Short-lived task branches | Branch from the integration branch of the issue's milestone; use focused names such as `feat/<issue>-<slug>`, `fix/<issue>-<slug>`, `docs/<issue>-<slug>` or `chore/<issue>-<slug>` |

Every development PR targets the integration branch of its issue's milestone:
**`release/v0.0.1`** for setup work, including automated maintenance PRs when
configured, and **`release/v0.1.0`** for prototype work. Task PRs are squash-merged after applicable
checks pass and review findings are resolved. Do not commit development work
directly to main or the release branch. Check the base explicitly when opening
a PR: GitHub's default branch remains main.

Do not open or merge a release-to-main integration PR merely to report progress.
When the owner requests integration, open a PR from the applicable integration branch into
`main`, verify its diff, applicable checks and review findings, then merge with
a **merge commit** to preserve ancestry. Integration does not by itself publish
a version tag, release, workbook or website.

Release branches are retained: a separate active ruleset blocks their deletion
with no bypass. After integration, an authorized maintainer may fast-forward
the applicable integration branch to the main merge commit if work continues, using the
existing administrator maintenance bypass and an expected-head check. Never
force-push, reset shared history, or delete/recreate a release branch. At a
milestone transition, create the next owner-approved integration branch and
update this document, agent guidance and automated PR targets together.

### Integration verification

Before integration, record the release head and main head. After the
owner-requested merge, inspect the resulting commit: its first parent must
be the previous main head and its second parent the reviewed release head.
Fast-forward the retained release branch only if it still points to that
reviewed head and the merge commit descends from it. If it moved, inspect
the new work before proceeding; never reset or force an update.

Record the PR, merge commit, branch readback, and applicable post-merge checks.
PR [#13](https://github.com/danielep71/MKT-FTRB-SA/pull/13) demonstrates this
lifecycle: merge commit `c01f2ad6c71ea2d6f23eac2b5a07fcdd430456a4`
preserved both parents and the retained release branch was fast-forwarded to
it. [CodeQL passed](https://github.com/danielep71/MKT-FTRB-SA/actions/runs/39071612077).
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
Files merged into a release branch need a separate owner-requested main
integration before default-branch activation. Initial forms and policies were
activated and verified through #21/#6. Prototype-aware updates on
release/v0.1.0 require their own later main integration. The
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

Two milestones are active: [v0.0.1 - Repo setup](https://github.com/danielep71/MKT-FTRB-SA/milestone/1)
and [v0.1.0 - SA prototype](https://github.com/danielep71/MKT-FTRB-SA/milestone/2).
The setup [detailed guide](Milestones/v0.0.1.md) defines purpose, entry/exit
criteria and evidence. Prototype closeout and its milestone guide are tracked
in #32; #28 owns Excel evidence and #29 the remaining methodology decisions. The live issue tracker
owns progress; a guide is not a substitute for completed acceptance criteria.

The owner approves milestone scope and any next integration branch. Before a
milestone closes, its closeout issue must reconcile all associated work,
including closed issues and PRs, confirm metadata and evidence, and record
adopted and deferred maintenance practices. For v0.0.1, issue #8 owns that record.
A genuine gap stays open or is explicitly respecified by the owner; moving it
elsewhere does not make the original acceptance criterion pass.

Closing a milestone does not authorize integration into main, a tag, a GitHub
release, a workbook, a website, or a visibility change. Those decisions are
separate. Issue #8 owns the release procedure and version convention.

## Current controls and outstanding setup

[Repository settings](REPOSITORY_SETTINGS.md) records the live rulesets,
bypass actors, security features and current limitations. PRs and resolved
conversations are required; main allows merge commits, release branches allow
squash merges. Required approvals are zero. The universal integrity workflow
is implemented under #7; attachment to branch rules remains #2. Automatic
PR-review configuration is not yet
verified under issue #2.

| Requirement | Enforcement or working procedure |
| --- | --- |
| PRs, merge methods, conversation resolution, shared-history and deletion protection | Active rulesets, with the bypass modes recorded in the settings baseline |
| Release-branch deletion prohibition | Separate active ruleset with no bypass actors |
| Independent approval | No required approvals configured; maintainer procedure must not claim independent review occurred |
| Successful universal integrity check | Repository integrity workflow (#7); pending attachment to rulesets in #2 |
| Review coverage for every PR | Maintainer procedure; automatic-review configuration and release-target coverage remain to be verified in #2 |
| Issue/PR assignee, priority, milestone, acceptance evidence | Manual triage and completion procedure |
| Owner-requested main integration and controlled release-branch fast-forward | Maintainer procedure using the documented branch protections and expected-head guard |

Issue #6 recorded initial default-branch activation of forms and the PR
template; later changes follow the same activation procedure. [Conduct](../CODE_OF_CONDUCT.md) and [security](../SECURITY.md)
policies define the reporting routes.
Dependabot targets setup updates at `release/v0.0.1` and existing prototype
updates at `release/v0.1.0`, as detailed in [Repository checks](CI.md).
Issue #2 remains open for its required-check and review
dependencies; issue #8 owns final milestone closeout.

The procedures fit this project's setup stage and retained-release-branch
protections. This document records maintenance procedures, not Excel execution or
regulatory certification. Prototype source and LibreOffice evidence are
tracked separately from setup closeout.
