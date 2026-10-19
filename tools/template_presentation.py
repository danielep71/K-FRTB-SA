"""Preserve workbook view/print settings lost by headless VBA compatibility.

Cell content and formatting remain owned by the VBA builder. This small OOXML
normalization step saves view and print properties that the headless host
does not reliably expose through Excel's ActiveWindow and PageSetup APIs.
"""

from __future__ import annotations

import re
import tempfile
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET

NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
ET.register_namespace("", NS)
ET.register_namespace("r", REL)


def _tag(name: str) -> str:
    return f"{{{NS}}}{name}"


def _child(parent, name, **attributes):
    element = parent.find(_tag(name))
    if element is None:
        element = ET.SubElement(parent, _tag(name))
    element.attrib.update({key: str(value) for key, value in attributes.items()})
    return element


def _palette() -> dict[str, str]:
    """Use the VBA palette, converting Excel's BGR Long to OOXML ARGB."""
    source = (Path(__file__).resolve().parents[1] / "src/modules/CORE_Config.bas").read_text()
    colors = {}
    for name, value in re.findall(r"Public Const (TAB_\w+) As Long = (\d+)", source):
        number = int(value)
        colors[name] = f"FF{number & 255:02X}{(number >> 8) & 255:02X}{(number >> 16) & 255:02X}"
    return colors


def normalize(path: Path) -> None:
    """Normalize only views, tab colors and printing; never values or formulas."""
    palette = _palette()
    with zipfile.ZipFile(path) as archive:
        parts = {item.filename: archive.read(item.filename) for item in archive.infolist()}
    book = ET.fromstring(parts["xl/workbook.xml"])
    relations = {r.attrib["Id"]: r.attrib["Target"] for r in ET.fromstring(parts["xl/_rels/workbook.xml.rels"])}
    names = _child(book, "definedNames")
    for defined in list(names):
        if defined.get("name") in ("_xlnm.Print_Area", "_xlnm.Print_Titles"):
            names.remove(defined)
    for index, sheet in enumerate(book.find(_tag("sheets"))):
        name = sheet.attrib["name"]
        target = relations[sheet.attrib[f"{{{REL}}}id"]]
        target = "xl/" + target.lstrip("/").removeprefix("xl/")
        root = ET.fromstring(parts[target])
        props = root.find(_tag("sheetPr"))
        if props is None:
            props = ET.Element(_tag("sheetPr"))
            root.insert(0, props)
        role = "TAB_REFERENCE" if name == "README" else "TAB_TEST" if name == "Test_Expected" else "TAB_OUTPUT" if name in ("Results", "Log") or name.startswith("Out_") else "TAB_INPUT"
        color = props.find(_tag("tabColor"))
        if color is None:
            color = ET.Element(_tag("tabColor"))
            props.insert(0, color)
        color.attrib.clear()
        color.set("rgb", palette[role])
        _child(props, "pageSetUpPr", fitToPage="1")

        frozen_rows = 3 if name == "README" else 6 if name in ("Control", "Test_Expected") or name.startswith("P_") else 5
        frozen_cols = 0 if name == "README" else 3
        for view in root.findall(f"{_tag('sheetViews')}/{_tag('sheetView')}"):
            view.set("showGridLines", "0")
            view.set("topLeftCell", "A1")
            for old in list(view):
                if old.tag in (_tag("pane"), _tag("selection")):
                    view.remove(old)
            pane = ET.Element(_tag("pane"), ySplit=str(frozen_rows), topLeftCell=f"{'D' if frozen_cols else 'A'}{frozen_rows + 1}", activePane="bottomRight" if frozen_cols else "bottomLeft", state="frozen")
            if frozen_cols:
                pane.set("xSplit", str(frozen_cols))
            view.insert(0, pane)
            ET.SubElement(view, _tag("selection"), pane=pane.attrib["activePane"], activeCell=pane.attrib["topLeftCell"], sqref=pane.attrib["topLeftCell"])

        _child(root, "pageMargins", left="0.25", right="0.25", top="0.5", bottom="0.5", header="0.2", footer="0.2")
        setup = _child(root, "pageSetup", paperSize="9", orientation="landscape", fitToWidth="1", fitToHeight="0")
        setup.attrib.pop("scale", None)
        footer = _child(root, "headerFooter")
        footer.clear()
        ET.SubElement(footer, _tag("oddFooter")).text = '&C&"Aptos,Regular"&9Page &P of &N'
        # Bound printing to populated or intentionally styled cells, excluding
        # default column styles that may extend to the worksheet's last column.
        coordinates = [c.attrib["r"] for c in root.findall(f"{_tag('sheetData')}/{_tag('row')}/{_tag('c')}")]
        def column_number(address):
            value = 0
            for letter in re.match(r"[A-Z]+", address).group():
                value = value * 26 + ord(letter) - 64
            return value
        last_col = re.match(r"[A-Z]+", max(coordinates, key=column_number)).group()
        last_row = max(int(re.search(r"\d+", address).group()) for address in coordinates)
        quoted = "'" + name.replace("'", "''") + "'"
        ET.SubElement(names, _tag("definedName"), name="_xlnm.Print_Titles", localSheetId=str(index)).text = f"{quoted}!$1:${frozen_rows}"
        # Outputs grow at run time, so do not freeze their print extent here.
        if role != "TAB_OUTPUT":
            ET.SubElement(names, _tag("definedName"), name="_xlnm.Print_Area", localSheetId=str(index)).text = f"{quoted}!$B$1:${last_col}${last_row}"
        parts[target] = ET.tostring(root, encoding="utf-8", xml_declaration=True)
    # definedNames precedes calcPr/external-link metadata in workbook order.
    book.remove(names)
    sheets_index = list(book).index(book.find(_tag("sheets")))
    book.insert(sheets_index + 1, names)
    parts["xl/workbook.xml"] = ET.tostring(book, encoding="utf-8", xml_declaration=True)
    with tempfile.NamedTemporaryFile(dir=path.parent, suffix=".xlsx", delete=False) as temp:
        replacement = Path(temp.name)
    try:
        with zipfile.ZipFile(replacement, "w", zipfile.ZIP_DEFLATED) as archive:
            for name, content in parts.items():
                archive.writestr(name, content)
        replacement.replace(path)
    finally:
        replacement.unlink(missing_ok=True)
