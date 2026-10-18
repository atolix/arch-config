#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
quickshell_bin="${ARCH_CONFIG_QUICKSHELL_BIN:-quickshell}"
exec "$quickshell_bin" --path "$project_dir" "$@"
