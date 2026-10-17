# Repository tooling

This directory indexes maintenance tools and will hold future general-purpose
repository checks/build helpers when they exist. No engine runtime, workbook
builder, or additional package dependency is introduced by this skeleton.

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
The universal validation entry point, hosted integrity workflow, and dependency
update configuration are pending issue #7. No `tools/check.py` or other
universal runner exists yet. Do not report an absent gate as green.

Add new tools only for real work, document their prerequisites and failure
behavior, and keep calculation logic under `src/`. Generated output and
durable evidence follow [Repository structure](../docs/REPOSITORY_STRUCTURE.md).
