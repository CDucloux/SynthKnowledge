"""Fiche son : lecture du YAML, schéma de la machine, nommage du PDF."""
from dataclasses import dataclass
from functools import cache

import yaml

from . import MACHINES


def _fix_on_off(node):
    """PyYAML (YAML 1.1) lit les clés `on` / `off` comme des booléens : les remettre en texte."""
    if isinstance(node, dict):
        return {("on" if k is True else "off" if k is False else k): _fix_on_off(v) for k, v in node.items()}
    if isinstance(node, list):
        return [_fix_on_off(v) for v in node]
    return node


def read_yaml(path):
    """Renvoie (texte brut, données). Lève yaml.YAMLError si le fichier est illisible."""
    with open(path, encoding="utf-8") as f:
        raw = f.read()
    return raw, _fix_on_off(yaml.safe_load(raw))


def yaml_error_message(error):
    mark = getattr(error, "problem_mark", None)
    where = f" (ligne {mark.line + 1}, colonne {mark.column + 1})" if mark else ""
    return f"YAML illisible{where} : {getattr(error, 'problem', error)}"


@cache
def load_schema(machine):
    return read_yaml(f"template/schema/{machine}.yaml")[1]


@dataclass(frozen=True)
class Sheet:
    """Une fiche chargée depuis sounds/<machine>/<son>.yaml (données déjà lues)."""
    source: str
    data: dict

    @property
    def machine(self):
        return self.data["synth"]

    @property
    def machine_name(self):
        return MACHINES[self.machine]

    @property
    def reference(self):
        return self.data.get("reference") or {}

    @property
    def role(self):
        """Rôle = titre moins le nom du morceau (« Closer Bass » → « Bass »)."""
        song, title = self.reference.get("song", ""), self.data["title"]
        return title[len(song):].strip() if song and title.startswith(song) else ""

    @property
    def pdf_path(self):
        """« sheets/<machine>/[Artiste] Morceau (Rôle).pdf »"""
        artist, song = self.reference.get("artist", ""), self.reference.get("song", "")
        name = f"[{artist}] {song}" if artist and song else self.data["title"]
        if self.role:
            name += f" ({self.role})"
        return f"sheets/{self.machine}/{name.replace('/', '-')}.pdf"
