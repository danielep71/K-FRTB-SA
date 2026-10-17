# Agent instructions

## Development branch

- The active integration branch is `release/v0.0.1`.
- Branch every task from that branch and open its PR against `release/v0.0.1`.
- Put all development, documentation, tooling, tests and configuration work
  through task PRs; do not commit directly to main or the release branch.
- Squash-merge task PRs after applicable checks pass and findings are resolved.
- Keep main as the default stable branch. Open or merge a release-to-main PR
  only when the owner explicitly requests integration; use a merge commit.
- Preserve shared history and protected release branches; never force-push,
  reset, or delete/recreate them.

Read [docs/GOVERNANCE.md](docs/GOVERNANCE.md) for the integration lifecycle
and [docs/REPOSITORY_SETTINGS.md](docs/REPOSITORY_SETTINGS.md) for current
controls and pending integrity/review configuration.

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
- Read docs/SCOPE.md before changing functional scope. The engine platform and
  coverage decisions remain unresolved; do not imply a working calculator.
