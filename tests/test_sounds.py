"""Non-régression : toutes les fiches du dépôt et leurs PDF."""

from pathlib import Path

import pytest

from synther import ROOT, SOUNDS_DIR
from synther.compiler import page_count
from synther.validate import load_sheet

# Relatifs à la racine (les tests s'y placent, voir conftest.py).
SOUNDS = sorted(
    path.relative_to(ROOT) for path in (ROOT / SOUNDS_DIR).glob("*/*.yaml")
)


@pytest.mark.parametrize("path", SOUNDS, ids=str)
def test_sheet_is_valid_and_compiled(path: Path) -> None:
    sheet = load_sheet(path)
    assert sheet.pdf_path.exists(), "PDF manquant ou mal nommé"
    assert page_count(sheet.pdf_path) == 2
