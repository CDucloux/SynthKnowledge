"""Compilation Typst : chaque fiche tient en 2 pages, garde-fous du template.

Nécessite le paquet Python `typst` (extra `typst` de pyproject.toml) ;
ignoré s'il manque. Les PDF sont écrits dans un dossier temporaire.
"""

from pathlib import Path

import pytest

from synther import FONTS_DIR, ROOT, SHEET_TEMPLATE, THEORY_DIR
from synther.compiler import page_count

from .test_sounds import SOUNDS

typst = pytest.importorskip("typst")


def compile_pdf(source: Path, output: Path, son: str | None = None) -> None:
    """Compile avec la racine `/` : le YAML peut être hors du dépôt."""
    typst.compile(
        str(ROOT / source),
        output=str(output),
        root="/",
        font_paths=[str(ROOT / FONTS_DIR)],
        sys_inputs={"son": son} if son else {},
    )


@pytest.mark.parametrize("path", SOUNDS, ids=str)
def test_sheet_compiles_on_two_pages(path: Path, tmp_path: Path) -> None:
    pdf = tmp_path / "fiche.pdf"
    compile_pdf(SHEET_TEMPLATE, pdf, son=str(ROOT / path))
    assert page_count(pdf) == 2, "page 1 trop longue : raccourcir les textes"


@pytest.mark.parametrize(
    "path", sorted((ROOT / THEORY_DIR).glob("*.typ")), ids=lambda p: p.name
)
def test_theory_compiles(path: Path, tmp_path: Path) -> None:
    pdf = tmp_path / "theorie.pdf"
    compile_pdf(path.relative_to(ROOT), pdf)
    assert page_count(pdf) >= 1


def test_unknown_section_is_refused(tmp_path: Path) -> None:
    """Garde-fou du template (check-params), en plus de la validation."""
    thriller = (ROOT / "sounds/messenger/thriller-bass.yaml").read_text(
        encoding="utf-8"
    )
    bad = tmp_path / "fiche.yaml"
    bad.write_text(
        thriller.replace("\n  osc:\n", "\n  oscillo:\n"), encoding="utf-8"
    )
    with pytest.raises(typst.TypstError, match="Section inconnue « oscillo »"):
        compile_pdf(SHEET_TEMPLATE, tmp_path / "fiche.pdf", son=str(bad))
