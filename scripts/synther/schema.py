"""Schéma d'une machine : template/schema/<machine>.yaml, validé.

Source unique des paramètres d'une machine : le template Typst y lit les
valeurs neutres et les options, `models.py` en tire le modèle des fiches.
Les machines connues sont les schémas présents (`machines()`).
"""

from functools import cache
from pathlib import Path
from typing import Annotated, Any, Literal

import yaml
from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    ValidationError,
    model_validator,
)

from . import ROOT, SCHEMA_DIR
from .errors import describe_all
from .yamlfile import read_yaml, yaml_error_message

ParamType = Literal["clock", "bool", "int", "number", "str", "list"]


class SchemaError(Exception):
    """Schéma de machine illisible ou invalide (une ligne par problème)."""

    def __init__(self, path: Path, errors: list[str]) -> None:
        super().__init__(
            f"{path} : schéma invalide\n"
            + "\n".join(f"    {error}" for error in errors)
        )
        self.path = path
        self.errors = errors


class _SchemaModel(BaseModel):
    """Clés connues seulement (une faute de frappe est une erreur)."""

    model_config = ConfigDict(extra="forbid")


class ParamSpec(_SchemaModel):
    """Un réglage : valeur neutre, puis type ou liste d'options.

    `label`, `unit` et `hide` servent aux réglages de séquence.
    """

    default: Any
    type: ParamType | None = None
    options: str | None = None
    min: float | None = None
    max: float | None = None
    choices: list[str | int | float] | None = None
    label: str | None = None
    unit: str = ""
    hide: bool = False

    @model_validator(mode="after")
    def _consistent(self) -> "ParamSpec":
        if self.type is None and self.options is None:
            raise ValueError("`type` ou `options` requis")
        if self.type == "list" and self.options is None:
            raise ValueError("`type: list` demande `options`")
        if (self.min is None) != (self.max is None):
            raise ValueError("`min` et `max` vont ensemble")
        if self.min is not None and self.max is not None:
            if self.min > self.max:
                raise ValueError(f"min ({self.min:g}) > max ({self.max:g})")
        return self


class ListExtra(_SchemaModel):
    """Bloc YAML en liste d'objets, chaque clé est un texte requis."""

    type: Literal["list"]
    item: dict[str, Literal["str"]]


class SequenceExtra(_SchemaModel):
    """Bloc `sequence` : pas, réglages de lecture, transpositions."""

    type: Literal["sequence"]
    max_steps: Annotated[int, Field(ge=1)]
    max_notes: Annotated[int, Field(ge=1)] = 1
    fields: dict[str, ParamSpec]
    transpose: dict[str, Literal["str"]] | None = None
    transpose_hint: str | None = None


Extra = Annotated[ListExtra | SequenceExtra, Field(discriminator="type")]
# Une option : [clé, libellé affiché sur le panneau].
Option = tuple[str | int | float, str]


class MachineSchema(_SchemaModel):
    name: Annotated[str, Field(min_length=1)]  # nom affiché (README, fiche)
    options: dict[str, list[Option]] = {}
    params: dict[str, dict[str, ParamSpec]]
    extra: dict[str, Extra] = {}

    @model_validator(mode="after")
    def _options_exist(self) -> "MachineSchema":
        """Chaque `options:` cité désigne une liste de `options`."""
        known = ", ".join(self.options) or "aucune"
        for where, spec in self.all_specs():
            if spec.options is not None and spec.options not in self.options:
                raise ValueError(
                    f"{where} : options « {spec.options} » inconnues "
                    f"(listes : {known})"
                )
        return self

    def all_specs(self) -> list[tuple[str, ParamSpec]]:
        """(chemin, spec) de tous les réglages, séquence comprise."""
        specs = [
            (f"params.{section}.{key}", spec)
            for section, keys in self.params.items()
            for key, spec in keys.items()
        ]
        for name, extra in self.extra.items():
            if isinstance(extra, SequenceExtra):
                specs += [
                    (f"extra.{name}.fields.{key}", spec)
                    for key, spec in extra.fields.items()
                ]
        return specs


def schema_path(machine: str) -> Path:
    return SCHEMA_DIR / f"{machine}.yaml"


@cache
def load_schema(machine: str) -> MachineSchema:
    """Schéma validé de `machine` ; SchemaError sinon."""
    path = schema_path(machine)
    try:
        data = read_yaml(ROOT / path)[1]
    except FileNotFoundError as error:
        raise SchemaError(path, ["fichier introuvable"]) from error
    except yaml.YAMLError as error:
        raise SchemaError(path, [yaml_error_message(error)]) from error
    try:
        return MachineSchema.model_validate(data)
    except ValidationError as error:
        raise SchemaError(path, describe_all(error, MachineSchema)) from error


@cache
def machines() -> dict[str, str]:
    """Machines connues : identifiant (nom du schéma) → nom affiché."""
    return {
        path.stem: load_schema(path.stem).name
        for path in sorted((ROOT / SCHEMA_DIR).glob("*.yaml"))
    }
