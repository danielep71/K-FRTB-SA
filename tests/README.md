# Verification source and data

This directory reserves verification source, synthetic fixtures, and reviewed
expected results. There is no calculation runner, benchmark suite, or passing
engine test at this stage.

Create fixture and expected-result subdirectories with the first real cases.
Each case must define its inputs and units, signs, expected intermediate and
final outputs, tolerances, independently derived source, and applicability.
Expected results must not be copied from the implementation under test.
Do not put disposable run output here; use ignored root `test-results/`.

The existing executable self-tests belong to the label scripts listed in
[Tooling](../tools/README.md). They exercise repository maintenance, not FRTB.
[Scope](../docs/SCOPE.md) owns validation principles, and
[Repository structure](../docs/REPOSITORY_STRUCTURE.md) owns placement and
durable evidence.
