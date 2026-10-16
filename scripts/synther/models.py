"""Modèles pydantic d'une fiche son.

La structure commune à toutes les fiches est décrite ici ; ce qui dépend de
la machine (paramètres de la façade, blocs `extra`) est généré à partir de
template/schema/<machine>.yaml par `sheet_model()`.
"""

import re
from collections.abc import Callable, Iterable, Iterator
from functools import cache
from typing import Annotated, Any, Literal

from pydantic import (
    AfterValidator,
    BaseModel,
    BeforeValidator,
    ConfigDict,
    Field,
    ValidationError,
    ValidatorFunctionWrapHandler,
    create_model,
    field_validator,
    model_validator,
)
from pydantic_core import InitErrorDetails, PydanticCustomError

from .sheet import load_schema

SEQ_NOTE = re.compile(r"^[A-G][b#]?-?\d$")
CITATION = re.compile(r"\[(\d+)\](?!\()")  # [n], pas un lien [texte](url)


# ---------------------------------------------------------------------------
# Types de base
# ---------------------------------------------------------------------------


def _not_blank(value: str) -> str:
    if not value.strip():
        raise ValueError("ne doit pas être vide")
    return value


def _number_to_str(value: Any) -> Any:
    """Un nombre YAML (`1/16` exclu) accepté là où un texte est attendu."""
    if isinstance(value, (int, float)) and not isinstance(value, bool):
        return str(value)
    return value


def _as_list(value: Any) -> Any:
    return value if isinstance(value, list) else [value]


def _in_range(
    low: float, high: float, hint: str = ""
) -> Callable[[float], float]:
    def check(value: float) -> float:
        if not low <= value <= high:
            raise ValueError(
                f"{value:g} hors plage ({hint or f'{low:g} à {high:g}'})"
            )
        return value

    return check


Text = Annotated[str, AfterValidator(_not_blank)]
TextList = Annotated[list[Text], Field(min_length=1)]
Label = Annotated[str, BeforeValidator(_number_to_str)]


class StrictModel(BaseModel):
    """Objet YAML : clés connues seulement, pas de conversion implicite."""

    model_config = ConfigDict(extra="forbid", strict=True)


# ---------------------------------------------------------------------------
# Structure commune
# ---------------------------------------------------------------------------


class Reference(StrictModel):
    artist: Text
    song: Text
    year: int | str | None = None
    part: str | None = None
    original_synth: str | None = None
    original_synth_short: str | None = None


def _http_url(value: str) -> str:
    if not value.startswith(("http://", "https://")):
        raise ValueError("doit commencer par https://")
    return value


class Source(StrictModel):
    title: Text
    site: str | None = None
    date: str | int | None = None
    url: Annotated[str, AfterValidator(_http_url)] | None = None
    note: str | None = None

    @model_validator(mode="before")
    @classmethod
    def _plain_text(cls, data: Any) -> Any:
        """Une source peut être un simple texte : son titre."""
        if isinstance(data, str):
            return {"title": data}
        if not isinstance(data, dict):
            fields = ", ".join(cls.model_fields)
            raise ValueError(f"doit être un texte ou un objet {{{fields}}}")
        return data


class AnalysisBox(StrictModel):
    title: Text
    text: Text


class Params(StrictModel):
    """Base des réglages de façade générés depuis le schéma."""

    @model_validator(mode="before")
    @classmethod
    def _not_empty(cls, data: Any) -> Any:
        if data == {}:
            raise ValueError("ne doit pas être vide")
        return data


class SheetModel(StrictModel):
    """Fiche son ; `sheet_model()` en dérive une classe par machine."""

    synth: str
    title: Text
    category: str | None = None
    tags: list[str] = []
    confidence: Literal[1, 2, 3]
    reference: Reference
    summary: Text
    params: Params
    steps: TextList
    tweaks: TextList
    playing: TextList
    analysis: Annotated[list[AnalysisBox], Field(min_length=1)]
    traceability: TextList
    sources: Annotated[list[Source], Field(min_length=1)]

    @model_validator(mode="wrap")
    @classmethod
    def _check_citations(
        cls, data: Any, handler: ValidatorFunctionWrapHandler
    ) -> Any:
        """Chaque renvoi [n] des textes pointe vers une source qui existe.

        Contrôle fait en plus des erreurs de structure, pour tout signaler
        d'un coup.
        """
        citations = list(_citation_errors(data))
        try:
            sheet = handler(data)
        except ValidationError as error:
            if not citations:
                raise
            raise ValidationError.from_exception_data(
                cls.__name__,
                [*error.errors(), *citations],  # type: ignore[list-item]
            ) from None
        if citations:
            raise ValidationError.from_exception_data(cls.__name__, citations)
        return sheet


def _citation_errors(data: Any) -> Iterator[InitErrorDetails]:
    if not isinstance(data, dict):
        return
    sources = data.get("sources")
    n_sources = len(sources) if isinstance(sources, list) else 0
    texts = _strings({k: v for k, v in data.items() if k != "sources"})
    for text in texts:
        for match in CITATION.finditer(text):
            n = int(match.group(1))
            if not 1 <= n <= n_sources:
                yield InitErrorDetails(
                    type=PydanticCustomError(
                        "citation",
                        "renvoi [{n}] sans source correspondante "
                        "({count} source(s))",
                        {"n": n, "count": n_sources},
                    ),
                    loc=(),
                    input=text,
                )


