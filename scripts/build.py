#!/usr/bin/env python3
"""Compile les fiches son SynthKnowledge (YAML → PDF Typst) et met à jour le README.

    scripts/build.py                          toutes les fiches
    scripts/build.py sounds/messenger/x.yaml  une ou plusieurs fiches
    scripts/build.py --check [yaml…]          valider seulement (pas de compilation)
    scripts/build.py --previews               aussi régénérer les aperçus PNG de docs/

Pour chaque fiche : validation contre template/schema/<machine>.yaml (clés, types,
plages, options, structure des textes et des sources, renvois [n]), refus des tirets
quadratins / demi-cadratins, compilation, contrôle « exactement 2 pages », puis
tableau des fiches du README régénéré.
Compilation : CLI `typst` si présente, sinon paquet Python `typst`.
"""
import argparse, glob, os, re, shutil, subprocess, sys, urllib.parse

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

MACHINES = {"messenger": "Moog Messenger", "minilogue-xd": "Korg minilogue XD"}
FORBIDDEN_DASHES = ("\u2014", "\u2013")  # cadratin, demi-cadratin

# ---------------------------------------------------------------------------
# Nommage : « sheets/<machine>/[Artiste] Morceau (Rôle).pdf »
# ---------------------------------------------------------------------------

def role_of(d):
    """Rôle = titre moins le nom du morceau (« Closer Bass » → « Bass »)."""
    morceau = (d.get("reference") or {}).get("morceau", "")
    titre = d["titre"]
    return titre[len(morceau):].strip() if morceau and titre.startswith(morceau) else ""


def sheet_path(d):
    ref = d.get("reference") or {}
    artiste, morceau = ref.get("artiste", ""), ref.get("morceau", "")
    nom = f"[{artiste}] {morceau}" if artiste and morceau else d["titre"]
    if role_of(d):
        nom += f" ({role_of(d)})"
    return f"sheets/{d['synthe']}/{nom.replace('/', '-')}.pdf"

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

def _norm_keys(x):
    """PyYAML (YAML 1.1) lit la clé `on` comme le booléen True : la remettre en texte."""
    if isinstance(x, dict):
        return {("on" if k is True else "off" if k is False else k): _norm_keys(v) for k, v in x.items()}
    if isinstance(x, list):
        return [_norm_keys(v) for v in x]
    return x


def load_schema(machine):
    return _norm_keys(yaml.safe_load(open(f"template/schema/{machine}.yaml", encoding="utf-8")))


def _is_num(v):
    return isinstance(v, (int, float)) and not isinstance(v, bool)


def check_value(where, v, spec, options, errors):
    keys = [o[0] for o in options.get(spec.get("options"), [])] if "options" in spec else None
    t = spec.get("type")
    if t == "list":
        vals = v if isinstance(v, list) else [v]
        for x in vals:
            if keys is not None and x not in keys:
                errors.append(f"{where} : « {x} » n'est pas une option ({', '.join(map(str, keys))})")
        return
    if keys is not None:
        if v not in keys:
            errors.append(f"{where} : « {v} » n'est pas une option ({', '.join(map(str, keys))})")
        return
    if t == "clock":
        if not _is_num(v) or not 7 <= v <= 17:
            errors.append(f"{where} : {v!r} hors plage (position en heures, 7 = MIN à 17 = MAX)")
    elif t == "bool":
        if not isinstance(v, bool):
            errors.append(f"{where} : {v!r} doit être true ou false")
    elif t in ("int", "number"):
        if not _is_num(v) or (t == "int" and not isinstance(v, int)):
            errors.append(f"{where} : {v!r} doit être un nombre{' entier' if t == 'int' else ''}")
        elif not spec.get("min", v) <= v <= spec.get("max", v):
            errors.append(f"{where} : {v} hors plage ({spec['min']} à {spec['max']})")
    elif t == "str":
        if not isinstance(v, (str, int, float)) or isinstance(v, bool):
            errors.append(f"{where} : {v!r} doit être un texte")
        elif "choices" in spec and str(v) not in spec["choices"]:
            errors.append(f"{where} : « {v} » inconnu ({', '.join(spec['choices'])})")


