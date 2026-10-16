"""Non-régression : toutes les fiches du dépôt et leurs PDF."""

import glob
import os

import pytest

from synther import MACHINES, ROOT
from synther.compiler import page_count
from synther.models import sheet_model
from synther.validate import load_sheet

SOUNDS = sorted(
    os.path.relpath(p, ROOT) for p in glob.glob(str(ROOT / "sounds/*/*.yaml"))
)


@pytest.mark.parametrize("machine", MACHINES)
def test_schema_builds_a_model(machine: str) -> None:
    assert sheet_model(machine).__name__.startswith("Sheet_")


def test_every_machine_has_a_schema() -> None:
    schemas = glob.glob(str(ROOT / "template/schema/*.yaml"))
    assert {os.path.basename(p).removesuffix(".yaml") for p in schemas} == set(
        MACHINES
    )


@pytest.mark.parametrize("path", SOUNDS)
def test_sheet_is_valid_and_compiled(path: str) -> None:
    sheet = load_sheet(path)
    assert os.path.exists(sheet.pdf_path), "PDF manquant ou mal nommé"
    assert page_count(sheet.pdf_path) == 2
