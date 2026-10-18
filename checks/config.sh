#!/usr/bin/env bash
set -u

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
failed=0
ok() { printf '  [ok] %s\n' "$1"; }
fail() { printf '  [!!] %s\n' "$1"; failed=1; }

printf 'Configuration files\n'
for file in \
    "$config_dir/hypr/hyprland.lua" \
    "$config_dir/hypr/hyprlock.conf" \
    "$config_dir/hypr/hypridle.conf" \
    "$config_dir/hypr/hyprland-osd.lua" \
    "$config_dir/wofi/style.css" \
    "$config_dir/btop/btop.conf" \
    "$config_dir/btop/themes/linux-config.theme" \
    "$config_dir/fastfetch/config.jsonc" \
    "$config_dir/gtk-3.0/settings.ini" \
    "$config_dir/gtk-3.0/gtk.css" \
    "$config_dir/mimeapps.list" \
    "$config_dir/mpv/mpv.conf"; do
    if [ -f "$file" ]; then ok "$file"; else fail "$file is missing"; fi
done

if rg -q '@(LINUX_CONFIG_DIR|HOME)@' "$config_dir/hypr" 2>/dev/null; then
    fail 'unrendered config placeholders remain'
else
    ok 'config paths rendered'
fi

exit "$failed"
