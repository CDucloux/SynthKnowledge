"""Erreurs pydantic reformulées en français, une ligne par problème.

Le chemin de la clé est donné en tête (`params.osc.wave1`, `sources[2].url`,
rangs à partir de 1). Partagé par la validation des fiches et des schémas.
"""

import types
import typing
from collections.abc import Iterator
from typing import Any

from pydantic import BaseModel, ValidationError
from pydantic_core import ErrorDetails

MESSAGES = {
    "missing": "manquant",
    "string_type": "doit être un texte",
    "int_type": "doit être un nombre entier",
    "float_type": "doit être un nombre",
    "bool_type": "doit être true ou false",
    "list_type": "doit être une liste",
    "dict_type": "doit être un objet",
    "model_type": "doit être un objet",
    "model_attributes_type": "doit être un objet",
    "too_short": "ne doit pas être vide",
}


def describe_all(
    error: ValidationError, model: type[BaseModel], prefix: str = ""
) -> list[str]:
    """Toutes les lignes d'une ValidationError (`prefix` : chemin parent)."""
    lines = []
    for detail in error.errors():
        for line in describe(detail, model):
            lines.append(f"{prefix}.{line}" if prefix else line)
    return lines


def describe(detail: ErrorDetails, model: type[BaseModel]) -> Iterator[str]:
    """Une ligne par problème (un validateur peut en signaler plusieurs)."""
    where = location(detail["loc"])
    prefix = f"{where} : " if where else ""
    for line in _message(detail, model).splitlines():
        yield prefix + line


def location(loc: tuple[int | str, ...]) -> str:
    """('sources', 0, 'url') → « sources[1].url » (rangs à partir de 1)."""
    out = ""
    for part in loc:
        if isinstance(part, int):
            out += f"[{part + 1}]"
        elif str(part).startswith(("function-", "list[")):
            continue  # étapes internes de pydantic (validateurs, unions)
        else:
            out += f".{part}" if out else str(part)
    return out


def _message(detail: ErrorDetails, model: type[BaseModel]) -> str:
    if detail["type"] == "extra_forbidden":
        allowed = ", ".join(_fields_at(model, detail["loc"][:-1]))
        return f"clé inconnue (attendu : {allowed})"
    return describe_message(detail)


def describe_message(detail: ErrorDetails) -> str:
    """Message d'une erreur, sans son chemin."""
    kind, value = detail["type"], detail["input"]
    if kind in MESSAGES:
        return MESSAGES[kind]
    if kind == "literal_error":
        expected = detail.get("ctx", {}).get("expected", "")
        expected = expected.replace("'", "").replace(" or ", ", ")
        return f"« {value} » n'est pas une option ({expected})"
    if kind == "value_error":
        return detail["msg"].removeprefix("Value error, ")
    return detail["msg"]


def _fields_at(
    model: type[BaseModel], loc: tuple[int | str, ...]
) -> list[str]:
    """Clés attendues à l'emplacement `loc` (pour « clé inconnue »)."""
    current: type[BaseModel] | None = model
    for part in loc:
        if isinstance(part, int) or current is None:
            continue
        current = _model_in(current.model_fields[part].annotation)
    return list(current.model_fields) if current else []


def _model_in(annotation: Any) -> type[BaseModel] | None:
    """Premier modèle pydantic dans un type (list[X], X | None…)."""
    if isinstance(annotation, type) and issubclass(annotation, BaseModel):
        return annotation
    origin = typing.get_origin(annotation)
    if isinstance(annotation, types.UnionType) or origin in (
        list,
        typing.Union,
        typing.Annotated,
    ):
        for arg in typing.get_args(annotation):
            if found := _model_in(arg):
                return found
    return None
