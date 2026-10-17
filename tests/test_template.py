"""The committed workbook template and the build that starts from it."""

from __future__ import annotations

import build_template
import lo_runner
import openpyxl
import openpyxl.styles
from conftest import require_libreoffice
from test_vba_engine import FIRST_COL, log_rows, reconcile


def test_template_is_current_and_macro_free():
    require_libreoffice()
    assert build_template.check() == []


def test_signature_detects_layout_changes(tmp_path):
    """A style-, width- or tab-only change must make the template stale."""
    base = build_template.signature(build_template.TEMPLATE)
    for change in ("fill", "number_format", "width", "tab"):
        wb = openpyxl.load_workbook(build_template.TEMPLATE)
        ws = wb["Control"]
        if change == "fill":
            ws["C1"].fill = openpyxl.styles.PatternFill("solid", fgColor="FF00FF00")
        elif change == "number_format":
            ws["D7"].number_format = "0.000"
        elif change == "width":
            ws.column_dimensions["C"].width = 99
        else:
            ws.sheet_properties.tabColor = "FF00FF00"
        path = tmp_path / f"{change}.xlsx"
        wb.save(path)
        assert build_template.signature_differences(base, build_template.signature(path)), change


def test_build_from_template_runs_and_reconciles(tmp_path):
    require_libreoffice()
    out = tmp_path / "from-template.xlsx"
    errors = lo_runner.run(
        out,
        ["M_Setup.FinishWorkbook", "M_Main.RunFRTB_Silent", "TEST_Regression.Test_RunRegression_Silent"],
        input_book=build_template.TEMPLATE,
    )
    assert errors == []
    wb = openpyxl.load_workbook(out, data_only=True)
    assert str(wb["Test_Expected"].cell(3, FIRST_COL).value).startswith("Result: PASS")
    assert log_rows(wb, "ERROR") == []
    assert reconcile(wb) == []
