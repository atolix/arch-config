# Arch configuration

Hyprland desktop configuration, managed as a Git repository. The Quickshell bar lives in `quickshell/`.

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
- Window switcher: press `Ctrl+S` for a wide Wofi list with application icons and window titles
- Idle power saving: locks after 5 minutes, suspends 5 seconds later, and turns the display off after 10 minutes as a fallback
- The bar appears on every monitor. The battery icon and percentage are hidden when no battery is present.

## Requirements

Arch Linux packages:

```sh
sudo pacman -S --needed - < packages.txt
```

The bar expects a Wayland session with PipeWire and NetworkManager running.

## Run

```sh
cd ~/development/arch-config/quickshell
./run.sh
```

Quickshell hot-reloads QML changes when files are saved. Stop it with Ctrl+C.
Quickshell owns the desktop notification service.

## Volume and brightness OSD

The Hyprland key bindings are kept in `hyprland-osd.conf` and are already enabled in this setup:

```ini
source = ~/.config/hypr/hyprland-osd.conf
```

Volume changes use 2% steps up to 100%; brightness changes use 10% steps. The mute key is supported.
The hardware controls continue to work even if Quickshell is stopped.
The OSD is shown on every monitor without taking keyboard focus or pointer input.

To preview the OSD without changing a value:

```sh
./quickshell/scripts/osd-control.py volume show
./quickshell/scripts/osd-control.py brightness show
```

## Autostart

`~/.config/hypr/hyprland.conf` is configured to start Quickshell automatically:

```ini
exec-once = <repo>/quickshell/run.sh --no-duplicate --daemonize
```

`install.sh` renders the repository path into the active Hyprland configuration.

## Install and apply

```sh
sudo pacman -S --needed - < packages.txt
./install.sh
./check.sh
```

The installer renders user configuration files into `~/.config` and applies the tracked SDDM theme and system configuration with sudo. Existing files are backed up under `~/.local/state/arch-config/backups/` before they are replaced.

## Files

- `quickshell/shell.qml`: layout, workspace apps, clock, audio, battery, and popups
- `quickshell/*.qml`: shared bar widgets and popups
- `quickshell/hyprland-osd.conf`: hardware key bindings for the OSD
- `quickshell/hypridle.conf`: idle locking, display power saving, and suspend timers
- `home/atolix/.config/hypr/hyprlock.conf`: lock screen appearance
- `quickshell/scripts/osd-control.py`: applies volume/brightness changes and triggers the OSD
- `quickshell/scripts/input-toggle.py`: toggles Fcitx5 and updates the layout label immediately
- `quickshell/scripts/window-switcher.py`: lists Hyprland windows in Wofi and focuses the selected one
- `quickshell/scripts/metrics.py`: reads brightness, input engine, and NetworkManager status every 10 seconds
- `quickshell/run.sh`: starts the bar configuration relative to its own location

The bar uses JetBrainsMono and a translucent dark background matching the previous Waybar setup.

Reference: [Quickshell documentation](https://quickshell.org/docs/guide/introduction/)
