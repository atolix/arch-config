#!/usr/bin/env bash

screenshots_dir() {
    printf '%s\n' "${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
}

recordings_dir() {
    printf '%s\n' "${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
}
