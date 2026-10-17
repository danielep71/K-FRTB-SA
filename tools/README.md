# Repository tooling

This directory indexes maintenance tools and will hold future general-purpose
repository checks/build helpers when they exist. No engine runtime, workbook
builder, or calculation dependency is introduced by setup maintenance.

## 🧪 Universal repository integrity

After installing `.github/requirements.txt`, run `python tools/check_repository.py`.
It validates tracked content and calls existing label scripts and offline
maintenance tests. [Repository checks](../docs/CI.md) owns coverage, installation,
hosted check identity and dependency policy. It does not run Excel or the engine.

## 📈 Traffic analytics

[Traffic history](../docs/TRAFFIC_HISTORY.md) documents `traffic_history.py`,
the privileged daily/manual export and the offline validation workflow.
It requires Python 3.12 on the workflow runner and no packages. Run its
credential-free tests from the repository root:

```sh
python3 -m unittest discover -s tests/tooling -p test_traffic_history.py -v
```

The collector's dedicated Administration: read credential belongs in the
main-restricted analytics environment, never in PR validation. This tooling
is separate from the engine runtime. Its offline fixtures are also included
in the universal maintenance gate.

## Available commands

Run these from the repository root with Node.js providing built-in fetch
support:

```sh
node .github/scripts/labels-sync.mjs --self-test
node .github/scripts/labels-sync.mjs --mode validate
node .github/scripts/labels-drift.mjs --self-test
```

They run offline fixtures or validate the label catalogue; these commands do
not change live GitHub labels. The scripts stay at their existing authoritative
paths under `.github/scripts/`; do not duplicate them here.
[Labels](../docs/LABELS.md) owns live verification and trusted reconciliation.

[Installation](../INSTALLATION.md) describes checkout and local verification.
`check_repository.py` is the shared local/hosted entry point; its PyYAML
dependency is pinned separately from the prototype's test packages.

Add new tools only for real work, document their prerequisites and failure
behavior, and keep calculation logic under `src/`. Generated output and
durable evidence follow [Repository structure](../docs/REPOSITORY_STRUCTURE.md).
