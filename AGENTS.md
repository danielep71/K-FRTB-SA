# Agent instructions

## Development branch

- The active integration branch is `release/v0.1.0` for the SA prototype
  and repository maintenance (milestone 2, owner-approved October 18, 2026, #51).
- The setup branch `release/v0.0.1` was deleted by the owner on October 18,
  2026 (#62); its head is on main. Do not recreate or target it.
- Branch every task from the integration branch of its issue's milestone and
  open its PR against that branch.
- Put all development, documentation, tooling, tests and configuration work
  through task PRs; do not commit directly to main or the release branch.
- Squash-merge task PRs after applicable checks pass and findings are resolved.
- Keep main as the default stable branch. Open or merge a release-to-main PR
  only when the owner explicitly requests integration; use a merge commit.
- Preserve shared history and protected release branches; never force-push,
  reset, or delete/recreate them. Only the owner decides a deletion (#62).

Read [docs/GOVERNANCE.md](docs/GOVERNANCE.md) for the integration lifecycle
and [docs/REPOSITORY_SETTINGS.md](docs/REPOSITORY_SETTINGS.md) for current
verified controls, including required integrity checks and automatic PR review.

## Scope and evidence

- Write repository content in US English.
- Every issue must have one priority label, a milestone and an assignee.
  Assign issues to danielep71. Reserve P1 for confirmed calculation bugs.
- Update affected documentation and CHANGELOG.md alongside implementation.
- Run checks appropriate to the change and inspect the hosted results before
  merging. Run `python tools/check_repository.py` after installing the pinned
  `.github/requirements.txt` dependency; see docs/CI.md for coverage and limits.
- Keep incomplete acceptance criteria open and link evidence when completing
  them. Distinguish static checks from runtime and independent validation.
- Read docs/SCOPE.md before changing functional scope. Excel/VBA is approved for the prototype; the long-term platform decision
  remains open. Do not claim Excel execution or regulatory certification
  without the evidence tracked in #28/#29.
