# Working rules for this repository

These rules apply to everyone who edits this repository, people and
automated assistants alike. They hold the editorial and assistant rules
only. The procedures are in [governance](docs/GOVERNANCE.md) and
[contributing](CONTRIBUTING.md): follow them, and do not copy them here.

## Voice

- Write my decisions and responsibilities in the first person: "I decided",
  "assign me", "my approval". Never write "the maintainer" or "the owner".
- Address instructions to the reader directly: "run the check", "you need a
  Windows host".
- Write in US English, as [contributing](CONTRIBUTING.md) states.

## What the documentation describes

- Operational documentation describes only the files, configuration and
  behavior of this repository. Do not refer to other repositories, to history
  copied from elsewhere, or to the context of a conversation or session.
- Record license attributions only in the license files:
  [LICENSE](LICENSE) and
  [THIRD_PARTY_NOTICES.txt](docs/licenses/THIRD_PARTY_NOTICES.txt). A file
  copied or adapted under another license keeps that license and its notice;
  never relabel it as MIT.
- Keep editorial and assistant rules in this file only. Other documents link
  here instead of repeating them.

## Branches, commits and pull requests

- Name a task branch with a descriptive prefix and its issue number:
  `docs/`, `fix/`, `feat/`, `chore/` or `test/`, for example
  `fix/123-short-description`. Release branches are `release/vX.Y.Z`. Never
  use a branch name that starts with `codex/` or `claude/`.
- Start the branch from the active release branch that
  [governance](docs/GOVERNANCE.md) names, and open the pull request against
  it.
- Commit messages, pull requests, issues, code comments and documentation
  name no assistant or model and carry no session link or co-author line for
  an assistant.
- State in the pull request what was validated and what was not, for example
  a desktop Excel run.

## Domain conventions are intended

The workbook is built for desktop Excel. The VBA source is kept as exported
modules under `src/modules` and `tests/modules`, next to a macro-free
template. The calculations follow the Basel Framework, and their results are
reconciled with an independent Python reference in LibreOffice. These are
deliberate defaults of this project, not leftovers from other projects: keep
them unless an issue I approve changes them.
