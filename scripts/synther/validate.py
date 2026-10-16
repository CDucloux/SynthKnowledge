"""Chargement d'une fiche : contrôles du fichier, puis modèle pydantic.

Les erreurs sont en français, une ligne par problème (voir errors.py).
"""

from collections.abc import Iterator
from pathlib import Path
from typing import Any

import yaml
from pydantic import ValidationError

from .errors import describe_all
from .models import SheetModel, sheet_model
from .schema import machines
from .sheet import Sheet
from .yamlfile import read_yaml, yaml_error_message

FORBIDDEN_DASHES = ("\u2014", "\u2013")  # cadratin, demi-cadratin


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
    if machine not in machines():
        known = ", ".join(machines())
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
        return None, [*errors, *describe_all(error, model)]


def check_dashes(text: str) -> Iterator[str]:
    for line_number, line in enumerate(text.splitlines(), 1):
        for dash in FORBIDDEN_DASHES:
            if dash in line:
                code = f"U+{ord(dash):04X}"
                yield (
                    f"ligne {line_number} : tiret interdit ({code}), "
                    "utiliser « : », « , » ou des parenthèses"
                )
