#!/usr/bin/env bash
set -u

failed=0
ok() { printf '  [ok] %s\n' "$1"; }
fail() { printf '  [!!] %s\n' "$1"; failed=1; }

printf 'Commands\n'
for command_name in hyprctl hypridle hyprlock quickshell wofi cliphist fastfetch grim slurp wf-recorder mpv wl-copy wl-paste python3; do
    if command -v "$command_name" >/dev/null 2>&1; then ok "$command_name"; else fail "$command_name is not installed"; fi
done

printf '\nPackages\n'
if command -v pacman >/dev/null 2>&1; then
    while IFS= read -r package_name; do
        [ -z "$package_name" ] && continue
        if pacman -Q "$package_name" >/dev/null 2>&1; then ok "$package_name"; else fail "$package_name is not installed"; fi
    done < "$1/packages.txt"
elif command -v nix >/dev/null 2>&1; then
    ok 'packages are managed by Nix'
else
    fail 'neither pacman nor nix is available'
fi

exit "$failed"
