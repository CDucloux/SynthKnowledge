#!/usr/bin/env python3
"""Synther : valide et compile les fiches (YAML → PDF Typst).

    scripts/build.py [yaml…]        fiches son (défaut : toutes) + README
    scripts/build.py check [yaml…]  valider seulement, sans compiler
    scripts/build.py theory [typ…]  fiches de théorie (défaut : theory/*.typ)
    scripts/build.py previews       aperçus PNG du README (docs/)

Fiche son : validation pydantic contre template/schema/<machine>.yaml
(clés, types, plages, options, textes, sources, renvois [n]), refus des
tirets cadratin / demi-cadratin, compilation, contrôle « exactement
2 pages », puis tableau du README régénéré.
Compilation : CLI `typst` si présente, sinon paquet Python `typst`.
"""

import argparse
import os
import sys
from collections.abc import Iterator
from pathlib import Path

from synther import ROOT, SHEETS_DIR, SOUNDS_DIR, THEORY_DIR
from synther.compiler import (
    CompileError,
    compile_sheet,
    compile_typst,
    page_count,
)
from synther.readme import update_previews, update_readme
from synther.sheet import Sheet
from synther.validate import InvalidSheetError, check_dashes, load_sheet

COMMANDS = ("sheets", "check", "theory", "previews")


def fail(path: Path, errors: list[str]) -> None:
    print(f"✗ {path}", file=sys.stderr)
    for error in errors:
        print(f"    {error}", file=sys.stderr)


def all_sounds() -> list[Path]:
    return sorted(SOUNDS_DIR.glob("*/*.yaml"))


def load_valid(path: Path) -> Sheet | None:
    """La fiche si elle est lisible et valide, sinon None.

    Les erreurs sont affichées au passage.
    """
    try:
        return load_sheet(path)
    except InvalidSheetError as error:
        fail(path, error.errors)
        return None


def build_sheet(sheet: Sheet) -> bool:
    try:
        compile_sheet(sheet)
    except CompileError as error:
        fail(sheet.source, ["compilation", str(error)])
        return False
    if (pages := page_count(sheet.pdf_path)) != 2:
        message = (
            f"{pages} pages au lieu de 2 (page 1 fiche, page 2 anatomie"
            " du son) : raccourcir les textes"
        )
        fail(sheet.pdf_path, [message])
        return False
    print(f"✓ {sheet.pdf_path}")
    return True


def readme_sheets() -> Iterator[Sheet]:
    """Toutes les fiches valides de sounds/.

    Une fiche invalide reste hors du tableau (signalée par la validation).
    """
    for path in all_sounds():
        try:
            yield load_sheet(path)
        except InvalidSheetError:
            continue


def cmd_sheets(files: list[Path], compile_: bool = True) -> bool:
    all_ok = True
    for path in files or all_sounds():
        sheet = load_valid(path)
        if sheet is None:
            all_ok = False
        elif not compile_:
            print(f"✓ {path} (valide)")
        else:
            all_ok = build_sheet(sheet) and all_ok
    if compile_:
        update_readme(readme_sheets())
    return all_ok


def cmd_theory(files: list[Path]) -> bool:
    all_ok = True
    for source in files or sorted(THEORY_DIR.glob("*.typ")):
        output = SHEETS_DIR / "theory" / f"{source.stem}.pdf"
        try:
            if errors := list(check_dashes(source.read_text("utf-8"))):
                fail(source, errors)
                all_ok = False
                continue
            compile_typst(source, output)
        except CompileError as error:
            fail(source, ["compilation", str(error)])
            all_ok = False
            continue
        print(f"✓ {output}")
    return all_ok


def from_root(path: str) -> Path:
    """Chemin donné depuis le dossier courant, relatif à la racine.

    Absolu s'il est hors du dépôt.
    """
    absolute = Path(path).resolve()
    if absolute.is_relative_to(ROOT):
        return absolute.relative_to(ROOT)
    return absolute


def main(argv: list[str]) -> bool:
    if not argv or argv[0] not in (*COMMANDS, "-h", "--help"):
        argv = ["sheets", *argv]
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("command", choices=COMMANDS, help="défaut : sheets")
    parser.add_argument(
        "files", nargs="*", help="fichiers à traiter (défaut : tous)"
    )
    args = parser.parse_args(argv)

    files = [from_root(path) for path in args.files]
    os.chdir(ROOT)  # voir synther/__init__.py : chemins relatifs à ROOT
    if args.command == "previews":
        update_previews()
        return True
    if args.command == "theory":
        return cmd_theory(files)
    return cmd_sheets(files, compile_=args.command == "sheets")


if __name__ == "__main__":
    sys.exit(0 if main(sys.argv[1:]) else 1)
