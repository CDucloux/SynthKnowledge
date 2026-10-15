#!/usr/bin/env bash
# Raccourci historique : tout est dans scripts/build.py (validation, compilation, README).
#   scripts/build.sh [--check] [--previews] [sounds/<machine>/<son>.yaml …]
exec python3 "$(dirname "$0")/build.py" "$@"
