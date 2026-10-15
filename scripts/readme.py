#!/usr/bin/env python3
"""Met à jour le tableau des fiches du README (entre les marqueurs) à partir des YAML.

    python3 scripts/readme.py              # tableau + compteurs
    python3 scripts/readme.py --previews   # + régénère les aperçus PNG de docs/

Appelé automatiquement à la fin de scripts/build.sh.
"""
import glob, os, re, subprocess, sys, urllib.parse
import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

SYNTHS = {"messenger": "Moog Messenger", "minilogue-xd": "Korg minilogue XD"}
TYPES = {"basse": "Basse", "lead": "Lead", "pluck": "Pluck", "cuivre": "Cuivres", "pad": "Pad",
         "keys": "Clavier", "percussion": "Percussion", "fx": "Effet", "arp": "Arpège", "sequence": "Séquence"}
# Rôle du titre (anglais) équivalent au type (français) : pas de redite « Basse (bass) ».
SAME = {"bass": "basse", "brass": "cuivres", "keys": "clavier", "arp": "arpège", "sequence": "séquence", "lead": "lead", "pad": "pad", "pluck": "pluck"}
CONF = {3: "●●● documenté", 2: "●●○ déduit", 1: "●○○ approximation"}


def sheet_name(path, d):
    """Même règle que scripts/build.sh : « [Artiste] Morceau (Rôle) »."""
    ref = d.get("reference") or {}
    artiste, morceau, titre = ref.get("artiste", ""), ref.get("morceau", ""), d["titre"]
    role = titre[len(morceau):].strip() if morceau and titre.startswith(morceau) else ""
    nom = f"[{artiste}] {morceau}" if artiste and morceau else titre
    if role:
        nom += f" ({role})"
    return os.path.basename(os.path.dirname(path)), nom.replace("/", "-")


def origin_short(ref):
    """Synthé d'origine en quelques mots : `synthe_court` si présent, sinon début de `synthe_origine`."""
    if ref.get("synthe_court"):
        return ref["synthe_court"]
    s = str(ref.get("synthe_origine") or "").strip()
    s = re.split(r" \(| ;|, |\.", s)[0].strip()
    return (s[:1].upper() + s[1:]) if s else "?"


def rows():
    out = []
    for f in glob.glob("sounds/*/*.yaml"):
        d = yaml.safe_load(open(f, encoding="utf-8"))
        ref = d.get("reference") or {}
        machine, nom = sheet_name(f, d)
        role = d["titre"][len(ref.get("morceau", "")):].strip() or d["titre"]
        typ = TYPES.get(str(d.get("categorie", "")).lower(), str(d.get("categorie", "")).capitalize())
        pdf = f"sheets/{machine}/{nom}.pdf"
        out.append({
            "artiste": ref.get("artiste", ""), "morceau": ref.get("morceau", ""), "annee": ref.get("annee", ""),
            "type": typ if SAME.get(role.lower(), role.lower()) == typ.lower() else f"{typ} ({role.lower()})",
            "synthe": SYNTHS.get(machine, machine), "origine": origin_short(ref),
            "confiance": CONF.get(d.get("confiance", 1), ""), "pdf": urllib.parse.quote(pdf),
        })
    return sorted(out, key=lambda r: (r["artiste"].lower().removeprefix("the "), r["morceau"], r["type"]))


def table(rs):
    lines = ["| Groupe | Morceau | Année | Type de son | Synthé | Son d'origine | Confiance | Fiche |",
             "|---|---|:-:|---|---|---|---|:-:|"]
    for r in rs:
        lines.append(f"| **{r['artiste']}** | {r['morceau']} | {r['annee']} | {r['type']} | {r['synthe']} "
                     f"| {r['origine']} | {r['confiance']} | [PDF]({r['pdf']}) |")
    return "\n".join(lines)


def counts(rs):
    n = len(rs)
    per = {s: sum(1 for r in rs if r["synthe"] == s) for s in SYNTHS.values()}
    groupes = len({r["artiste"] for r in rs})
    return (f"**{n} fiches** · {groupes} groupes · "
            + " · ".join(f"{v} pour le {k}" for k, v in per.items()))


def replace(text, tag, body):
    pat = re.compile(rf"(<!-- {tag}:start -->\n).*?(<!-- {tag}:end -->)", re.S)
    if not pat.search(text):
        sys.exit(f"README.md : marqueurs <!-- {tag}:start/end --> introuvables")
    return pat.sub(lambda m: m.group(1) + body + "\n" + m.group(2), text)


def previews():
    """Aperçus PNG pour le README : page 1 et 2 d'une fiche Messenger, page 1 d'une fiche XD."""
    shots = [("sheets/messenger/[Michael Jackson] Thriller (Bass).pdf", 1, "docs/apercu-messenger-p1"),
             ("sheets/messenger/[Michael Jackson] Thriller (Bass).pdf", 2, "docs/apercu-messenger-p2"),
             ("sheets/minilogue-xd/[MGMT] Little Dark Age (Intro).pdf", 1, "docs/apercu-minilogue-xd-p1")]
    for pdf, page, out in shots:
        if os.path.exists(pdf):
            subprocess.run(["pdftoppm", "-r", "110", "-png", "-singlefile", "-f", str(page), "-l", str(page), pdf, out], check=True)


if __name__ == "__main__":
    rs = rows()
    text = open("README.md", encoding="utf-8").read()
    text = replace(text, "fiches", table(rs))
    text = replace(text, "compteurs", counts(rs))
    open("README.md", "w", encoding="utf-8").write(text)
    if "--previews" in sys.argv:
        previews()
    print(f"README.md : {len(rs)} fiches")
