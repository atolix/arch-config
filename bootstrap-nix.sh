#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
nix_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nix"
nix_config="$nix_config_dir/nix.conf"

if ! command -v pacman >/dev/null 2>&1; then
    echo 'This bootstrap script supports Arch Linux with pacman.' >&2
    exit 1
fi

if [ "$EUID" -eq 0 ]; then
    root=()
elif command -v sudo >/dev/null 2>&1; then
    root=(sudo)
else
    echo 'sudo is required when the script is not run as root.' >&2
    exit 1
fi

installed_nix=false
if ! pacman -Q nix >/dev/null 2>&1; then
    "${root[@]}" pacman -S --needed nix
    installed_nix=true
fi

# The Arch package supplies these definitions, but explicitly applying them
# also repairs an interrupted first installation.
if ! getent group nixbld >/dev/null 2>&1; then
    "${root[@]}" systemd-sysusers /usr/lib/sysusers.d/nix-daemon.conf
fi

dir_matches() {
    [ "$(stat -c '%U:%G %a' "$1" 2>/dev/null || true)" = "$2" ]
}

if ! dir_matches /nix 'root:root 755' \
    || ! dir_matches /nix/var 'root:root 755' \
    || ! dir_matches /nix/var/nix 'root:root 755'; then
    "${root[@]}" install -d -m 0755 -o root -g root /nix /nix/var /nix/var/nix
fi
if ! dir_matches /nix/store 'root:nixbld 1775'; then
    "${root[@]}" install -d -m 1775 -o root -g nixbld /nix/store
fi
if ! dir_matches /nix/var/nix/daemon-socket 'root:root 755' \
    || ! dir_matches /nix/var/nix/builds 'root:root 755'; then
    "${root[@]}" systemd-tmpfiles --create /usr/lib/tmpfiles.d/nix-daemon.conf
fi

if [ "$installed_nix" = true ]; then
    "${root[@]}" systemctl daemon-reload
fi

if [ -f /usr/lib/systemd/system/nix-daemon.socket ]; then
    daemon_unit=nix-daemon.socket
else
    daemon_unit=nix-daemon.service
fi
if ! systemctl is-enabled --quiet "$daemon_unit" \
    || ! systemctl is-active --quiet "$daemon_unit"; then
    "${root[@]}" systemctl enable --now "$daemon_unit"
fi

mkdir -p "$nix_config_dir"
touch "$nix_config"
features="$(nix config show experimental-features 2>/dev/null || true)"
if ! grep -qw 'nix-command' <<< "$features" || ! grep -qw 'flakes' <<< "$features"; then
    printf '%s\n' 'extra-experimental-features = nix-command flakes' >> "$nix_config"
fi

nix store info --store daemon >/dev/null
nix flake check "path:$repo_dir"

echo 'Nix is ready and the repository flake check passed.'
