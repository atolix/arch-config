#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mode="${1:---dry-run}"

case "$mode" in
    --dry-run|--switch) ;;
    *)
        echo "Usage: $0 [--dry-run|--switch]" >&2
        exit 2
        ;;
esac

if ! command -v nix >/dev/null 2>&1; then
    echo 'Nix is required. Run ./bootstrap-nix.sh first.' >&2
    exit 1
fi

generation="$(nix build "path:$repo_dir#homeConfigurations.atolix.activationPackage" \
    --no-link --print-out-paths)"
backup_extension="arch-config-before-home-manager-$(date +%Y%m%d-%H%M%S)"

if [ "$mode" = '--dry-run' ]; then
    DRY_RUN=1 HOME_MANAGER_BACKUP_EXT="$backup_extension" \
        "$generation/activate" --driver-version 1
    echo 'Dry run complete. No Home Manager files were activated.'
else
    HOME_MANAGER_BACKUP_EXT="$backup_extension" "$generation/activate"
    echo "Home Manager activated. Replaced files were backed up with .$backup_extension."
fi
