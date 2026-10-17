"""Build, or check, the macro-free workbook template.

The template src/workbook/FRTB_Template.xlsx is the workbook that
M_Setup.BuildWorkbook produces, saved without a VBA project, without sheet
buttons and without personal document properties. Builds start from it and
import the modules of src/modules (and tests/modules); M_Setup.FinishWorkbook
then adds the buttons and window settings a template cannot hold.

The build runs headless in LibreOffice Calc. tools/Build-Workbook.ps1
-Template produces the same content through Excel.

Usage:
    python3 tools/build_template.py          # rewrite the template
    python3 tools/build_template.py --check  # exit 1 if it differs from a fresh build
"""

from __future__ import annotations

import argparse
import sys
import tempfile
import zipfile
from pathlib import Path

import openpyxl

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "tools"))

import lo_runner  # noqa: E402

TEMPLATE = lo_runner.TEMPLATE


def _strip(doc) -> None:
    """Remove sheet controls and personal document properties."""
    sheets = doc.Sheets
    for i in range(sheets.Count):
        page = sheets.getByIndex(i).DrawPage
        while page.Count > 0:
            page.remove(page.getByIndex(0))
    props = doc.DocumentProperties
    props.Author = ""
    props.ModifiedBy = ""
    props.Title = ""
    props.Subject = ""
    props.Description = ""


def build(output: Path) -> None:
    errors = lo_runner.run(output, ["M_Setup.BuildWorkbook"], post_process=_strip)
    if errors:
        raise RuntimeError("; ".join(errors))


def cell_values(path: Path) -> dict:
    wb = openpyxl.load_workbook(path, data_only=True)
    out = {}
    for ws in wb.worksheets:
        for row in ws.iter_rows():
            for c in row:
                if c.value is not None:
                    out[(ws.title, c.coordinate)] = c.value
    return {"sheets": wb.sheetnames, "cells": out}


def package_problems(path: Path) -> list[str]:
    """Return what makes the file unsuitable as a macro-free template."""
    problems = []
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        if any("vbaProject" in n for n in names):
            problems.append("contains a VBA project")
        if any(n.startswith("xl/ctrlProps/") for n in names):
            problems.append("contains form controls")
        core = z.read("docProps/core.xml").decode("utf-8") if "docProps/core.xml" in names else ""
        for tag in ("dc:creator", "cp:lastModifiedBy"):
            start = core.find(f"<{tag}>")
            if start >= 0 and core[start + len(tag) + 2 : core.find(f"</{tag}>")].strip():
                problems.append(f"document property {tag} is not empty")
    return problems


def check() -> list[str]:
    if not TEMPLATE.exists():
        return [f"{TEMPLATE} does not exist"]
    problems = package_problems(TEMPLATE)
    with tempfile.TemporaryDirectory() as tmp:
        fresh = Path(tmp) / "fresh.xlsx"
        build(fresh)
        a, b = cell_values(TEMPLATE), cell_values(fresh)
    if a["sheets"] != b["sheets"]:
        problems.append(f"sheets differ: {a['sheets']} vs {b['sheets']}")
    diff = sorted(set(a["cells"].items()) ^ set(b["cells"].items()), key=str)
    if diff:
        problems.append(f"{len(diff)} cell values differ, first: {diff[:3]}")
    return problems


def main(argv) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args(argv)
    if args.check:
        problems = check()
        for p in problems:
            print("TEMPLATE:", p, file=sys.stderr)
        if not problems:
            print("Template is current and macro-free")
        return 1 if problems else 0
    TEMPLATE.parent.mkdir(parents=True, exist_ok=True)
    build(TEMPLATE)
    problems = package_problems(TEMPLATE)
    for p in problems:
        print("TEMPLATE:", p, file=sys.stderr)
    print(f"Wrote {TEMPLATE.relative_to(REPO_ROOT)}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
