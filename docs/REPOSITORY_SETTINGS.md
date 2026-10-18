# Repository settings baseline

Baseline verified on October 17, 2026, against the live GitHub settings and
rulesets. Later readbacks are dated where they are recorded; the latest is
October 18, 2026. GitHub Settings remains authoritative; this file records
the observed baseline and outstanding dependencies.

## General settings

| Control | Before issue #2 | Verified baseline |
| --- | --- | --- |
| Visibility | Private | Public, changed by the owner during setup |
| License | MIT | MIT |
| Default branch | main | main |
| Automatically delete merged head branches | Off | On; protected release branches are retained |
| Suggest updating PR branches | Off | On |
| Merge / squash / rebase availability | All enabled | All enabled globally; branch rules narrow permitted methods |
| Auto-merge | Off | Off |
| Wiki | Enabled | Enabled, editing restricted to collaborators; since October 18, 2026 its Home page links to the versioned documents |
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
conversation resolution is required.
Administrative bypasses are not permissions granted to additional users or
apps. No app bypass was added.

The v0.0.1 setup milestone closed on October 18, 2026. The owner deleted
**`release/v0.0.1`** the same day (#62). For the deletion only, ruleset
25319621 temporarily excluded that branch and stayed active for every other
`release/**` branch; the owner then removed the exclusion, and the readback
matches the earlier configuration. The branch's closeout head
`b4d6c02edcd60bb412a06999d1909e6eaba63837` (#53) is on main. No v0.0.1 tag
was created.

The active prototype integration branch **`release/v0.1.0`** also receives
repository maintenance and all three Dependabot entries, milestone 2, under
the owner decision of October 18, 2026 (#51). Shared controls were synchronized
under #31. It matches `release/**`: readback on October 18 confirms the
active force-push restriction and the separate deletion rule with no bypass.
See [branch governance](GOVERNANCE.md) for task PRs and controlled active-branch
fast-forward after main integration. Task branches can be deleted automatically
after merge.

**Required status check.** The unconditional **Repository integrity** check
from #7 (GitHub Actions, app ID 15368) is required by both rulesets, read back
on October 18, 2026:

| Ruleset | Required check | Up to date before merging | Not enforced on branch creation |
| --- | --- | --- | --- |
| Protect main (25319557) | `Repository integrity` | Yes | No |
| Protect release branches (25319604) | `Repository integrity` | No | Yes, so new release branches can be created from main |

The path-filtered label, traffic and prototype checks are deliberately not
required: a PR that never triggers them would stay blocked. Dependabot PR
#37, opened before the workflow reached its base, was reported `blocked`
only because the required check had not run.

## Actions permissions

- All actions/reusable workflows are allowed, but **full-length
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
| Low-impact development-dependency auto-dismissal | Enabled by the public-repository preset | Disabled |
| Private vulnerability reporting | Not offered while private | Enabled after the owner's public-visibility change |
| Secret scanning alerts | Not offered while private | Secret Protection enabled |
| Secret push protection | Off | Enabled |
| CodeQL | Not configured | Default setup for GitHub Actions and Python (added automatically when Python code arrived), default query suite, weekly schedule; setup run succeeded; read back October 18, 2026 |
| Dependabot version updates | No configuration | Added under #7; #51 consolidates three entries on release/v0.1.0, milestone 2; scheduling uses the configuration on main; targets in CI.md |
| Dependabot security update PRs | Off | Remain off; version-update targets do not govern security PRs; changing this is a new owner settings decision (CI.md) |

[CodeQL setup evidence](https://github.com/danielep71/MKT-FTRB-SA/actions/runs/39070451926).
The detected language at setup was **GitHub Actions**, not an FRTB calculation
engine. CodeQL setup and scan results do not certify calculation correctness.
No paid feature or agentic autofix was enabled.

## Automated review and remaining work

GitHub's Copilot code review page explicitly reports **No Copilot code review
access** for this account. No paid subscription or Copilot review automation
was enabled. The ChatGPT Codex Connector reviews automatically when a PR is
opened or a draft is marked ready for review: on #42 and #46 its summary
shows the trigger "PR opened" with no manual request. It does not re-review later pushes; request
one with `@codex review` or review them as a maintainer, and resolve findings
before merge.

Issue #2 is closed with the readback of the required check, the
representative blocked PR and the review evidence.

The retained-branch lifecycle was exercised through PR #13: main received
merge commit `c01f2ad6c71ea2d6f23eac2b5a07fcdd430456a4`, the release branch
was fast-forwarded to it, and the post-integration CodeQL run passed.
[Governance](GOVERNANCE.md) defines the ongoing verification procedure;
issue #4 supplies contribution, milestone, and closeout guidance.

## Traffic analytics

The owner authorized traffic-history collection under issue #23.
[Traffic history](TRAFFIC_HISTORY.md) owns the workflow, dedicated data-branch
protection, analytics environment and credential contract. A real successful
collection is required before reporting the feature operational; branch or
workflow presence alone is insufficient.

Traffic ruleset **25321321** is active for `traffic-history`, blocks deletion
and non-fast-forward updates, and has no bypass actors. The `analytics`
environment is restricted to branch `main` (no tags) and holds the
`TRAFFIC_TOKEN` secret. The first successful collection ran on October 18,
2026 ([run 39105087826](https://github.com/danielep71/MKT-FTRB-SA/actions/runs/39105087826),
data commit `af6a68a`); #23 is closed.
