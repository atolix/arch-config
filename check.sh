#!/usr/bin/env bash
set -u

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
failed=0

ok() { printf '  [ok] %s\n' "$1"; }
fail() { printf '  [!!] %s\n' "$1"; failed=1; }

printf 'Commands\n'
for command_name in hyprctl hypridle hyprlock quickshell wofi cliphist wl-copy wl-paste python3 pacman; do
    if command -v "$command_name" >/dev/null 2>&1; then ok "$command_name"; else fail "$command_name is not installed"; fi
done

printf '\nConfiguration files\n'
for file in \
    "$config_dir/hypr/hyprland.conf" \
    "$config_dir/hypr/hyprlock.conf" \
    "$config_dir/hypr/hypridle.conf" \
    "$config_dir/hypr/hyprland-osd.conf" \
    "$config_dir/wofi/style.css" \
    "$config_dir/gtk-3.0/settings.ini" \
    "$config_dir/gtk-3.0/gtk.css"; do
    if [ -f "$file" ]; then ok "$file"; else fail "$file is missing"; fi
done

if rg -q '@(ARCH_CONFIG_DIR|HOME)@' "$config_dir/hypr" 2>/dev/null; then
    fail 'unrendered config placeholders remain'
else
    ok 'config paths rendered'
fi

printf '\nPackages\n'
while IFS= read -r package_name; do
    [ -z "$package_name" ] && continue
    if pacman -Q "$package_name" >/dev/null 2>&1; then ok "$package_name"; else fail "$package_name is not installed"; fi
done < "$repo_dir/packages.txt"

printf '\nSyntax checks\n'
if bash -n "$repo_dir/install.sh" "$repo_dir/quickshell/run.sh" "$repo_dir/quickshell/scripts/lock-and-suspend.sh" "$repo_dir/quickshell/scripts/clipboard-picker.sh"; then ok 'shell scripts'; else fail 'shell script syntax'; fi
if python3 -m py_compile "$repo_dir"/quickshell/scripts/*.py; then ok 'Python scripts'; else fail 'Python script syntax'; fi
if git -C "$repo_dir" diff --check; then ok 'Git whitespace'; else fail 'Git whitespace errors'; fi

printf '\nSession checks\n'
if hyprctl version >/dev/null 2>&1; then ok 'Hyprland IPC'; else fail 'Hyprland IPC unavailable'; fi
if quickshell list --all >/dev/null 2>&1; then ok 'Quickshell instance'; else fail 'Quickshell instance unavailable'; fi

if [ "$failed" -eq 0 ]; then
    echo 'All checks passed.'
else
    echo 'Some checks failed.'
fi
exit "$failed"
