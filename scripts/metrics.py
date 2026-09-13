#!/usr/bin/env python3
"""Stream brightness and NetworkManager status as JSON lines to Quickshell."""

import json
import os
from pathlib import Path
import subprocess
import time


def brightness_percent():
    for device in sorted(Path("/sys/class/backlight").glob("*")):
        try:
            maximum = int((device / "max_brightness").read_text())
            current = int((device / "brightness").read_text())
            if maximum > 0:
                return max(0, min(100, round(100 * current / maximum)))
        except (OSError, ValueError):
            continue
    return None


def network_status():
    try:
        result = subprocess.run(
            ["nmcli", "--terse", "--escape", "no", "--fields", "TYPE,STATE,CONNECTION", "device", "status"],
            capture_output=True, text=True, timeout=3, check=True,
            env={**os.environ, "LC_ALL": "C"},
        )
    except (OSError, subprocess.SubprocessError):
        return {"network": "net: —", "networkKind": "offline", "wifiSignal": 0}
    connections = [line.split(":", 2) for line in result.stdout.splitlines()]
    for kind in ("wifi", "ethernet"):
        for entry in connections:
            if len(entry) == 3 and entry[0] == kind and entry[1] == "connected":
                signal = 0
                if kind == "wifi":
                    try:
                        wifi = subprocess.run(
                            ["nmcli", "--terse", "--escape", "no", "--fields", "IN-USE,SIGNAL", "device", "wifi"],
                            capture_output=True, text=True, timeout=3, check=True,
                            env={**os.environ, "LC_ALL": "C"},
                        )
                        for wifi_entry in wifi.stdout.splitlines():
                            fields = wifi_entry.split(":", 1)
                            if len(fields) == 2 and fields[0] == "*" and fields[1].isdigit():
                                signal = int(fields[1])
                                break
                    except (OSError, subprocess.SubprocessError):
                        pass
                return {"network": "wifi: " + entry[2] if kind == "wifi" else "eth: connected",
                        "networkKind": kind, "wifiSignal": signal}
    return {"network": "net: offline", "networkKind": "offline", "wifiSignal": 0}


def main():
    while True:
        time.sleep(2)
        network = network_status()
        print(json.dumps({**network, "brightness": brightness_percent()}), flush=True)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        pass
