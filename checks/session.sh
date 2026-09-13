#!/usr/bin/env bash
set -u

failed=0
ok() { printf '  [ok] %s\n' "$1"; }
fail() { printf '  [!!] %s\n' "$1"; failed=1; }

printf 'Session checks\n'
if hyprctl version >/dev/null 2>&1; then ok 'Hyprland IPC'; else fail 'Hyprland IPC unavailable'; fi
if quickshell list --all >/dev/null 2>&1; then ok 'Quickshell instance'; else fail 'Quickshell instance unavailable'; fi

exit "$failed"
