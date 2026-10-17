# Repository settings baseline

Verified on October 17, 2026, against the live GitHub settings and
VBA-SACCR-Toolkit's current rulesets. GitHub Settings remains authoritative;
this file records the observed baseline and outstanding dependencies.

## General settings

| Control | Before issue #2 | Verified baseline |
| --- | --- | --- |
| Visibility | Private | Public, changed by the owner during setup |
| License | MIT | MIT retained; ported label files retain their MPL notices |
| Default branch | main | main |
| Automatically delete merged head branches | Off | On; protected release branches are retained |
| Suggest updating PR branches | Off | On |
| Merge / squash / rebase availability | All enabled | All enabled globally, as in SACCR; branch rules narrow permitted methods |
| Auto-merge | Off | Off |
| Wiki | Enabled | Enabled, editing restricted to collaborators |
| Issues / projects | Enabled / disabled | Enabled / disabled |
| Discussions | Disabled in repository API | Disabled in repository API; the navigation may display a Discussions link |
| GitHub Pages | Disabled | Disabled; website publication is separate work |

## Active rulesets

| Ruleset | Target | Enforced behavior | Bypass actors |
| --- | --- | --- | --- |
| [Protect main](https://github.com/danielep71/MKT-FTRB-SA/rules/25319557) | Default branch | PR required; resolved conversations; merge commits only; no deletion or force pushes | Repository admin, through PRs only |
| [Protect release branches](https://github.com/danielep71/MKT-FTRB-SA/rules/25319604) | release/** | PR required; resolved conversations; squash only; no force pushes; deletion restriction | Repository admin, always, subject to the separate deletion rule |
| [Prevent release branch deletion](https://github.com/danielep71/MKT-FTRB-SA/rules/25319621) | release/** | Deletion blocked independently | None |
| [Protect release tags](https://github.com/danielep71/MKT-FTRB-SA/rules/25319649) | v* tags | Updates, deletion and force pushes blocked | None |

All four rulesets have active enforcement. Required approval count is zero,
as in SACCR's inspected baseline; conversation resolution is required.
Administrative bypasses are not permissions granted to additional users or
apps. No app bypass was added.

The owner has selected **`release/v0.0.1`** as the active integration branch.
It was created from main after PR #11 and inherits the existing setup work.
All task PRs target this branch. No version tag has been created. The rulesets
match `release/**`, including the `release/v0.0.1` name. See
[branch governance](GOVERNANCE.md) for integration into main and subsequent
retention/fast-forward; the separate deletion rule has no bypass. Task branches
can be deleted automatically after merge.

**Required status checks are pending issue #7.** The label checks are
path-filtered and cannot serve as a universal repository-integrity gate.
Do not require a nonexistent check or one that skips ordinary PRs. After #7
passes on a representative PR, add its actual stable check name and GitHub
Actions identity to main and release rules, require main to be up to date,
and record the resulting settings/evidence in issue #2.

## Actions permissions

- All actions/reusable workflows are allowed, matching SACCR, but **full-length
  commit SHA pinning is now enforced** in repository settings.
- Default GITHUB_TOKEN permissions remain read-only (contents/packages).
- Actions cannot create or approve PRs by default.
- Retention remains 90 days; label evidence artifacts explicitly use 30 days.
- Existing label workflows separately grant issues:write only to trusted
  reconciliation, not to PR validation.
- Public-repository fork approval currently requires approval for first-time
  contributors; this was read back after the owner made the repository public.

## Security features

| Control | Before | Verified result |
| --- | --- | --- |
| Dependency graph | Off | Enabled |
| Dependabot alerts | Off | Enabled |
| Low-impact development-dependency auto-dismissal | Enabled by the public-repository preset | Disabled, matching SACCR's policy |
| Private vulnerability reporting | Not offered while private | Enabled after the owner's public-visibility change |
| Secret scanning alerts | Not offered while private | Secret Protection enabled |
| Secret push protection | Off | Enabled |
| CodeQL | Not configured | Default setup enabled for detected GitHub Actions; setup run succeeded |
| Dependabot version updates | No configuration | Issue #7 owns configuration and integration-branch targeting |
| Dependabot security update PRs | Off | Remain off pending the dependency-update policy in #7 |

[CodeQL setup evidence](https://github.com/danielep71/MKT-FTRB-SA/actions/runs/39070451926).
The detected language at setup was **GitHub Actions**, not an FRTB calculation
engine. CodeQL setup and scan results do not certify calculation correctness.
No paid feature or agentic autofix was enabled.

## Automated review and remaining work

GitHub's Copilot code review page explicitly reports **No Copilot code review
access** for this account. No paid subscription or Copilot review automation
was enabled. ChatGPT Codex Connector is installed, but installation alone is
not evidence that automatic PR review is configured; that setting remains to
be verified through its supported review configuration. Until verified, use
maintainer review and resolve findings before merge.

Issue #2 remains open for the required check from #7, automated-review verification and a
representative PR/check verification of the completed configuration. Preserve
an accurate distinction between live controls and pending work.

The retained-branch lifecycle was exercised through PR #13: main received
merge commit `c01f2ad6c71ea2d6f23eac2b5a07fcdd430456a4`, the release branch
was fast-forwarded to it, and the post-integration CodeQL run passed.
[Governance](GOVERNANCE.md) defines the ongoing verification procedure;
issue #4 supplies contribution, milestone, and closeout guidance.
