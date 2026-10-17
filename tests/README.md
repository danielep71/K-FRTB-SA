# 🧪 Tests

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

Run them as described in [validation](../docs/validation.md). The fixtures
are synthetic: never add real portfolio data.
