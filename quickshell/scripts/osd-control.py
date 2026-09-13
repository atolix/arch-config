#!/usr/bin/env python3
"""Adjust hardware first; optionally notify this Quickshell instance."""
import argparse
import os
from pathlib import Path
import re
import subprocess
import sys


def run(*command):
    return subprocess.run(command, check=True, capture_output=True, text=True,
                          timeout=5, env={**os.environ, "LC_ALL": "C"}).stdout


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("kind", choices=("volume", "brightness"))
    parser.add_argument("action", choices=("up", "down", "mute", "show"))
    args = parser.parse_args()
    if args.kind == "brightness" and args.action == "mute":
        parser.error("brightness does not support mute")

    muted = False
    if args.kind == "volume":
        if args.action in ("up", "down"):
            run("wpctl", "set-volume", "--limit", "1", "@DEFAULT_AUDIO_SINK@",
                "2%+" if args.action == "up" else "2%-")
        elif args.action == "mute":
            run("wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle")
        result = run("wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@")
        match = re.search(r"Volume:\s+([0-9.]+)", result)
        if not match:
            raise ValueError("Cannot read output volume")
        percent = round(float(match[1]) * 100)
        muted = "[MUTED]" in result
    else:
        if args.action in ("up", "down"):
            run("brightnessctl", "--class=backlight", "--min-value=1", "set",
                "10%+" if args.action == "up" else "10%-")
        current = int(run("brightnessctl", "--class=backlight", "get"))
        maximum = int(run("brightnessctl", "--class=backlight", "max"))
        percent = round(current / maximum * 100)

    # Hardware keys still work when Quickshell is not running (e.g. using Waybar).
    project = str(Path(__file__).resolve().parent.parent)
    try:
        run("quickshell", "ipc", "--path", project, "call", "osd", "display",
            args.kind, str(percent), str(muted).lower())
    except (OSError, subprocess.SubprocessError):
        pass


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print(f"OSD control: {error}", file=sys.stderr)
        sys.exit(1)
