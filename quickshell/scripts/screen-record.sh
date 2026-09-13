#!/usr/bin/env bash
set -euo pipefail

if pgrep -x wf-recorder >/dev/null 2>&1; then
    pkill -INT -x wf-recorder
    exit 0
fi

geometry="$(slurp)" || exit 0
directory="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
mkdir -p "$directory"
wf-recorder -g "$geometry" -f "$directory/recording-$(date +%Y%m%d-%H%M%S).mp4"
