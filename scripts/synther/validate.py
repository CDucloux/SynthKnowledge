"""Validation d'une fiche contre template/schema/<machine>.yaml.

Chaque vérification est un générateur de messages d'erreur ; validate() les enchaîne
pour tout signaler d'un coup.
"""
import os
import re

from . import MACHINES
from .sheet import load_schema

FORBIDDEN_DASHES = ("\u2014", "\u2013")  # cadratin, demi-cadratin

# Clés de premier niveau communes à toutes les fiches : clé → obligatoire
TOP_KEYS = {
    "synthe": True, "titre": True, "categorie": False, "tags": False, "confiance": True,
    "reference": True, "resume": True, "params": True, "etapes": True, "oreille": True,
    "jeu": True, "analyse": True, "tracabilite": True, "sources": True,
}
TEXT_LISTS = ("etapes", "oreille", "jeu", "tracabilite")
REFERENCE_KEYS = ("artiste", "morceau", "annee", "passage", "synthe_origine", "synthe_court")
SOURCE_KEYS = ("titre", "site", "date", "url", "note")
SEQ_NOTE = re.compile(r"^[A-G][b#]?-?\d$")
CITATION = re.compile(r"\[(\d+)\](?!\()")  # [n], pas un lien [texte](url)


def validate(path, raw, data):
    """Renvoie la liste des erreurs de la fiche (vide si elle est valide)."""
    errors = list(check_dashes(raw))
    if not isinstance(data, dict):
        return errors + ["le fichier ne contient pas un objet YAML"]
    machine = data.get("synthe")
    if machine not in MACHINES:
        return errors + [f"synthe : « {machine} » inconnu ({', '.join(MACHINES)})"]
    schema = load_schema(machine)
    checks = (
        _check_folder(path, machine),
        _check_top_keys(data, schema.get("extra", {})),
        _check_reference(data),
        _check_texts(data),
        _check_sources(data.get("sources") or []),
        _check_extras(data, schema),
        _check_params(data.get("params") or {}, schema),
        _check_citations(data),
    )
    return errors + [e for check in checks for e in check]


def check_dashes(text):
    for n, line in enumerate(text.splitlines(), 1):
        for ch in FORBIDDEN_DASHES:
            if ch in line:
                yield f"ligne {n} : tiret interdit (U+{ord(ch):04X}), utiliser « : », « , » ou des parenthèses"


# ---------------------------------------------------------------------------
# Structure de la fiche
# ---------------------------------------------------------------------------

def _check_folder(path, machine):
    folder = os.path.basename(os.path.dirname(path))
    if folder != machine:
        yield f"synthe : « {machine} » mais le fichier est dans sounds/{folder}/"


def _check_top_keys(data, extra):
    for key in data:
        if key not in TOP_KEYS and key not in extra:
            yield f"clé inconnue « {key} » (attendu : {', '.join([*TOP_KEYS, *extra])})"
    for key, required in TOP_KEYS.items():
        if required and data.get(key) in (None, "", [], {}):
            yield f"« {key} » manquant ou vide"
    if "confiance" in data and data["confiance"] not in (1, 2, 3):
        yield f"confiance : {data['confiance']!r} doit valoir 1, 2 ou 3"


def _check_reference(data):
    ref = data.get("reference") or {}
    if not isinstance(ref, dict):
        yield "reference : doit être un objet"
        ref = {}
    for key in ref:
        if key not in REFERENCE_KEYS:
            yield f"reference : clé inconnue « {key} » (attendu : {', '.join(REFERENCE_KEYS)})"
    for key in ("artiste", "morceau"):
        if not ref.get(key):
            yield f"reference.{key} manquant"


def _check_texts(data):
    for key in TEXT_LISTS:
        if key in data:
            yield from check_list(key, data[key], "str")
    if "analyse" in data:
        yield from check_list("analyse", data["analyse"], ("titre", "texte"), required=("titre", "texte"))


def _check_sources(sources):
    if not isinstance(sources, list):
        yield "sources : doit être une liste"
        return
    for i, src in enumerate(sources, 1):
        if isinstance(src, str):
            continue
        if not isinstance(src, dict):
            yield f"sources[{i}] : doit être un texte ou un objet {{{', '.join(SOURCE_KEYS)}}}"
            continue
        for key in src:
            if key not in SOURCE_KEYS:
                yield f"sources[{i}] : clé inconnue « {key} » (attendu : {', '.join(SOURCE_KEYS)})"
        if not src.get("titre"):
            yield f"sources[{i}] : « titre » manquant"
        if src.get("url") and not str(src["url"]).startswith(("http://", "https://")):
            yield f"sources[{i}].url : doit commencer par https://"


def _check_extras(data, schema):
    """Blocs propres à la machine (séquence, etc.), décrits dans `extra` du schéma."""
    for key, spec in schema.get("extra", {}).items():
        if data.get(key) is None:
            continue
        if spec["type"] == "sequence":
            yield from check_sequence(key, data[key], spec, schema["options"])
        else:
            yield from check_list(key, data[key], tuple(spec["item"]))


def _check_params(params, schema):
    """Réglages de la façade : sections, paramètres, types, plages, options."""
    sections = schema["params"]
    for section, values in params.items():
        if section not in sections:
            yield f"params.{section} : section inconnue (attendu : {', '.join(sections)})"
        elif not isinstance(values, dict):
            yield f"params.{section} : doit être un objet"
        else:
            for key, value in values.items():
                spec = sections[section].get(key)
                if spec is None:
                    yield f"params.{section}.{key} : paramètre inconnu (attendu : {', '.join(sections[section])})"
                else:
                    yield from check_value(f"params.{section}.{key}", value, spec, schema["options"])


