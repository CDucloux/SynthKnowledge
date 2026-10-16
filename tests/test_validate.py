"""Messages d'erreur de la validation, sur des fiches fausses."""

from typing import Any

import pytest

from synther.validate import InvalidSheetError, _location, load_sheet

from .conftest import WriteSheet


def errors_of(path: str) -> list[str]:
    with pytest.raises(InvalidSheetError) as info:
        load_sheet(path)
    return info.value.errors


def test_valid_copy_loads(
    write_sheet: WriteSheet, thriller: dict[str, Any]
) -> None:
    sheet = load_sheet(write_sheet(thriller))
    assert sheet.role == "Bass"
    assert sheet.reference.artist == "Michael Jackson"


def test_unreadable_yaml(write_sheet: WriteSheet) -> None:
    [error] = errors_of(write_sheet(None, raw="title: [ouvert\n"))
    assert error.startswith("YAML illisible (ligne")


def test_not_an_object(write_sheet: WriteSheet) -> None:
    assert errors_of(write_sheet(["a"])) == [
        "le fichier ne contient pas un objet YAML"
    ]


def test_unknown_synth(
    write_sheet: WriteSheet, thriller: dict[str, Any]
) -> None:
    thriller["synth"] = "jupiter-8"
    [error] = errors_of(write_sheet(thriller))
    assert error.startswith("synth : « jupiter-8 » inconnu")


def test_wrong_folder(
    write_sheet: WriteSheet, thriller: dict[str, Any]
) -> None:
    assert errors_of(write_sheet(thriller, folder="minilogue-xd")) == [
        "synth : « messenger » mais le fichier est dans sounds/minilogue-xd/"
    ]


def test_forbidden_dashes(write_sheet: WriteSheet) -> None:
    raw = "synth: messenger\ntitle: a \u2014 b\nsummary: c \u2013 d\n"
    errors = errors_of(write_sheet(None, raw=raw))
    assert "ligne 2 : tiret interdit (U+2014)" in errors[0]
    assert "ligne 3 : tiret interdit (U+2013)" in errors[1]


def test_all_errors_at_once(
    write_sheet: WriteSheet, thriller: dict[str, Any]
) -> None:
    del thriller["summary"]
    thriller["params"]["osc"]["wave1"] = 18
    thriller["params"]["lfo1"]["wave"] = "sinus"
    thriller["params"]["filter"]["couleur"] = 12
    thriller["sources"][0] = {"title": "x", "url": "www.exemple.fr"}
    thriller["steps"].append(f"voir [{len(thriller['sources']) + 1}]")
    errors = errors_of(write_sheet(thriller))
    assert "summary : manquant" in errors
    assert "params.osc.wave1 : 18 hors plage" in "\n".join(errors)
    assert (
        "params.lfo1.wave : « sinus » n'est pas une option "
        "(tri, saw, ramp, sqr)" in errors
    )
    unknown = [e for e in errors if e.startswith("params.filter.couleur")]
    assert unknown and "clé inconnue (attendu : " in unknown[0]
    assert "sources[1].url : doit commencer par https://" in errors
    assert any("sans source correspondante" in e for e in errors)


def test_sequence_steps(
    write_sheet: WriteSheet, thriller: dict[str, Any]
) -> None:
    thriller["sequence"] = {"steps": "_ C5 H2 C5+E5"}
    errors = errors_of(write_sheet(thriller))
    assert "sequence.steps : le pas 1 ne peut pas être une liaison" in errors
    assert any("pas 3 « H2 » invalide" in e for e in errors)
    assert any("pas 4 « C5+E5 » : 2 notes, maximum 1" in e for e in errors)


@pytest.mark.parametrize(
    ("loc", "expected"),
    [
        (("sources", 0, "url"), "sources[1].url"),
        (
            ("params", "osc", "function-after[check()]", "wave1"),
            "params.osc.wave1",
        ),
        ((), ""),
    ],
)
def test_location(loc: tuple[int | str, ...], expected: str) -> None:
    assert _location(loc) == expected
