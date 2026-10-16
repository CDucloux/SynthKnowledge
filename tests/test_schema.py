"""Schémas de machine : ceux du dépôt sont valides, les fautes sont dites."""

import re
from collections.abc import Callable, Iterator
from pathlib import Path

import pytest

from synther import ROOT, SCHEMA_DIR, SHEET_TEMPLATE, schema
from synther.models import sheet_model
from synther.schema import SchemaError, load_schema, machines


def clear_caches() -> None:
    for cached in (load_schema, machines, sheet_model):
        cached.cache_clear()


@pytest.mark.parametrize("machine", machines())
def test_schema_builds_a_model(machine: str) -> None:
    assert sheet_model(machine).__name__.startswith("Sheet_")


def test_machine_names_come_from_schemas() -> None:
    assert machines() == {
        "messenger": "Moog Messenger",
        "minilogue-xd": "Korg minilogue XD",
    }


def test_sheet_typ_knows_every_machine() -> None:
    """template/sheet.typ ne peut pas lister les schémas lui-même."""
    source = (ROOT / SHEET_TEMPLATE).read_text(encoding="utf-8")
    declared = re.findall(
        r"^\s+([\w-]+): [\w-]+\.render-sheet,$", source, re.M
    )
    assert set(declared) == set(machines())


EditSchema = Callable[[str, str], list[str]]


@pytest.fixture
def broken_schema(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> Iterator[EditSchema]:
    """Copie du schéma Messenger dans un dépôt temporaire.

    `edit(old, new)` remplace un passage du schéma et renvoie les erreurs.
    """
    folder = tmp_path / SCHEMA_DIR
    folder.mkdir(parents=True)
    text = (ROOT / SCHEMA_DIR / "messenger.yaml").read_text(encoding="utf-8")
    monkeypatch.setattr(schema, "ROOT", tmp_path)
    clear_caches()

    def edit(old: str, new: str) -> list[str]:
        assert old in text
        (folder / "messenger.yaml").write_text(
            text.replace(old, new), encoding="utf-8"
        )
        clear_caches()
        with pytest.raises(SchemaError) as info:
            sheet_model("messenger")
        return info.value.errors

    yield edit
    clear_caches()


def test_unknown_key(broken_schema: EditSchema) -> None:
    [error] = broken_schema("\noptions:", "\noptons:")
    assert error.startswith("optons : clé inconnue (attendu : name, options")


def test_missing_name(broken_schema: EditSchema) -> None:
    assert broken_schema("name: Moog Messenger", "") == ["name : manquant"]


def test_unknown_option_list(broken_schema: EditSchema) -> None:
    [error] = broken_schema("options: octave}", "options: octav}")
    assert "params.osc.oct1 : options « octav » inconnues" in error


def test_min_above_max(broken_schema: EditSchema) -> None:
    [error] = broken_schema("min: -2, max: 2", "min: 2, max: -2")
    assert error == "params.perf.kb_octave : min (2) > max (-2)"


def test_type_or_options_required(broken_schema: EditSchema) -> None:
    [error] = broken_schema(
        "kb_reset: {default: false, type: bool}", "kb_reset: {default: false}"
    )
    assert error == "params.lfo1.kb_reset : `type` ou `options` requis"


def test_default_out_of_range(broken_schema: EditSchema) -> None:
    [error] = broken_schema(
        "tune: {default: 12, type: clock}", "tune: {default: 18, type: clock}"
    )
    assert error.startswith("params.osc.tune.default : 18 hors plage")


def test_default_not_an_option(broken_schema: EditSchema) -> None:
    [error] = broken_schema(
        "oct1: {default: 8, options: octave}",
        "oct1: {default: 5, options: octave}",
    )
    assert error == (
        "params.osc.oct1.default : « 5 » n'est pas une option (4, 8, 16, 32)"
    )
