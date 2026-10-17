# Verification source and data

This directory reserves verification source, synthetic fixtures, and reviewed
expected results. There is no calculation runner, benchmark suite, or passing
engine test at this stage.

Create fixture and expected-result subdirectories with the first real cases.
Each case must define its inputs and units, signs, expected intermediate and
final outputs, tolerances, independently derived source, and applicability.
Expected results must not be copied from the implementation under test.
Do not put disposable run output here; use ignored root `test-results/`.

The offline traffic collector tests are in `tooling/test_traffic_history.py`.
They use synthetic payloads and mocked GitHub writes, without credentials or
network access. Run them with the command in [Tooling](../tools/README.md).
They do not run a calculation engine.

The label self-tests belong to the scripts listed in
[Tooling](../tools/README.md). They exercise repository maintenance, not FRTB.
[Scope](../docs/SCOPE.md) owns validation principles, and
[Repository structure](../docs/REPOSITORY_STRUCTURE.md) owns placement and
durable evidence.
