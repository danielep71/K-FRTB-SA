"""Shared fixtures: headless LibreOffice runs of the VBA engine.

Tests that need LibreOffice are skipped when soffice or the Python UNO
bridge is unavailable, unless REQUIRE_LIBREOFFICE=1 is set (as in CI), in
which case they fail instead.
"""

from __future__ import annotations

import importlib.util
import os
import shutil
import sys
from pathlib import Path

import openpyxl
import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT / "tools"))
sys.path.insert(0, str(Path(__file__).resolve().parent))

import lo_runner  # noqa: E402


def _libreoffice_available() -> bool:
    return bool(shutil.which("soffice") or shutil.which("libreoffice")) and importlib.util.find_spec("uno") is not None


def require_libreoffice():
    if not _libreoffice_available():
        if os.environ.get("REQUIRE_LIBREOFFICE") == "1":
            pytest.fail("LibreOffice with the Python UNO bridge is required (REQUIRE_LIBREOFFICE=1)")
        pytest.skip("LibreOffice with the Python UNO bridge is not available")


@pytest.fixture(scope="session")
def lo_default_run(tmp_path_factory):
    """Workbook built, calculated and regression-tested with default data."""
    require_libreoffice()
    out = tmp_path_factory.mktemp("lo") / "default.xlsx"
    errors = lo_runner.run(out, list(lo_runner.DEFAULT_MACROS))
    assert errors == [], errors
    return openpyxl.load_workbook(out, data_only=True)


@pytest.fixture(scope="session")
def lo_default_path(lo_default_run, tmp_path_factory):
    path = tmp_path_factory.mktemp("lo") / "default-copy.xlsx"
    lo_default_run.save(path)
    return path