def check_list_of(where, v, item, errors, required=()):
    if not isinstance(v, list):
        errors.append(f"{where} : doit être une liste")
        return
    for i, x in enumerate(v, 1):
        if item == "str":
            if not isinstance(x, str) or not x.strip():
                errors.append(f"{where}[{i}] : doit être un texte non vide")
            continue
        if not isinstance(x, dict):
            errors.append(f"{where}[{i}] : doit être un objet {{{', '.join(item)}}}")
            continue
        for k in x:
            if k not in item:
                errors.append(f"{where}[{i}] : clé inconnue « {k} » (attendu : {', '.join(item)})")
        for k in required:
            if not x.get(k):
                errors.append(f"{where}[{i}] : « {k} » manquant")


TOP = {  # clés communes à toutes les fiches : (obligatoire, vérification)
    "synthe": True, "titre": True, "categorie": False, "tags": False, "confiance": True,
    "reference": True, "resume": True, "params": True, "etapes": True, "oreille": True,
    "jeu": True, "analyse": True, "tracabilite": True, "sources": True,
}
REFERENCE = ("artiste", "morceau", "annee", "passage", "synthe_origine", "synthe_court")
SOURCE = ("titre", "site", "date", "url", "note")


def _strings(x):
    if isinstance(x, str):
        yield x
    elif isinstance(x, dict):
        for v in x.values():
            yield from _strings(v)
    elif isinstance(x, list):
        for v in x:
            yield from _strings(v)


def validate(path, raw, d):
    errors = []
    for ch in FORBIDDEN_DASHES:
        for n, line in enumerate(raw.splitlines(), 1):
            if ch in line:
                errors.append(f"ligne {n} : tiret interdit (U+{ord(ch):04X}), utiliser « : », « , » ou des parenthèses")
    if not isinstance(d, dict):
        return errors + ["le fichier ne contient pas un objet YAML"]
    machine = d.get("synthe")
    if machine not in MACHINES:
        return errors + [f"synthe : « {machine} » inconnu ({', '.join(MACHINES)})"]
    if os.path.basename(os.path.dirname(path)) != machine:
        errors.append(f"synthe : « {machine} » mais le fichier est dans sounds/{os.path.basename(os.path.dirname(path))}/")
    schema = load_schema(machine)
    extra = schema.get("extra", {})

    for k in d:
        if k not in TOP and k not in extra:
            errors.append(f"clé inconnue « {k} » (attendu : {', '.join(list(TOP) + list(extra))})")
    for k, required in TOP.items():
        if required and d.get(k) in (None, "", [], {}):
            errors.append(f"« {k} » manquant ou vide")

    if "confiance" in d and d["confiance"] not in (1, 2, 3):
        errors.append(f"confiance : {d['confiance']!r} doit valoir 1, 2 ou 3")
    ref = d.get("reference") or {}
    if not isinstance(ref, dict):
        errors.append("reference : doit être un objet")
        ref = {}
    for k in ref:
        if k not in REFERENCE:
            errors.append(f"reference : clé inconnue « {k} » (attendu : {', '.join(REFERENCE)})")
    for k in ("artiste", "morceau"):
        if not ref.get(k):
            errors.append(f"reference.{k} manquant")

    for k in ("etapes", "oreille", "jeu", "tracabilite"):
        if k in d:
            check_list_of(k, d[k], "str", errors)
    if "analyse" in d:
        check_list_of("analyse", d["analyse"], ("titre", "texte"), errors, required=("titre", "texte"))
    sources = d.get("sources") or []
    if isinstance(sources, list):
        for i, s in enumerate(sources, 1):
            if isinstance(s, dict):
                for k in s:
                    if k not in SOURCE:
                        errors.append(f"sources[{i}] : clé inconnue « {k} » (attendu : {', '.join(SOURCE)})")
                if not s.get("titre"):
                    errors.append(f"sources[{i}] : « titre » manquant")
                if s.get("url") and not str(s["url"]).startswith(("http://", "https://")):
                    errors.append(f"sources[{i}].url : doit commencer par https://")
            elif not isinstance(s, str):
                errors.append(f"sources[{i}] : doit être un texte ou un objet {{{', '.join(SOURCE)}}}")
    else:
        errors.append("sources : doit être une liste")
    for k, spec in extra.items():
        if k in d and d[k] is not None:
            check_list_of(k, d[k], tuple(spec["item"]), errors)

    # Paramètres de la façade
    params = d.get("params") or {}
    for sec, vals in params.items():
        if sec not in schema["params"]:
            errors.append(f"params.{sec} : section inconnue (attendu : {', '.join(schema['params'])})")
            continue
        if not isinstance(vals, dict):
            errors.append(f"params.{sec} : doit être un objet")
            continue
        for k, v in vals.items():
            spec = schema["params"][sec].get(k)
            if spec is None:
                errors.append(f"params.{sec}.{k} : paramètre inconnu (attendu : {', '.join(schema['params'][sec])})")
            else:
                check_value(f"params.{sec}.{k}", v, spec, schema["options"], errors)

    # Renvois [n] vers des sources qui existent (hors liens [texte](url))
    n_src = len(sources) if isinstance(sources, list) else 0
    for text in _strings({k: v for k, v in d.items() if k != "sources"}):
        for m in re.finditer(r"\[(\d+)\](?!\()", text):
            if not 1 <= int(m.group(1)) <= n_src:
                errors.append(f"renvoi [{m.group(1)}] sans source correspondante ({n_src} source(s))")
    return errors

