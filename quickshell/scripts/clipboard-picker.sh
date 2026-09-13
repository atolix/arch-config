#!/usr/bin/env bash
set -euo pipefail

selection="$(cliphist list | wofi --dmenu --prompt "")"
[ -n "$selection" ] || exit 0
printf '%s\n' "$selection" | cliphist decode | wl-copy
