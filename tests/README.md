# 🧪 Verification source and data

This directory holds the verification source of the v0.1.0 prototype
(issue #20). Expected results are derived by an independent Python reference,
never copied from the VBA under test.

| Path | Content |
| --- | --- |
| `modules/TEST_Regression.bas` | VBA regression test imported into development builds; compares the last run with `Test_Expected` |
| `frtb_reference.py` | Independent Python reference implementation of the prototype's scope |
| `regulatory_defaults.py` | Regulatory parameters typed independently of `M_Setup` |
| `test_reference.py` | Hand-calculated checks of the reference |
| `test_vba_engine.py` | Headless LibreOffice runs of the VBA reconciled with the reference |
| `test_tooling.py` | VBA lint and freshness of the embedded expected values |
| `conftest.py` | Shared LibreOffice fixtures |
| `requirements.txt` | Pinned Python test dependencies |

The sample portfolio and the test cases are synthetic, written for this
project. Each hand-calculated case states its inputs and the MAR formula it
works through; tolerances are in the tests. Do not put disposable run output
here; use ignored root `test-results/`.

The label scripts listed in [Tooling](../tools/README.md) keep their own
self-tests. [Scope](../docs/SCOPE.md) owns validation principles,
[Repository structure](../docs/REPOSITORY_STRUCTURE.md) owns placement and
durable evidence, and [Validation](../docs/validation.md) records what the
prototype checks do and do not establish.