def _strings(node: Any) -> Iterator[str]:
    if isinstance(node, str):
        yield node
    elif isinstance(node, dict):
        for child in node.values():
            yield from _strings(child)
    elif isinstance(node, list):
        for child in node:
            yield from _strings(child)


# ---------------------------------------------------------------------------
# Partie propre à la machine, générée depuis template/schema/<machine>.yaml
# ---------------------------------------------------------------------------

Spec = dict[str, Any]


def _literal(values: Iterable[Any]) -> Any:
    """Literal[...] construit à partir d'une liste de valeurs."""
    return Literal.__getitem__(tuple(values))


def _param_type(spec: Spec, options: dict[str, list[list[Any]]]) -> Any:
    """Type pydantic d'un réglage d'après sa spec (type, plage, options)."""
    kind = spec.get("type")
    if "options" in spec:
        choice = _literal(option[0] for option in options[spec["options"]])
        if kind == "list":
            items = list[choice]  # type: ignore[valid-type]
            return Annotated[items, BeforeValidator(_as_list)]
        return choice
    low, high = spec.get("min"), spec.get("max")
    match kind:
        case "clock":
            hint = "position en heures, 7 = MIN à 17 = MAX"
            return Annotated[float, AfterValidator(_in_range(7, 17, hint))]
        case "bool":
            return bool
        case "int" | "number":
            base = int if kind == "int" else float
            if low is None or high is None:
                return base
            check = _in_range(float(low), float(high))
            return Annotated[base, AfterValidator(check)]
        case "str" if "choices" in spec:
            choice = _literal(spec["choices"])
            return Annotated[choice, BeforeValidator(_number_to_str)]
        case "str":
            return Label
    raise ValueError(f"type de paramètre inconnu dans le schéma : {kind!r}")


def _optional_fields(
    specs: dict[str, Spec], options: dict[str, list[list[Any]]]
) -> dict[str, Any]:
    return {
        key: (_param_type(spec, options) | None, None)
        for key, spec in specs.items()
    }


def _params_model(schema: Spec) -> type[BaseModel]:
    sections: dict[str, Any] = {
        section: (
            create_model(
                f"Params_{section}",
                __base__=StrictModel,
                **_optional_fields(specs, schema["options"]),
            )
            | None,
            None,
        )
        for section, specs in schema["params"].items()
    }
    return create_model("MachineParams", __base__=Params, **sections)


def _item_model(name: str, item: dict[str, str]) -> type[BaseModel]:
    """Objet d'une liste `extra` : toutes ses clés sont des textes requis."""
    fields: dict[str, Any] = {key: (Label, ...) for key in item}
    return create_model(name, __base__=StrictModel, **fields)


def _steps_validator(max_steps: int, max_notes: int) -> Any:
    def check(value: str) -> str:
        problems = list(_step_problems(value, max_steps, max_notes))
        if problems:
            raise ValueError("\n".join(problems))
        return value

    return field_validator("steps")(check)


def _step_problems(
    steps: str, max_steps: int, max_notes: int
) -> Iterator[str]:
    """Jetons : note (Bb4), accord (G3+Bb3), « . » silence, « _ » liaison."""
    tokens = [t for t in steps.split() if t != "|"]
    if not tokens:
        yield "ne doit pas être vide"
    if len(tokens) > max_steps:
        yield f"{len(tokens)} pas, maximum {max_steps}"
    chord = ", accord G3+Bb3+D4" if max_notes > 1 else ""
    for i, token in enumerate(tokens, 1):
        if token in (".", "_"):
            continue
        notes = token.split("+")
        if not all(SEQ_NOTE.match(note) for note in notes):
            yield (
                f"pas {i} « {token} » invalide (note comme Bb4 / C5 / F#3"
                f"{chord}, « . » silence, « _ » liaison)"
            )
        elif len(notes) > max_notes:
            yield (
                f"pas {i} « {token} » : {len(notes)} notes, "
                f"maximum {max_notes} sur cette machine"
            )
    if tokens and tokens[0] == "_":
        yield "le pas 1 ne peut pas être une liaison"


def _sequence_model(spec: Spec, options: dict[str, Any]) -> type[BaseModel]:
    fields: dict[str, Any] = {
        "steps": (Label, ...),
        **_optional_fields(spec["fields"], options),
    }
    if "transpose" in spec:
        transpose = _item_model("Transpose", spec["transpose"])
        fields["transpose"] = (list[transpose] | None, None)  # type: ignore[valid-type]
    validators = {
        "steps_tokens": _steps_validator(
            spec["max_steps"], spec.get("max_notes", 1)
        )
    }
    return create_model(
        "Sequence",
        __base__=StrictModel,
        __validators__=validators,
        **fields,
    )


def _extra_fields(schema: Spec) -> dict[str, Any]:
    """Blocs propres à la machine (séquence, settings…), tous optionnels."""
    fields: dict[str, Any] = {}
    for key, spec in schema.get("extra", {}).items():
        if spec["type"] == "sequence":
            model = _sequence_model(spec, schema["options"])
            fields[key] = (model | None, None)
        else:
            item = _item_model(key.capitalize(), spec["item"])
            fields[key] = (list[item] | None, None)  # type: ignore[valid-type]
    return fields


@cache
def sheet_model(machine: str) -> type[SheetModel]:
    """Classe de fiche pour une machine, d'après son schéma."""
    schema = load_schema(machine)
    return create_model(
        f"Sheet_{machine.replace('-', '_')}",
        __base__=SheetModel,
        params=(_params_model(schema), ...),
        **_extra_fields(schema),
    )
