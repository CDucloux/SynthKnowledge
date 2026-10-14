#!/usr/bin/env bash
# Compile les fiches PDF à partir des YAML de sons/.
#   scripts/build.sh                              → toutes les fiches
#   scripts/build.sh sons/messenger/mon-son.yaml  → une seule
# Requiert la CLI typst (https://typst.app) — ou, à défaut, le paquet Python `typst`.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -gt 0 ]; then files=("$@"); else mapfile -t files < <(find sons -name '*.yaml' | sort); fi

compile() { # $1 = yaml relatif, $2 = pdf de sortie
  if command -v typst >/dev/null 2>&1; then
    typst compile --root . --font-path fonts --input "son=/$1" template/fiche.typ "$2"
  else
    python3 -c 'import sys, typst
typst.compile("template/fiche.typ", output=sys.argv[2], root=".", font_paths=["fonts"], sys_inputs={"son": "/" + sys.argv[1]})' "$1" "$2"
  fi
}

status=0
for f in "${files[@]}"; do
  rel="${f#./}"
  out="fiches/${rel#sons/}"; out="${out%.yaml}.pdf"
  mkdir -p "$(dirname "$out")"
  compile "$rel" "$out"
  pages=$(python3 -c 'import re,sys; print(len(re.findall(rb"/Type\s*/Page[^s]", open(sys.argv[1],"rb").read())))' "$out")
  if [ "$pages" != "1" ]; then echo "✗ $out : $pages pages — la fiche doit tenir sur une page (raccourcir les textes)" >&2; status=1; else echo "✓ $out"; fi
done
exit $status
