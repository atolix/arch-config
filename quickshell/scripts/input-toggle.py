#!/usr/bin/env python3
"""Toggle Fcitx5 input mode and update the Quickshell label immediately."""

import os
from pathlib import Path
import subprocess


def run(*command):
    return subprocess.run(command, capture_output=True, text=True, check=True, timeout=3,
                          env={**os.environ, "LC_ALL": "C"}).stdout.strip()


def layout_name(engine):
    engine = engine.lower()
    if "mozc" in engine or "japanese" in engine or "keyboard-jp" in engine:
        return "JP"
    if "keyboard-us" in engine or engine in ("us", "english"):
        return "EN"
    return engine.upper()[:4] if engine else "—"


def main():
    run("fcitx5-remote", "-t")
    layout = layout_name(run("fcitx5-remote", "-n"))
    project = str(Path(__file__).resolve().parent.parent)
    quickshell = os.environ.get("LINUX_CONFIG_QUICKSHELL_BIN", "quickshell")
    run(quickshell, "ipc", "--path", project, "call", "input", "setLayout", layout)


if __name__ == "__main__":
    main()
