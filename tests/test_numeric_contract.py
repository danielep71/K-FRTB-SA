"""Synthetic runtime regressions for issue #41; no locale-dependent expectations."""

import openpyxl
import pytest

import lo_runner
from conftest import require_libreoffice
from test_vba_engine import reconcile, log_rows


def test_shared_numeric_validation_and_conversion(tmp_path):
    require_libreoffice()
    assert lo_runner.run(
        tmp_path / "numeric-contract.xlsx",
        ["TEST_Numeric.Test_NumericContracts_Silent"],
    ) == []


@pytest.mark.parametrize("invalid", ["abc", "", "0,5", "0.5junk", "1e309"])
def test_required_parameter_aborts_and_logs_context(lo_default_path, tmp_path, invalid):
    wb = openpyxl.load_workbook(lo_default_path)
    ws = wb["P_FX"]
    row = next(row for row in ws.iter_rows() if row[2].value == "RW")
    row[3].value = invalid
    source = tmp_path / "bad-parameter.xlsx"
    wb.save(source)
    out = tmp_path / "failed-run.xlsx"
    assert lo_runner.run(out, ["M_Main.RunFRTB_Silent"], input_book=source) == []
    result = openpyxl.load_workbook(out, data_only=True)
    errors = log_rows(result, "ERROR")
    assert any("Invalid numeric parameter RW (P_FX)" in str(row) for row in errors), errors
    assert not any("Finished with" in str(row) for row in log_rows(result, "INFO"))


def test_invariant_numeric_text_preserves_reconciled_outputs(lo_default_path, tmp_path):
    wb = openpyxl.load_workbook(lo_default_path)
    ws = wb["P_FX"]
    row = next(row for row in ws.iter_rows() if row[2].value == "RW")
    row[3].value = str(row[3].value)
    source = tmp_path / "numeric-text.xlsx"
    wb.save(source)
    out = tmp_path / "numeric-text-out.xlsx"
    assert lo_runner.run(out, ["M_Main.RunFRTB_Silent"], input_book=source) == []
    result = openpyxl.load_workbook(out, data_only=True)
    assert log_rows(result, "ERROR") == []
    assert reconcile(result) == []