def _check_citations(data):
    """Chaque renvoi [n] des textes pointe vers une source qui existe."""
    sources = data.get("sources")
    n_sources = len(sources) if isinstance(sources, list) else 0
    for text in _strings({k: v for k, v in data.items() if k != "sources"}):
        for m in CITATION.finditer(text):
            if not 1 <= int(m.group(1)) <= n_sources:
                yield f"renvoi [{m.group(1)}] sans source correspondante ({n_sources} source(s))"


def _strings(node):
    if isinstance(node, str):
        yield node
    elif isinstance(node, (dict, list)):
        for child in node.values() if isinstance(node, dict) else node:
            yield from _strings(child)


# ---------------------------------------------------------------------------
# Vérifications élémentaires (valeur, liste, séquence)
# ---------------------------------------------------------------------------

def _is_number(v):
    return isinstance(v, (int, float)) and not isinstance(v, bool)


def check_value(where, value, spec, options):
    """Une valeur de paramètre contre sa spec du schéma (type, plage, options)."""
    allowed = [o[0] for o in options.get(spec["options"], [])] if "options" in spec else None
    kind = spec.get("type")
    if allowed is not None:
        for v in (value if kind == "list" and isinstance(value, list) else [value]):
            if v not in allowed:
                yield f"{where} : « {v} » n'est pas une option ({', '.join(map(str, allowed))})"
    elif kind == "clock":
        if not _is_number(value) or not 7 <= value <= 17:
            yield f"{where} : {value!r} hors plage (position en heures, 7 = MIN à 17 = MAX)"
    elif kind == "bool":
        if not isinstance(value, bool):
            yield f"{where} : {value!r} doit être true ou false"
    elif kind in ("int", "number"):
        if not _is_number(value) or (kind == "int" and not isinstance(value, int)):
            yield f"{where} : {value!r} doit être un nombre{' entier' if kind == 'int' else ''}"
        elif not spec.get("min", value) <= value <= spec.get("max", value):
            yield f"{where} : {value} hors plage ({spec['min']} à {spec['max']})"
    elif kind == "str":
        if not isinstance(value, (str, int, float)) or isinstance(value, bool):
            yield f"{where} : {value!r} doit être un texte"
        elif "choices" in spec and str(value) not in spec["choices"]:
            yield f"{where} : « {value} » inconnu ({', '.join(spec['choices'])})"


def check_list(where, value, item, required=()):
    """Liste de textes non vides (item = "str") ou d'objets aux clés `item`."""
    if not isinstance(value, list):
        yield f"{where} : doit être une liste"
        return
    for i, x in enumerate(value, 1):
        if item == "str":
            if not isinstance(x, str) or not x.strip():
                yield f"{where}[{i}] : doit être un texte non vide"
        elif not isinstance(x, dict):
            yield f"{where}[{i}] : doit être un objet {{{', '.join(item)}}}"
        else:
            for key in x:
                if key not in item:
                    yield f"{where}[{i}] : clé inconnue « {key} » (attendu : {', '.join(item)})"
            for key in required:
                if not x.get(key):
                    yield f"{where}[{i}] : « {key} » manquant"


def check_sequence(where, value, spec, options):
    """Séquence de pas : note / accord (« G3+Bb3 ») / « . » / « _ », réglages de lecture, transpositions."""
    allowed = ("steps", *spec["fields"], *(("transpose",) if "transpose" in spec else ()))
    if not isinstance(value, dict):
        yield f"{where} : doit être un objet {{{', '.join(allowed)}}}"
        return
    for key in value:
        if key not in allowed:
            yield f"{where} : clé inconnue « {key} » (attendu : {', '.join(allowed)})"
    yield from _check_steps(f"{where}.steps", value.get("steps", ""), spec)
    for key, field in spec["fields"].items():
        if key in value:
            yield from check_value(f"{where}.{key}", value[key], field, options)
    if "transpose" in value and "transpose" in spec:  # sinon déjà signalé : clé inconnue
        keys = tuple(spec["transpose"])
        yield from check_list(f"{where}.transpose", value["transpose"], keys, required=keys)


def _check_steps(where, steps, spec):
    tokens = [t for t in str(steps).split() if t != "|"]
    max_notes = spec.get("max_notes", 1)
    if not tokens:
        yield f"{where} : manquant ou vide"
    if len(tokens) > spec["max_steps"]:
        yield f"{where} : {len(tokens)} pas, maximum {spec['max_steps']}"
    for i, token in enumerate(tokens, 1):
        if token in (".", "_"):
            continue
        notes = token.split("+")
        if not all(SEQ_NOTE.match(n) for n in notes):
            yield (f"{where} : pas {i} « {token} » invalide (note comme Bb4 / C5 / F#3"
                   f"{', accord G3+Bb3+D4' if max_notes > 1 else ''}, « . » silence, « _ » liaison)")
        elif len(notes) > max_notes:
            yield f"{where} : pas {i} « {token} » : {len(notes)} notes, maximum {max_notes} sur cette machine"
    if tokens and tokens[0] == "_":
        yield f"{where} : le pas 1 ne peut pas être une liaison"
