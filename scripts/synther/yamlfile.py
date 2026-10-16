"""Lecture des fichiers YAML : fiches son et schémas de machine."""

from functools import cache
from pathlib import Path
from typing import Any

import yaml

from . import SCHEMA_DIR


def _fix_on_off(node: Any) -> Any:
    """Remet en texte les clés `on` / `off`.

    PyYAML (YAML 1.1) les lit comme les booléens True / False.
    """
    if isinstance(node, dict):
        return {
            _key_as_text(key): _fix_on_off(value)
            for key, value in node.items()
        }
    if isinstance(node, list):
        return [_fix_on_off(item) for item in node]
    return node


def read_yaml(path: Path) -> tuple[str, Any]:
    """Renvoie (texte brut, données).

    Lève yaml.YAMLError si le fichier est illisible.
    """
    raw = path.read_text(encoding="utf-8")
    return raw, _fix_on_off(yaml.safe_load(raw))


def yaml_error_message(error: yaml.YAMLError) -> str:
    mark = getattr(error, "problem_mark", None)
    where = (
        f" (ligne {mark.line + 1}, colonne {mark.column + 1})" if mark else ""
    )
    return f"YAML illisible{where} : {getattr(error, 'problem', error)}"


def _key_as_text(key: Any) -> Any:
    # `is` et non `==` : la clé 1 vaut True mais doit rester 1.
    if key is True:
        return "on"
    if key is False:
        return "off"
    return key


@cache
def load_schema(machine: str) -> dict[str, Any]:
    schema: dict[str, Any] = read_yaml(SCHEMA_DIR / f"{machine}.yaml")[1]
    return schema
