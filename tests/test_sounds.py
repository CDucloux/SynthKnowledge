"""Non-régression : toutes les fiches du dépôt et leurs PDF."""

from pathlib import Path

import pytest

from synther import MACHINES, ROOT, SCHEMA_DIR, SOUNDS_DIR
from synther.compiler import page_count
from synther.models import sheet_model
from synther.validate import load_sheet

# Relatifs à la racine (les tests s'y placent, voir conftest.py).
SOUNDS = sorted(
    path.relative_to(ROOT) for path in (ROOT / SOUNDS_DIR).glob("*/*.yaml")
)


@pytest.mark.parametrize("machine", MACHINES)
def test_schema_builds_a_model(machine: str) -> None:
    assert sheet_model(machine).__name__.startswith("Sheet_")


def test_every_machine_has_a_schema() -> None:
    schemas = (ROOT / SCHEMA_DIR).glob("*.yaml")
    assert {schema.stem for schema in schemas} == set(MACHINES)


@pytest.mark.parametrize("path", SOUNDS, ids=str)
def test_sheet_is_valid_and_compiled(path: Path) -> None:
    sheet = load_sheet(path)
    assert sheet.pdf_path.exists(), "PDF manquant ou mal nommé"
    assert page_count(sheet.pdf_path) == 2
