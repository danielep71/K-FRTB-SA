# Repository governance

Owner and maintainer: **@danielep71**.

This document owns branch, issue, review, and milestone procedures.
[CONTRIBUTING.md](../CONTRIBUTING.md) provides the contributor walkthrough;
[labels and triage](LABELS.md) owns label definitions, and
[repository settings](REPOSITORY_SETTINGS.md) records effective GitHub controls.

## Branches

The active integration branch is **`release/v0.0.1`**, selected by the owner.
It was created from main at `96a3b44312fd0f6beb000a06d2a43ac46b0551ef`,
so it includes all setup work already integrated through PRs #9, #10 and #11.
Those earlier commits remain in main; shared history is preserved.

| Branch | Purpose and allowed changes |
| --- | --- |
| `release/v0.0.1` | Integration branch for all ongoing v0.0.1 development, including documentation, tooling, tests and configuration |
| `main` | Stable default branch; receives the integration branch only through a separate owner-requested PR |
| Short-lived task branches | Branch from `release/v0.0.1`; use focused names such as `fix/<issue>-<slug>`, `docs/<issue>-<slug>` or `chore/<issue>-<slug>` |

Every development PR targets **`release/v0.0.1`**, including automated
maintenance PRs when configured. Task PRs are squash-merged after applicable
checks pass and review findings are resolved. Do not commit development work
directly to main or the release branch. Check the base explicitly when opening
a PR: GitHub's default branch remains main.

Do not open or merge a release-to-main integration PR merely to report progress.
When the owner requests integration, open a PR from `release/v0.0.1` into
`main`, verify its diff, applicable checks and review findings, then merge with
a **merge commit** to preserve ancestry. Integration does not by itself publish
a version tag, release, workbook or website.

Release branches are retained: a separate active ruleset blocks their deletion
with no bypass. After integration, an authorized maintainer may fast-forward
`release/v0.0.1` to the main merge commit if v0.0.1 work continues, using the
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

The active milestone is
[v0.0.1 - Repo setup](https://github.com/danielep71/MKT-FTRB-SA/milestone/1).
Its [detailed guide](Milestones/v0.0.1.md) defines purpose, entry and exit
criteria, dependencies, evidence, and deferred scope. The live issue tracker
owns progress; a guide is not a substitute for completed acceptance criteria.

The owner approves milestone scope and any next integration branch. Before a
milestone closes, its closeout issue must reconcile all associated work,
including closed issues and PRs, confirm metadata and evidence, and record
adopted and deferred SACCR practices. For v0.0.1, issue #8 owns that record.
A genuine gap stays open or is explicitly respecified by the owner; moving it
elsewhere does not make the original acceptance criterion pass.

Closing a milestone does not authorize integration into main, a tag, a GitHub
release, a workbook, a website, or a visibility change. Those decisions are
separate. Issue #8 owns the release procedure and version convention.

## Current controls and outstanding setup

[Repository settings](REPOSITORY_SETTINGS.md) records the live rulesets,
bypass actors, security features and current limitations. PRs and resolved
conversations are required; main allows merge commits, release branches allow
squash merges. Required approvals are zero. The universal required integrity
check is pending issue #7, and automatic PR-review configuration is not yet
verified under issue #2.

| Requirement | Enforcement or working procedure |
| --- | --- |
| PRs, merge methods, conversation resolution, shared-history and deletion protection | Active rulesets, with the bypass modes recorded in the settings baseline |
| Release-branch deletion prohibition | Separate active ruleset with no bypass actors |
| Independent approval | No required approvals configured; maintainer procedure must not claim independent review occurred |
| Successful universal integrity check | Pending #7 and attachment to rulesets in #2 |
| Review coverage for every PR | Maintainer procedure; automatic-review configuration and release-target coverage remain to be verified in #2 |
| Issue/PR assignee, priority, milestone, acceptance evidence | Manual triage and completion procedure |
| Owner-requested main integration and controlled release-branch fast-forward | Maintainer procedure using the documented branch protections and expected-head guard |

Issue #6 owns issue forms, the PR template, and conduct/security policies.
Issue #7 must target Dependabot PRs at `release/v0.0.1` when adding its
configuration. Issue #2 remains open for its required-check and review
dependencies; issue #8 owns final milestone closeout.

The procedures follow SACCR's contribution and governance approach, adapted
to this project's setup stage and retained-release-branch protections. No
SACCR engine, Excel harness, traffic-alert exception, or unimplemented check
is adopted by this documentation.
