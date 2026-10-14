#!/usr/bin/env bash
# Compile les fiches de théorie (theory/*.typ) en PDF imprimables (pas de limite de pages).
#   scripts/build-theory.sh                              → toutes
#   scripts/build-theory.sh theory/01-forme-onde-spectre.typ → une seule
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -gt 0 ]; then files=("$@"); else mapfile -t files < <(find theory -name '*.typ' | sort); fi

status=0
for f in "${files[@]}"; do
  rel="${f#./}"
  out="sheets/theory/$(basename "${rel%.typ}").pdf"
  mkdir -p sheets/theory
  if grep -q -e $'\xe2\x80\x94' -e $'\xe2\x80\x93' "$rel"; then echo "✗ $rel : tiret quadratin interdit" >&2; status=1; continue; fi
  if command -v typst >/dev/null 2>&1; then
    typst compile --root . --font-path fonts "$rel" "$out"
  else
    python3 -c 'import sys, typst
typst.compile(sys.argv[1], output=sys.argv[2], root=".", font_paths=["fonts"])' "$rel" "$out"
  fi
  echo "✓ $out"
done
exit $status
