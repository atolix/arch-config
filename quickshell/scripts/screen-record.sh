#!/usr/bin/env bash
set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/paths.sh"

if pgrep -x wf-recorder >/dev/null 2>&1; then
    pkill -INT -x wf-recorder
    exit 0
fi

geometry="$(slurp)" || exit 0
directory="$(recordings_dir)"
mkdir -p "$directory"
wf-recorder -g "$geometry" -f "$directory/recording-$(date +%Y%m%d-%H%M%S).mp4"
