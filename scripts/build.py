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
import glob
import os
import sys
from collections.abc import Iterator

import yaml

from synther import MACHINES, ROOT
from synther.compiler import compile_sheet, compile_typst, page_count
from synther.readme import update_previews, update_readme
from synther.sheet import Sheet, read_yaml, yaml_error_message
from synther.validate import check_dashes, validate

COMMANDS = ("sheets", "check", "theory", "previews")


def fail(name: str, errors: list[str]) -> None:
    print(f"✗ {name}", file=sys.stderr)
    for e in errors:
        print(f"    {e}", file=sys.stderr)


def load_valid(path: str) -> Sheet | None:
    """La fiche si elle est lisible et valide, sinon None.

    Les erreurs sont affichées au passage.
    """
    try:
        raw, data = read_yaml(path)
    except yaml.YAMLError as e:
        fail(path, [yaml_error_message(e)])
        return None
    if errors := validate(path, raw, data):
        fail(path, errors)
        return None
    return Sheet(path, data)


def build_sheet(sheet: Sheet) -> bool:
    try:
        compile_sheet(sheet)
    except Exception as e:  # erreur Typst : message déjà explicite
        fail(sheet.source, ["compilation", str(e)])
        return False
    if (n := page_count(sheet.pdf_path)) != 2:
        fail(
            sheet.pdf_path,
            [
                f"{n} pages au lieu de 2 (page 1 fiche, page 2 anatomie"
                " du son) : raccourcir les textes"
            ],
        )
        return False
    print(f"✓ {sheet.pdf_path}")
    return True


def readme_sheets() -> Iterator[Sheet]:
    """Toutes les fiches lisibles de sounds/.

    Une fiche illisible reste hors du tableau (déjà signalée).
    """
    for path in sorted(glob.glob("sounds/*/*.yaml")):
        try:
            data = read_yaml(path)[1]
        except yaml.YAMLError:
            continue
        if isinstance(data, dict) and data.get("synth") in MACHINES:
            yield Sheet(path, data)


def cmd_sheets(files: list[str], compile_: bool = True) -> bool:
    ok = True
    for path in files or sorted(glob.glob("sounds/*/*.yaml")):
        sheet = load_valid(path)
        if sheet is None:
            ok = False
        elif not compile_:
            print(f"✓ {path} (valide)")
        else:
            ok = build_sheet(sheet) and ok
    if compile_:
        update_readme(list(readme_sheets()))
    return ok


def cmd_theory(files: list[str]) -> bool:
    ok = True
    for path in files or sorted(glob.glob("theory/*.typ")):
        with open(path, encoding="utf-8") as f:
            if errors := list(check_dashes(f.read())):
                fail(path, errors)
                ok = False
                continue
        out = (
            f"sheets/theory/{os.path.splitext(os.path.basename(path))[0]}.pdf"
        )
        compile_typst(path, out)
        print(f"✓ {out}")
    return ok


def main(argv: list[str]) -> bool:
    if not argv or argv[0] not in (*COMMANDS, "-h", "--help"):
        argv = ["sheets", *argv]
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument("command", choices=COMMANDS, help="défaut : sheets")
    ap.add_argument(
        "files", nargs="*", help="fichiers à traiter (défaut : tous)"
    )
    args = ap.parse_args(argv)

    # Chemins donnés depuis le dossier courant, puis travail à la racine.
    files = [os.path.relpath(os.path.abspath(f), ROOT) for f in args.files]
    os.chdir(ROOT)
    if args.command == "previews":
        update_previews()
        return True
    if args.command == "theory":
        return cmd_theory(files)
    return cmd_sheets(files, compile_=args.command == "sheets")


if __name__ == "__main__":
    sys.exit(0 if main(sys.argv[1:]) else 1)
