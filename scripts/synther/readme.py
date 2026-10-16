"""README : tableau des fiches et compteurs (régénérés entre marqueurs), aperçus PNG de docs/."""
import os
import re
import subprocess
import urllib.parse
from typing import NamedTuple

from . import MACHINES

TYPES = {"basse": "Basse", "lead": "Lead", "pluck": "Pluck", "cuivre": "Cuivres", "pad": "Pad",
         "keys": "Clavier", "percussion": "Percussion", "fx": "Effet", "arp": "Arpège", "sequence": "Séquence"}
# Rôle du titre (anglais) équivalent au type (français) : pas de redite « Basse (bass) ».
SAME_ROLE = {"bass": "basse", "brass": "cuivres", "keys": "clavier", "arp": "arpège", "sequence": "séquence"}
# Emoji ⚫/⚪ : même taille à l'affichage (● et ○ n'ont pas la même chasse selon les polices).
CONFIDENCE = {3: "⚫⚫⚫ documenté", 2: "⚫⚫⚪ déduit", 1: "⚫⚪⚪ approximation"}
PREVIEWS = [  # (PDF, page, PNG sans extension)
    ("sheets/messenger/[Michael Jackson] Thriller (Bass).pdf", 1, "docs/apercu-messenger-p1"),
    ("sheets/messenger/[Michael Jackson] Thriller (Bass).pdf", 2, "docs/apercu-messenger-p2"),
    ("sheets/minilogue-xd/[MGMT] Little Dark Age (Intro).pdf", 1, "docs/apercu-minilogue-xd-p1"),
]


class Row(NamedTuple):
    artist: str
    song: str
    year: str
    type: str
    synth: str
    origin: str
    confidence: str
    pdf: str

    @classmethod
    def of(cls, sheet):
        ref = sheet.reference
        return cls(ref.get("artist", ""), ref.get("song", ""), ref.get("year", ""), _sound_type(sheet),
                   sheet.machine_name, _origin(ref), CONFIDENCE.get(sheet.data.get("confidence"), ""),
                   urllib.parse.quote(sheet.pdf_path))

    def sort_key(self):
        return self.artist.lower().removeprefix("the "), self.song, self.type

    def markdown(self):
        return (f"| **{self.artist}** | {self.song} | {self.year} | {self.type} | {self.synth} "
                f"| {self.origin} | {self.confidence} | [PDF]({self.pdf}) |")


def _sound_type(sheet):
    """« Basse », ou « Pluck (intro) » quand le rôle du titre précise le type."""
    role = (sheet.role or sheet.data["title"]).lower()
    category = str(sheet.data.get("category", ""))
    label = TYPES.get(category.lower(), category.capitalize())
    return label if SAME_ROLE.get(role, role) == label.lower() else f"{label} ({role})"


def _origin(ref):
    """Synthé d'origine en quelques mots (`original_synth_short`, sinon début de `original_synth`)."""
    text = ref.get("original_synth_short") or re.split(r" \(| ;|, |\.", str(ref.get("original_synth") or "?").strip())[0]
    return text[:1].upper() + text[1:]


def update_readme(sheets, path="README.md"):
    rows = sorted((Row.of(s) for s in sheets), key=Row.sort_key)
    table = ["| Groupe | Morceau | Année | Type de son | Synthé | Son d'origine | Confiance | Fiche |",
             "|---|---|:-:|---|---|---|---|:-:|", *(r.markdown() for r in rows)]
    # Compteurs dans un <p> HTML : pas de Markdown (GitHub afficherait les **), donc <b>.
    per_machine = " · ".join(f"{sum(r.synth == m for r in rows)} pour le {m}" for m in MACHINES.values())
    counts = f"📄 <b>{len(rows)} fiches</b> · 🎤 {len({r.artist for r in rows})} groupes · 🎹 {per_machine}"

    with open(path, encoding="utf-8") as f:
        text = f.read()
    for tag, body in (("fiches", "\n".join(table)), ("compteurs", counts)):
        text = _replace_between_markers(text, tag, body)
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"README.md : {len(rows)} fiches")


def _replace_between_markers(text, tag, body):
    pattern = re.compile(rf"(<!-- {tag}:start -->\n).*?(<!-- {tag}:end -->)", re.S)
    if not pattern.search(text):
        raise SystemExit(f"README.md : marqueurs <!-- {tag}:start --> / <!-- {tag}:end --> introuvables")
    return pattern.sub(lambda m: m.group(1) + body + "\n" + m.group(2), text)


def update_previews():
    for pdf, page, png in PREVIEWS:
        if os.path.exists(pdf):
            subprocess.run(["pdftoppm", "-r", "110", "-png", "-singlefile", "-f", str(page), "-l", str(page), pdf, png],
                           check=True)
    print("docs/ : aperçus régénérés")
