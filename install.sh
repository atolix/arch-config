#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
backup_dir="$HOME/.local/state/arch-config/backups/$(date +%Y%m%d-%H%M%S)"

render_config() {
    local source="$1"
    local target="$2"
    mkdir -p "$(dirname -- "$target")"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local relative_target="${target#"$HOME/"}"
        mkdir -p "$backup_dir/$(dirname -- "$relative_target")"
        cp -a "$target" "$backup_dir/$relative_target"
    fi
    if [ -L "$target" ]; then
        rm -f "$target"
    fi
    sed "s|@ARCH_CONFIG_DIR@|$repo_dir|g; s|@HOME@|$HOME|g" "$source" > "$target"
}

render_config "$repo_dir/home/atolix/.config/hypr/hyprland.conf" "$config_dir/hypr/hyprland.conf"
render_config "$repo_dir/home/atolix/.config/hypr/hyprlock.conf" "$config_dir/hypr/hyprlock.conf"
render_config "$repo_dir/quickshell/hypridle.conf" "$config_dir/hypr/hypridle.conf"
render_config "$repo_dir/quickshell/hyprland-osd.conf" "$config_dir/hypr/hyprland-osd.conf"
render_config "$repo_dir/home/atolix/.config/wofi/style.css" "$config_dir/wofi/style.css"
render_config "$repo_dir/home/atolix/.config/gtk-3.0/settings.ini" "$config_dir/gtk-3.0/settings.ini"
render_config "$repo_dir/home/atolix/.config/gtk-3.0/gtk.css" "$config_dir/gtk-3.0/gtk.css"
render_config "$repo_dir/home/atolix/.config/fcitx5/config" "$config_dir/fcitx5/config"
render_config "$repo_dir/home/atolix/.config/fcitx5/profile" "$config_dir/fcitx5/profile"
render_config "$repo_dir/home/atolix/.config/fcitx5/conf/notifications.conf" "$config_dir/fcitx5/conf/notifications.conf"

sudo install -d /usr/share/sddm/themes/mysddm /etc/sddm.conf.d
sudo cp -a "$repo_dir/sddm/mysddm/." /usr/share/sddm/themes/mysddm/
sudo install -m 644 "$repo_dir/etc/sddm.conf.d/theme.conf" /etc/sddm.conf.d/theme.conf

echo "Linked user configuration from $repo_dir"
if [ -d "$backup_dir" ]; then
    echo "Backed up existing user configuration to $backup_dir"
fi
echo "Install packages with: sudo pacman -S --needed - < $repo_dir/packages.txt"
echo "Applied SDDM theme from $repo_dir/sddm/mysddm"