# ---------------------------------------------------------------------------
# Compilation
# ---------------------------------------------------------------------------

def compile_sheet(yaml_path, pdf_path):
    os.makedirs(os.path.dirname(pdf_path), exist_ok=True)
    son = "/" + yaml_path
    if shutil.which("typst"):
        subprocess.run(["typst", "compile", "--root", ".", "--font-path", "fonts", "--input", f"son={son}",
                        "template/sheet.typ", pdf_path], check=True)
    else:
        import typst
        typst.compile("template/sheet.typ", output=pdf_path, root=".", font_paths=["fonts"], sys_inputs={"son": son})


def page_count(pdf_path):
    if shutil.which("pdfinfo"):
        out = subprocess.run(["pdfinfo", pdf_path], capture_output=True, text=True).stdout
        m = re.search(r"^Pages:\s+(\d+)", out, re.M)
        if m:
            return int(m.group(1))
    return len(re.findall(rb"/Type\s*/Page[^s]", open(pdf_path, "rb").read()))

# ---------------------------------------------------------------------------
# README : tableau des fiches et compteurs (entre marqueurs)
# ---------------------------------------------------------------------------

TYPES = {"basse": "Basse", "lead": "Lead", "pluck": "Pluck", "cuivre": "Cuivres", "pad": "Pad",
         "keys": "Clavier", "percussion": "Percussion", "fx": "Effet", "arp": "Arpège", "sequence": "Séquence"}
# Rôle du titre (anglais) équivalent au type (français) : pas de redite « Basse (bass) ».
SAME = {"bass": "basse", "brass": "cuivres", "keys": "clavier", "arp": "arpège", "sequence": "séquence"}
CONF = {3: "●●● documenté", 2: "●●○ déduit", 1: "●○○ approximation"}


def readme_row(d):
    ref = d.get("reference") or {}
    role = role_of(d) or d["titre"]
    cat = str(d.get("categorie", ""))
    typ = TYPES.get(cat.lower(), cat.capitalize())
    if SAME.get(role.lower(), role.lower()) != typ.lower():
        typ += f" ({role.lower()})"
    origine = ref.get("synthe_court") or re.split(r" \(| ;|, |\.", str(ref.get("synthe_origine") or "?").strip())[0]
    return {"artiste": ref.get("artiste", ""), "morceau": ref.get("morceau", ""), "annee": ref.get("annee", ""),
            "type": typ, "synthe": MACHINES[d["synthe"]], "origine": origine[:1].upper() + origine[1:],
            "confiance": CONF.get(d.get("confiance"), ""), "pdf": urllib.parse.quote(sheet_path(d))}


