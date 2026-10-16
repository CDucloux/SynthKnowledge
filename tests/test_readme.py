"""Tableau du README : colonnes calculées et remplacement entre marqueurs."""

import pytest

from synther.models import Reference
from synther.readme import Row, _origin, _replace_between_markers
from synther.validate import load_sheet


def ref(**fields: str) -> Reference:
    return Reference(artist="A", song="S", **fields)


@pytest.mark.parametrize(
    ("reference", "expected"),
    [
        (ref(original_synth_short="ARP 2600", original_synth="x"), "ARP 2600"),
        (ref(original_synth="minimoog (probable) ; ou autre"), "Minimoog"),
        (ref(original_synth="Juno-60, puis Jupiter"), "Juno-60"),
        (ref(), "?"),
    ],
)
def test_origin(reference: Reference, expected: str) -> None:
    assert _origin(reference) == expected


@pytest.mark.parametrize(
    ("path", "sound_type"),
    [
        ("sounds/messenger/thriller-bass.yaml", "Basse"),
        ("sounds/minilogue-xd/jump-brass.yaml", "Cuivres"),
    ],
)
def test_row(path: str, sound_type: str) -> None:
    row = Row.of(load_sheet(path))
    assert row.type == sound_type
    assert row.pdf.startswith("sheets/") and row.pdf.endswith(".pdf")
    assert row.markdown().startswith(f"| **{row.artist}** |")


def test_replace_between_markers() -> None:
    text = "avant\n<!-- t:start -->\nvieux\n<!-- t:end -->\naprès"
    assert _replace_between_markers(text, "t", "neuf") == (
        "avant\n<!-- t:start -->\nneuf\n<!-- t:end -->\naprès"
    )


def test_missing_markers() -> None:
    with pytest.raises(SystemExit, match="introuvables"):
        _replace_between_markers("rien", "t", "neuf")
