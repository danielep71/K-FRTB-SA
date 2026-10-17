# Production source

This directory is the future production-source boundary. It currently contains
guidance and the [workbook reservation](workbook/README.md), not a calculation
engine.

[Repository structure](../docs/REPOSITORY_STRUCTURE.md) owns placement and the
source-of-truth policy. Before adding components, record the platform, public
contracts, regulatory baseline, and initial coverage in
[Scope](../docs/SCOPE.md) and the relevant implementation issues.

Add internal subdirectories with their first real component. Keep test code
under `tests/` and maintenance logic under `tools/` or the existing
`.github/scripts/`. Workbook binaries must never be the only source record.
