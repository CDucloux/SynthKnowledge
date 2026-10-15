#!/usr/bin/env bash
# Compile les fiches PDF à partir des YAML de sounds/.
#   scripts/build.sh                              → toutes les fiches
#   scripts/build.sh sounds/messenger/mon-son.yaml  → une seule
#   scripts/build.sh --paysage [yaml…]            → version paysage de la page 1 (Messenger),
#                                                   en plus de la version portrait : « … (Rôle, paysage).pdf »
# Une fiche peut aussi être en paysage par défaut : `orientation: paysage` dans son YAML.
# PDF nommé « sheets/<machine>/[Artiste] Morceau (Rôle).pdf » d'après le YAML.
# Requiert la CLI typst (https://typst.app), ou à défaut le paquet Python `typst`.
set -euo pipefail
cd "$(dirname "$0")/.."

orient=""
if [ "${1:-}" = "--paysage" ]; then orient="paysage"; shift; fi

if [ $# -gt 0 ]; then files=("$@"); else mapfile -t files < <(find sounds -name '*.yaml' | sort); fi

compile() { # $1 = yaml relatif, $2 = pdf de sortie, $3 = orientation forcée (vide = celle du YAML)
  local extra=()
  [ -n "${3:-}" ] && extra=(--input "orientation=$3")
  if command -v typst >/dev/null 2>&1; then
    typst compile --root . --font-path fonts --input "son=/$1" "${extra[@]}" template/sheet.typ "$2"
  else
    python3 -c 'import sys, typst
inputs = {"son": "/" + sys.argv[1]}
if sys.argv[3]: inputs["orientation"] = sys.argv[3]
typst.compile("template/sheet.typ", output=sys.argv[2], root=".", font_paths=["fonts"], sys_inputs=inputs)' "$1" "$2" "${3:-}"
  fi
}

sheet_name() { # $1 = yaml, $2 = orientation forcée → "<machine>/[Artiste] Morceau (Rôle)", rôle = titre moins le morceau (« Closer Bass » → « Bass »)
  python3 -c 'import sys, yaml, os
d = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
ref = d.get("reference") or {}
artiste, morceau, titre = ref.get("artiste", ""), ref.get("morceau", ""), d["titre"]
role = titre[len(morceau):].strip() if morceau and titre.startswith(morceau) else ""
nom = f"[{artiste}] {morceau}" if artiste and morceau else titre
tags = [role] if role else []
if sys.argv[2] == "paysage" and d.get("orientation") != "paysage": tags.append("paysage")
if tags: nom += " (" + ", ".join(tags) + ")"
print(os.path.basename(os.path.dirname(sys.argv[1])) + "/" + nom.replace("/", "-"))' "$1" "${2:-}"
}

status=0
for f in "${files[@]}"; do
  rel="${f#./}"
  if [ -n "$orient" ] && ! grep -q "^synthe: messenger" "$rel"; then echo "· $rel : paysage disponible pour le Messenger seulement, ignoré"; continue; fi
  out="sheets/$(sheet_name "$rel" "$orient").pdf"
  mkdir -p "$(dirname "$out")"
  if grep -q -e $'\xe2\x80\x94' -e $'\xe2\x80\x93' "$rel"; then echo "✗ $rel : tiret quadratin interdit" >&2; status=1; continue; fi
  compile "$rel" "$out" "$orient"
  pages=$(python3 -c 'import re,sys; print(len(re.findall(rb"/Type\s*/Page[^s]", open(sys.argv[1],"rb").read())))' "$out")
  if [ "$pages" != "2" ]; then echo "✗ $out : $pages pages au lieu de 2 (page 1 fiche, page 2 anatomie du son) : raccourcir les textes de la page 1" >&2; status=1; else echo "✓ $out"; fi
done
exit $status
