# Quickshell bar

A small top bar for Hyprland, managed as a Git repository.

- Left: power menu; focused workspace applications are centered between the power icon and clock
- Center: local date and time in 24-hour format with seconds
- Click the clock: English calendar with previous/next month navigation and a Today button
- Power icon: Lock / Suspend / Reboot / Shutdown
- Right: keyboard layout / volume / brightness / battery / Wi-Fi or Ethernet
- Volume: scroll to change by 5%, right-click to mute, left-click to open the volume panel
- Volume icon: no wave at 0%, then one, two, or three waves for 1–33%, 34–66%, and 67–100%
- Brightness icon: light rays expand continuously with the current brightness
- Battery: percentage beside a rounded battery gauge; yellow below 30%, red below 15%, green while charging
- Wi-Fi: connected SSID; Ethernet shows `eth: connected`, and disconnected networking shows `net: offline`
- Keyboard layout: `JP` for Mozc and `EN` for the US keyboard engine
- Focused workspace apps: application names separated by `/`; the focused app uses the accent color
- Keyboard layout: press Ctrl+Space or click the `JP` / `EN` label to switch immediately
- Volume and brightness keys: an English OSD appears at the bottom center for 1.8 seconds
- Desktop notifications: Quickshell receives D-Bus notifications and shows them as cards below the top-right of the bar
- App launcher: press `Super+R` to open the Wofi application launcher with matching bar colors
- The bar appears on every monitor. The battery icon and percentage are hidden when no battery is present.

## Requirements

Arch Linux packages:

```sh
sudo pacman -S --needed quickshell hyprlock python networkmanager upower pavucontrol brightnessctl wireplumber
```

The bar expects a Wayland session with PipeWire and NetworkManager running.

## Run

```sh
cd ~/development/quickshell-bar
./run.sh
```

Quickshell hot-reloads QML changes when files are saved. Stop it with Ctrl+C.
If Waybar is still running, stop it separately to avoid displaying two bars.

Quickshell owns the desktop notification service. The setup masks the user `dunst.service` so notifications are not displayed twice.

## Volume and brightness OSD

The Hyprland key bindings are kept in `hyprland-osd.conf` and are already enabled in this setup:

```ini
source = /home/atolix/development/quickshell-bar/hyprland-osd.conf
```

Volume changes use 2% steps up to 100%; brightness changes use 10% steps. The mute key is supported.
The hardware controls continue to work even if Quickshell is stopped.
The OSD is shown on every monitor without taking keyboard focus or pointer input.

To preview the OSD without changing a value:

```sh
./scripts/osd-control.py volume show
./scripts/osd-control.py brightness show
```

## Autostart

`~/.config/hypr/hyprland.conf` is configured to start Quickshell automatically:

```ini
exec-once = /home/atolix/development/quickshell-bar/run.sh --no-duplicate --daemonize
```

For a different user or installation path, update the paths. To switch back to Waybar, replace the line with `exec-once = waybar`.

## Files

- `shell.qml`: layout, workspace apps, clock, audio, battery, and popups
- `BarText.qml`: shared font and text styling
- `BrightnessIcon.qml`: light bulb whose rays expand with brightness
- `VolumeIcon.qml`: speaker with zero to three volume waves
- `BatteryIcon.qml`: rounded battery gauge and charging color
- `VolumePopup.qml`: PipeWire volume slider and mute control
- `CalendarPopup.qml`: calendar with today highlighting and month navigation
- `PowerPopup.qml`: lock, suspend, reboot, and shutdown menu
- `NotificationPopup.qml`: event-driven desktop notification cards
- `Osd.qml`: temporary volume and brightness display
- `hyprland-osd.conf`: hardware key bindings for the OSD
- `~/.config/hypr/hyprlock.conf`: lock screen appearance
- `scripts/osd-control.py`: applies volume/brightness changes and triggers the OSD
- `scripts/input-toggle.py`: toggles Fcitx5 and updates the layout label immediately
- `scripts/metrics.py`: reads brightness, input engine, and NetworkManager status every 10 seconds
- `run.sh`: starts the configuration relative to its own location

The bar uses JetBrainsMono and a translucent dark background matching the previous Waybar setup.

Reference: [Quickshell documentation](https://quickshell.org/docs/guide/introduction/)
