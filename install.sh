#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"

link_config() {
    local source="$1"
    local target="$2"
    mkdir -p "$(dirname -- "$target")"
    ln -sfn "$source" "$target"
}

link_config "$repo_dir/home/atolix/.config/hypr/hyprland.conf" "$config_dir/hypr/hyprland.conf"
link_config "$repo_dir/home/atolix/.config/hypr/hyprlock.conf" "$config_dir/hypr/hyprlock.conf"
link_config "$repo_dir/quickshell/hypridle.conf" "$config_dir/hypr/hypridle.conf"
link_config "$repo_dir/home/atolix/.config/wofi/style.css" "$config_dir/wofi/style.css"
link_config "$repo_dir/home/atolix/.config/fcitx5/config" "$config_dir/fcitx5/config"
link_config "$repo_dir/home/atolix/.config/fcitx5/profile" "$config_dir/fcitx5/profile"
link_config "$repo_dir/home/atolix/.config/fcitx5/conf/notifications.conf" "$config_dir/fcitx5/conf/notifications.conf"

echo "Linked user configuration from $repo_dir"
echo "Install packages with: sudo pacman -S --needed - < $repo_dir/packages.txt"
echo "SDDM theme files are in $repo_dir/sddm/mysddm; copy them to /usr/share/sddm/themes/mysddm as root."
