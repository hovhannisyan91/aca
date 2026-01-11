#!/usr/bin/env bash
set -euo pipefail

# Expand ~ explicitly (important in non-interactive shells)
source ~/Envs/quarto/bin/activate



MODULE="$1"
SESSION="$2"

if [[ -z "${MODULE:-}" || -z "${SESSION:-}" ]]; then
  echo "Usage: ./preview.sh <module> <session_number>"
  echo "Example: ./preview.sh statistics 03"
  exit 1
fi


quarto preview "materials/${MODULE}/session${SESSION}.qmd"

# ./book_preview.sh tableau 1