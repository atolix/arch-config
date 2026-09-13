#!/usr/bin/env python3
"""Show Hyprland windows in a Wofi list and focus the selected one."""

import configparser
import json
import subprocess
from pathlib import Path


def desktop_entries():
    entries = {}
    for desktop in Path("/usr/share/applications").glob("*.desktop"):
        parser = configparser.ConfigParser(interpolation=None, strict=False)
        try:
            parser.read(desktop, encoding="utf-8")
            entry = parser["Desktop Entry"]
            icon = entry.get("Icon", "")
            name = entry.get("Name", desktop.stem)
            keys = {desktop.stem.lower(), entry.get("StartupWMClass", "").lower()}
            for key in keys:
                if key:
                    entries.setdefault(key, (name, icon))
        except (OSError, KeyError, configparser.Error):
            continue
    return entries


def icon_path(icon):
    if not icon:
        return ""
    path = Path(icon)
    if path.is_absolute() and path.exists():
        return str(path)
    for root in (Path("/usr/share/icons"), Path("/usr/share/pixmaps")):
        for suffix in (".svg", ".png", ".xpm"):
            matches = list(root.rglob(icon + suffix))
            if matches:
                return str(matches[0])
    return icon


def main():
    clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))
    clients = [client for client in clients if client.get("mapped") and not client.get("hidden") and client.get("class") != "wofi"]
    if not clients:
        return

    entries = desktop_entries()
    rows = []
    for client in clients:
        app_id = client.get("class") or client.get("initialClass") or "Application"
        app_name, icon = entries.get(app_id.lower(), (app_id, app_id.lower()))
        title = client.get("title") or app_name
        label = f"{app_name}  |  {title}"
        rows.append((label, client["address"], icon_path(icon)))

    input_data = "".join(f"{label}\0icon\x1f{icon}\n" for label, _, icon in rows)
    result = subprocess.run(
        ["wofi", "--dmenu", "--prompt", "", "--allow-images", "--width", "760", "--height", "460"],
        input=input_data,
        text=True,
        capture_output=True,
    )
    selected = result.stdout.strip()
    for label, address, _ in rows:
        if selected == label:
            subprocess.run(["hyprctl", "dispatch", "focuswindow", f"address:{address}"], check=False)
            subprocess.run(["hyprctl", "dispatch", "alterzorder", "top"], check=False)
            break


if __name__ == "__main__":
    main()
