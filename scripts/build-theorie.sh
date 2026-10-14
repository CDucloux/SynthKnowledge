#!/usr/bin/env bash
# Compile les fiches de théorie (theorie/*.typ) en PDF imprimables, une page chacune.
#   scripts/build-theorie.sh                              → toutes
#   scripts/build-theorie.sh theorie/01-forme-onde-spectre.typ → une seule
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -gt 0 ]; then files=("$@"); else mapfile -t files < <(find theorie -name '*.typ' | sort); fi

status=0
for f in "${files[@]}"; do
  rel="${f#./}"
  out="fiches/theorie/$(basename "${rel%.typ}").pdf"
  mkdir -p fiches/theorie
  if grep -q -e $'\xe2\x80\x94' -e $'\xe2\x80\x93' "$rel"; then echo "✗ $rel : tiret quadratin interdit" >&2; status=1; continue; fi
  if command -v typst >/dev/null 2>&1; then
    typst compile --root . --font-path fonts "$rel" "$out"
  else
    python3 -c 'import sys, typst
typst.compile(sys.argv[1], output=sys.argv[2], root=".", font_paths=["fonts"])' "$rel" "$out"
  fi
  pages=$(python3 -c 'import re,sys; print(len(re.findall(rb"/Type\s*/Page[^s]", open(sys.argv[1],"rb").read())))' "$out")
  if [ "$pages" != "1" ]; then echo "✗ $out : $pages pages, une fiche de théorie tient sur une page" >&2; status=1; else echo "✓ $out"; fi
done
exit $status
