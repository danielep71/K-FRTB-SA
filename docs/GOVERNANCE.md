# Repository governance

Owner and maintainer: **@danielep71**.

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

## Current controls and outstanding setup

[Repository settings](REPOSITORY_SETTINGS.md) records the live rulesets,
bypass actors, security features and current limitations. PRs and resolved
conversations are required; main allows merge commits, release branches allow
squash merges. Required approvals are zero. The universal required integrity
check is pending issue #7, and automatic PR-review configuration is not yet
verified under issue #2.

Issue #4 still owns CONTRIBUTING.md, the detailed milestone guide and the
remaining contribution/closeout procedures. Issue #7 must target Dependabot
PRs at `release/v0.0.1` when adding its configuration. Issue #8 owns evidence-based
milestone closeout. Creating this branch does not complete those issues.
