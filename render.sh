#!/usr/bin/env bash
set -euo pipefail

# Expand ~ explicitly (important in non-interactive shells)
source ~/Envs/quarto/bin/activate




quarto render

# ./slides_preview.sh tableau 1