def update_readme(sheets):
    rows = sorted((readme_row(d) for d in sheets),
                  key=lambda r: (r["artiste"].lower().removeprefix("the "), r["morceau"], r["type"]))
    table = ["| Groupe | Morceau | Année | Type de son | Synthé | Son d'origine | Confiance | Fiche |",
             "|---|---|:-:|---|---|---|---|:-:|"]
    table += [f"| **{r['artiste']}** | {r['morceau']} | {r['annee']} | {r['type']} | {r['synthe']} "
              f"| {r['origine']} | {r['confiance']} | [PDF]({r['pdf']}) |" for r in rows]
    per = " · ".join(f"{sum(r['synthe'] == s for r in rows)} pour le {s}" for s in MACHINES.values())
    counts = f"**{len(rows)} fiches** · {len({r['artiste'] for r in rows})} groupes · {per}"

    text = open("README.md", encoding="utf-8").read()
    for tag, body in (("fiches", "\n".join(table)), ("compteurs", counts)):
        pat = re.compile(rf"(<!-- {tag}:start -->\n).*?(<!-- {tag}:end -->)", re.S)
        if not pat.search(text):
            sys.exit(f"README.md : marqueurs <!-- {tag}:start --> / <!-- {tag}:end --> introuvables")
        text = pat.sub(lambda m: m.group(1) + body + "\n" + m.group(2), text)
    open("README.md", "w", encoding="utf-8").write(text)
    print(f"README.md : {len(rows)} fiches")


def update_previews():
    shots = [("sheets/messenger/[Michael Jackson] Thriller (Bass).pdf", 1, "docs/apercu-messenger-p1"),
             ("sheets/messenger/[Michael Jackson] Thriller (Bass).pdf", 2, "docs/apercu-messenger-p2"),
             ("sheets/minilogue-xd/[MGMT] Little Dark Age (Intro).pdf", 1, "docs/apercu-minilogue-xd-p1")]
    for pdf, page, out in shots:
        if os.path.exists(pdf):
            subprocess.run(["pdftoppm", "-r", "110", "-png", "-singlefile", "-f", str(page), "-l", str(page), pdf, out], check=True)
    print("docs/ : aperçus régénérés")

# ---------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="*", help="YAML à compiler (défaut : tous ceux de sounds/)")
    ap.add_argument("--check", action="store_true", help="valider seulement")
    ap.add_argument("--previews", action="store_true", help="régénérer aussi les aperçus PNG de docs/")
    args = ap.parse_args()

    files = [os.path.relpath(f) for f in args.files] or sorted(glob.glob("sounds/*/*.yaml"))
    ok = True
    for f in files:
        raw = open(f, encoding="utf-8").read()
        try:
            d = _norm_keys(yaml.safe_load(raw))
        except yaml.YAMLError as e:
            ok = False
            mark = getattr(e, "problem_mark", None)
            where = f" (ligne {mark.line + 1}, colonne {mark.column + 1})" if mark else ""
            print(f"✗ {f}\n    YAML illisible{where} : {getattr(e, 'problem', e)}", file=sys.stderr)
            continue
        errors = validate(f, raw, d)
        if errors:
            ok = False
            print(f"✗ {f}", file=sys.stderr)
            for e in errors:
                print(f"    {e}", file=sys.stderr)
            continue
        if args.check:
            print(f"✓ {f} (valide)")
            continue
        out = sheet_path(d)
        try:
            compile_sheet(f, out)
        except Exception as e:  # erreur Typst : message déjà explicite
            ok = False
            print(f"✗ {f} : compilation\n    {e}", file=sys.stderr)
            continue
        n = page_count(out)
        if n != 2:
            ok = False
            print(f"✗ {out} : {n} pages au lieu de 2 (page 1 fiche, page 2 anatomie du son) : raccourcir les textes", file=sys.stderr)
        else:
            print(f"✓ {out}")

    if not args.check:
        all_sheets = []
        for f in sorted(glob.glob("sounds/*/*.yaml")):
            try:
                all_sheets.append(_norm_keys(yaml.safe_load(open(f, encoding="utf-8"))))
            except yaml.YAMLError:
                pass  # déjà signalé ou hors de cette compilation : la fiche reste hors du tableau
        update_readme([d for d in all_sheets if isinstance(d, dict) and d.get("synthe") in MACHINES])
        if args.previews:
            update_previews()
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
