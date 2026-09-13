#!/usr/bin/env bash
set -u

failed=0
ok() { printf '  [ok] %s\n' "$1"; }
fail() { printf '  [!!] %s\n' "$1"; failed=1; }

printf 'Commands\n'
for command_name in hyprctl hypridle hyprlock quickshell wofi cliphist grim slurp wf-recorder mpv wl-copy wl-paste python3 pacman; do
    if command -v "$command_name" >/dev/null 2>&1; then ok "$command_name"; else fail "$command_name is not installed"; fi
done

printf '\nPackages\n'
while IFS= read -r package_name; do
    [ -z "$package_name" ] && continue
    if pacman -Q "$package_name" >/dev/null 2>&1; then ok "$package_name"; else fail "$package_name is not installed"; fi
done < "$1/packages.txt"

exit "$failed"
