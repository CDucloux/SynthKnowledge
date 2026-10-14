#!/usr/bin/env bash
# Compile les fiches PDF à partir des YAML de sounds/.
#   scripts/build.sh                              → toutes les fiches
#   scripts/build.sh sounds/messenger/mon-son.yaml  → une seule
# Requiert la CLI typst (https://typst.app), ou à défaut le paquet Python `typst`.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -gt 0 ]; then files=("$@"); else mapfile -t files < <(find sounds -name '*.yaml' | sort); fi

compile() { # $1 = yaml relatif, $2 = pdf de sortie
  if command -v typst >/dev/null 2>&1; then
    typst compile --root . --font-path fonts --input "son=/$1" template/sheet.typ "$2"
  else
    python3 -c 'import sys, typst
typst.compile("template/sheet.typ", output=sys.argv[2], root=".", font_paths=["fonts"], sys_inputs={"son": "/" + sys.argv[1]})' "$1" "$2"
  fi
}

status=0
for f in "${files[@]}"; do
  rel="${f#./}"
  out="sheets/${rel#sounds/}"; out="${out%.yaml}.pdf"
  mkdir -p "$(dirname "$out")"
  if grep -q -e $'\xe2\x80\x94' -e $'\xe2\x80\x93' "$rel"; then echo "✗ $rel : tiret quadratin interdit" >&2; status=1; continue; fi
  compile "$rel" "$out"
  pages=$(python3 -c 'import re,sys; print(len(re.findall(rb"/Type\s*/Page[^s]", open(sys.argv[1],"rb").read())))' "$out")
  if [ "$pages" != "2" ]; then echo "✗ $out : $pages pages au lieu de 2 (page 1 fiche, page 2 anatomie du son) : raccourcir les textes de la page 1" >&2; status=1; else echo "✓ $out"; fi
done
exit $status
