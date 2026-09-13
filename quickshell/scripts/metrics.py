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


def cpu_ticks():
    try:
        fields = Path("/proc/stat").read_text().splitlines()[0].split()[1:]
        values = [int(value) for value in fields]
        return sum(values), values[3] + values[4]
    except (IndexError, OSError, ValueError):
        return None


def cpu_percent(previous):
    current = cpu_ticks()
    if previous is None or current is None:
        return 0, current
    total_delta = current[0] - previous[0]
    idle_delta = current[1] - previous[1]
    if total_delta <= 0:
        return 0, current
    return max(0, min(100, round(100 * (total_delta - idle_delta) / total_delta))), current


def memory_percent():
    values = {}
    try:
        for line in Path("/proc/meminfo").read_text().splitlines():
            key, value = line.split(":", 1)
            values[key] = int(value.strip().split()[0])
        total = values["MemTotal"]
        available = values["MemAvailable"]
        return max(0, min(100, round(100 * (total - available) / total)))
    except (KeyError, OSError, ValueError, ZeroDivisionError):
        return 0


def temperature_celsius():
    preferred = ("x86_pkg_temp", "cpu_thermal", "coretemp")
    zones = sorted(Path("/sys/class/thermal").glob("thermal_zone*/"))
    def zone_priority(zone):
        try:
            return preferred.index((zone / "type").read_text().strip())
        except (OSError, ValueError):
            return len(preferred)

    zones.sort(key=zone_priority)
    for zone in zones:
        try:
            zone_type = (zone / "type").read_text().strip()
            if zone_type not in preferred:
                continue
            value = int((zone / "temp").read_text().strip())
            return round(value / 1000)
        except (OSError, ValueError):
            continue
    return None


def input_layout():
    try:
        engine = subprocess.run(
            ["fcitx5-remote", "-n"], capture_output=True, text=True, timeout=2, check=True
        ).stdout.strip().lower()
    except (OSError, subprocess.SubprocessError):
        return "—"
    if "mozc" in engine or "japanese" in engine or "keyboard-jp" in engine:
        return "JP"
    if "keyboard-us" in engine or engine in ("us", "english"):
        return "EN"
    return engine.upper()[:4] if engine else "—"


def network_status():
    try:
        result = subprocess.run(
            ["nmcli", "--terse", "--escape", "no", "--fields", "TYPE,STATE,CONNECTION", "device", "status"],
            capture_output=True, text=True, timeout=3, check=True,
            env={**os.environ, "LC_ALL": "C"},
        )
    except (OSError, subprocess.SubprocessError):
        return {"network": "net: —", "network_type": "offline", "signal": 0}
    connections = [line.split(":", 2) for line in result.stdout.splitlines()]
    for kind in ("wifi", "ethernet"):
        for entry in connections:
            if len(entry) == 3 and entry[0] == kind and entry[1] == "connected":
                if kind == "wifi":
                    signal = 0
                    try:
                        signal_result = subprocess.run(
                            ["nmcli", "--terse", "--escape", "no", "--fields", "IN-USE,SIGNAL", "device", "wifi"],
                            capture_output=True, text=True, timeout=3, check=True,
                            env={**os.environ, "LC_ALL": "C"},
                        )
                        for signal_entry in signal_result.stdout.splitlines():
                            fields = signal_entry.split(":", 1)
                            if len(fields) == 2 and fields[0] == "*":
                                signal = int(fields[1] or 0)
                                break
                    except (OSError, subprocess.SubprocessError, ValueError):
                        pass
                    return {"network": entry[2], "network_type": "wifi", "signal": signal}
                return {"network": "eth: connected", "network_type": "ethernet", "signal": 0}
    return {"network": "net: offline", "network_type": "offline", "signal": 0}


def main():
    previous_cpu = cpu_ticks()
    while True:
        time.sleep(10)
        cpu, previous_cpu = cpu_percent(previous_cpu)
        network = network_status()
        print(json.dumps({**network, "brightness": brightness_percent(), "cpu": cpu,
                          "mem": memory_percent(), "temp": temperature_celsius(),
                          "input": input_layout()}), flush=True)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        pass
