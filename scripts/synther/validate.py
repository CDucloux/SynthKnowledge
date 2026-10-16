"""Chargement d'une fiche : contrôles du fichier, puis modèle pydantic.

Les erreurs pydantic sont reformulées en français, une ligne par problème,
avec le chemin de la clé (`params.osc.wave1`, `sources[2].url`).
"""

import types
import typing
from collections.abc import Iterator
from pathlib import Path
from typing import Any

import yaml
from pydantic import BaseModel, ValidationError
from pydantic_core import ErrorDetails

from . import MACHINES
from .models import SheetModel, sheet_model
from .sheet import Sheet
from .yamlfile import read_yaml, yaml_error_message

FORBIDDEN_DASHES = ("\u2014", "\u2013")  # cadratin, demi-cadratin

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


class InvalidSheetError(Exception):
    """Fiche illisible ou invalide ; `errors` : une ligne par problème."""

    def __init__(self, path: Path, errors: list[str]) -> None:
        super().__init__(f"{path} : {len(errors)} erreur(s)")
        self.errors = errors


def load_sheet(path: Path) -> Sheet:
    """La fiche validée, ou InvalidSheetError avec toutes ses erreurs."""
    try:
        raw, data = read_yaml(path)
    except FileNotFoundError as error:
        raise InvalidSheetError(path, ["fichier introuvable"]) from error
    except yaml.YAMLError as error:
        raise InvalidSheetError(path, [yaml_error_message(error)]) from error
    model, errors = _validate(path, raw, data)
    if model is None or errors:
        raise InvalidSheetError(path, errors)
    return Sheet(path, model)


def _validate(
    path: Path, raw: str, data: Any
) -> tuple[SheetModel | None, list[str]]:
    """(modèle si la structure est valide, erreurs de toute la fiche)."""
    errors = list(check_dashes(raw))
    if not isinstance(data, dict):
        return None, [*errors, "le fichier ne contient pas un objet YAML"]
    machine = data.get("synth")
    if machine not in MACHINES:
        known = ", ".join(MACHINES)
        return None, [*errors, f"synth : « {machine} » inconnu ({known})"]
    folder = path.parent.name
    if folder != machine:
        errors.append(
            f"synth : « {machine} » mais le fichier est dans sounds/{folder}/"
        )
    model = sheet_model(machine)
    try:
        return model.model_validate(data), errors
    except ValidationError as error:
        for detail in error.errors():
            errors.extend(_describe(detail, model))
        return None, errors


def check_dashes(text: str) -> Iterator[str]:
    for line_number, line in enumerate(text.splitlines(), 1):
        for dash in FORBIDDEN_DASHES:
            if dash in line:
                code = f"U+{ord(dash):04X}"
                yield (
                    f"ligne {line_number} : tiret interdit ({code}), "
                    "utiliser « : », « , » ou des parenthèses"
                )


# ---------------------------------------------------------------------------
# Erreurs pydantic → messages
# ---------------------------------------------------------------------------


def _describe(detail: ErrorDetails, model: type[SheetModel]) -> Iterator[str]:
    """Une ligne par problème (un validateur peut en signaler plusieurs)."""
    where = _location(detail["loc"])
    prefix = f"{where} : " if where else ""
    for line in _message(detail, model).splitlines():
        yield prefix + line


def _location(loc: tuple[int | str, ...]) -> str:
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


def _message(detail: ErrorDetails, model: type[SheetModel]) -> str:
    kind, value = detail["type"], detail["input"]
    if kind in MESSAGES:
        return MESSAGES[kind]
    if kind == "extra_forbidden":
        allowed = ", ".join(_fields_at(model, detail["loc"][:-1]))
        return f"clé inconnue (attendu : {allowed})"
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
