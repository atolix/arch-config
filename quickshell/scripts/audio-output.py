#!/usr/bin/env python3
"""Print the current default audio output kind for Quickshell."""

import json
import os
import subprocess


HEADPHONE_TERMS = ("headphone", "headset", "earbud", "earphone")


def command_output(command):
    return subprocess.run(
        command,
        capture_output=True,
        check=True,
        text=True,
        timeout=3,
        env={**os.environ, "LC_ALL": "C"},
    ).stdout.strip()


def output_kind():
    try:
        default_name = command_output(["pactl", "get-default-sink"])
        sinks = json.loads(command_output(["pactl", "--format=json", "list", "sinks"]))
    except (OSError, subprocess.SubprocessError, json.JSONDecodeError):
        return "unknown"

    sink = next((item for item in sinks if item.get("name") == default_name), None)
    if sink is None:
        return "unknown"

    active_port_name = sink.get("active_port", "")
    active_port = next(
        (port for port in sink.get("ports", []) if port.get("name") == active_port_name), {}
    )
    properties = sink.get("properties", {})
    identity = " ".join(
        str(value)
        for value in (
            active_port_name,
            active_port.get("type", ""),
            active_port.get("description", ""),
            properties.get("device.form_factor", ""),
            properties.get("device.icon_name", ""),
            properties.get("device.icon-name", ""),
        )
    ).lower()
    return "headphones" if any(term in identity for term in HEADPHONE_TERMS) else "speaker"


if __name__ == "__main__":
    print(output_kind(), flush=True)
