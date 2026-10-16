"""Synther : validation et compilation des fiches (YAML → PDF Typst), mise à jour du README.

Tous les chemins sont relatifs à la racine du dépôt (ROOT) : le point d'entrée
scripts/build.py s'y place avant d'appeler ces modules.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MACHINES = {"messenger": "Moog Messenger", "minilogue-xd": "Korg minilogue XD"}
