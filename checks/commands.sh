#!/usr/bin/env bash
set -u

failed=0
ok() { printf '  [ok] %s\n' "$1"; }
fail() { printf '  [!!] %s\n' "$1"; failed=1; }

printf 'Commands\n'
for command_name in hyprctl hypridle hyprlock quickshell wofi cliphist fastfetch grim slurp wf-recorder mpv wl-copy wl-paste python3; do
    if command -v "$command_name" >/dev/null 2>&1; then ok "$command_name"; else fail "$command_name is not installed"; fi
done

exit "$failed"
