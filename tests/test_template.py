"""The committed workbook template and the build that starts from it."""

from __future__ import annotations

import build_template
import lo_runner
import re
import zipfile

import openpyxl
from conftest import require_libreoffice
from test_vba_engine import FIRST_COL, log_rows, reconcile


def test_template_is_current_and_macro_free():
    require_libreoffice()
    assert build_template.check() == []


def _repack(source, target, part, old, new):
    """Copy a package, replacing one occurrence of old by new in one part."""
    with zipfile.ZipFile(source) as zin, zipfile.ZipFile(target, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)
            if item.filename == part and old:
                text = data.decode("utf-8")
                assert old in text, (part, old)
                data = text.replace(old, new, 1).encode("utf-8")
            zout.writestr(item, data)


def test_signature_detects_layout_changes(tmp_path):
    """A width-, height-, tab-, fill- or format-only change must make the template stale."""
    template = build_template.TEMPLATE
    base = build_template.signature(template)
    control = build_template.sheet_parts(template)["Control"]
    control_xml = zipfile.ZipFile(template).read(control).decode("utf-8")
    sheet_pr = re.search(r"<sheetPr[^>]*>", control_xml).group(0)

    unchanged = tmp_path / "unchanged.xlsx"
    _repack(template, unchanged, control, "", "")
    assert build_template.signature_differences(base, build_template.signature(unchanged)) == []

    cases = {
        "width": (control, 'width="34.75"', 'width="60"'),
        "height": (control, 'ht="26.1"', 'ht="40"'),
        "tab": (control, sheet_pr, sheet_pr + '<tabColor rgb="FF00FF00"/>'),
        "fill": ("xl/styles.xml", "FF265A99", "FF265A98"),
        "number_format": ("xl/styles.xml", 'formatCode="0.0##%"', 'formatCode="0.00%"'),
    }
    for name, (part, old, new) in cases.items():
        path = tmp_path / f"{name}.xlsx"
        _repack(template, path, part, old, new)
        assert build_template.signature_differences(base, build_template.signature(path)), name


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
