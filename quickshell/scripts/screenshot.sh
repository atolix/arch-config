#!/usr/bin/env bash
set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/paths.sh"

geometry="$(slurp)" || exit 0
directory="$(screenshots_dir)"
mkdir -p "$directory"
grim -g "$geometry" "$directory/screenshot-$(date +%Y%m%d-%H%M%S).png"
