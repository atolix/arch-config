#!/usr/bin/env bash
set -euo pipefail

geometry="$(slurp)" || exit 0
directory="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$directory"
grim -g "$geometry" "$directory/screenshot-$(date +%Y%m%d-%H%M%S).png"
