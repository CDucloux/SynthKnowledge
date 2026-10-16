"""Synther : validation et compilation des fiches (YAML → PDF Typst).

Les chemins ci-dessous sont relatifs à la racine du dépôt (ROOT) : le
point d'entrée scripts/build.py s'y place (os.chdir) avant d'appeler ces
modules, et Typst compile avec cette racine. Relatifs, ils s'affichent
tels quels dans les messages et les liens du README.
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

SOUNDS_DIR = Path("sounds")  # sounds/<machine>/<son>.yaml
SHEETS_DIR = Path("sheets")  # sheets/<machine>/[Artiste] Morceau (Rôle).pdf
THEORY_DIR = Path("theory")  # theory/<fiche>.typ
SCHEMA_DIR = Path("template/schema")  # template/schema/<machine>.yaml
SHEET_TEMPLATE = Path("template/sheet.typ")
FONTS_DIR = Path("fonts")
README = Path("README.md")

MACHINES = {"messenger": "Moog Messenger", "minilogue-xd": "Korg minilogue XD"}
