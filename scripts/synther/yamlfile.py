"""Lecture des fichiers YAML : fiches son et schémas de machine."""

from functools import cache
from typing import Any

import yaml


def _fix_on_off(node: Any) -> Any:
    """Remet en texte les clés `on` / `off`.

    PyYAML (YAML 1.1) les lit comme les booléens True / False.
    """
    if isinstance(node, dict):
        return {
            ("on" if k is True else "off" if k is False else k): _fix_on_off(v)
            for k, v in node.items()
        }
    if isinstance(node, list):
        return [_fix_on_off(v) for v in node]
    return node


def read_yaml(path: str) -> tuple[str, Any]:
    """Renvoie (texte brut, données).

    Lève yaml.YAMLError si le fichier est illisible.
    """
    with open(path, encoding="utf-8") as f:
        raw = f.read()
    return raw, _fix_on_off(yaml.safe_load(raw))


def yaml_error_message(error: yaml.YAMLError) -> str:
    mark = getattr(error, "problem_mark", None)
    where = (
        f" (ligne {mark.line + 1}, colonne {mark.column + 1})" if mark else ""
    )
    return f"YAML illisible{where} : {getattr(error, 'problem', error)}"


@cache
def load_schema(machine: str) -> dict[str, Any]:
    schema: dict[str, Any] = read_yaml(f"template/schema/{machine}.yaml")[1]
    return schema
