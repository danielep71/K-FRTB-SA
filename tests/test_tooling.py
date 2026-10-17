"""Repository tooling checks: VBA static lint and generated expected values."""

import subprocess
import sys
from pathlib import Path

import vba_lint
from conftest import require_libreoffice

REPO_ROOT = Path(__file__).resolve().parents[1]


def test_vba_lint_is_clean():
    assert vba_lint.main() == 0


def test_expected_values_in_setup_are_current():
    require_libreoffice()
    proc = subprocess.run(
        [sys.executable, str(REPO_ROOT / "tools" / "update_expected.py"), "--check"],
        capture_output=True,
        text=True,
        timeout=300,
    )
    assert proc.returncode == 0, proc.stdout + proc.stderr
