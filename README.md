# Arch configuration

Hyprland desktop configuration, managed as a Git repository. The Quickshell bar lives in `quickshell/`.

## Quickshell bar

| Position | Display |
| --- | --- |
| Left | Power menu, workspace indicators, and focused application names |
| Center | Local date and time in 24-hour format with seconds; active media appears between the clock and status icons |
| Left rail | Focused application names and `cpu: yy% / mem: xx% / temp: zz°C / fan: n RPM` |
| Right | Keyboard layout, volume, brightness, battery, network, and notification icons |

| Component | Behavior |
| --- | --- |
| Workspaces | Empty spaces use hollow dots, occupied spaces use accent dots, and the current space uses a wider bar. Click a dot or press `Super+1`–`Super+5`. |
| Power | Lock, suspend, reboot, and shutdown menu. `Super+Ctrl+Q` locks immediately. |
| Volume | Scroll changes by 5%, right-click mutes, and left-click opens the volume panel. The icon shows 0–3 waves, or headphones when a headphone/headset output is active. |
| Brightness | The icon changes with brightness; clicking opens the brightness OSD. |
| Battery | Rounded gauge with percentage; charging is green, low charge is yellow, and critical charge is red. |
| Network | Wi‑Fi signal, Ethernet, or disconnected icon. The SSID is not shown. |
| Keyboard | `JP` / `EN`; click or press Ctrl+Space to switch immediately. |
| Clock | Click for an English calendar with month navigation and a Today button. |
| Media | Shows the active MPRIS track and playback state; long titles continuously scroll left. Click for artwork, track details, playback controls, and seeking. |
| Notifications | Quickshell keeps D-Bus notifications in a center opened from the bell icon. The badge shows the count; notifications can be dismissed individually or cleared together. |
| OSD | Volume and brightness changes show an English OSD at the bottom center for 1.8 seconds. |

The bar appears on every monitor. The battery icon and percentage are hidden when no battery is present.

## Other desktop tools

- App launcher: press `Super+R` for the Wofi application launcher.
- Clipboard history: press `Super+Shift+C` to search and paste saved text or images with Wofi.
- Screenshot: press `Super+Shift+4` to select an area and save it under `~/Pictures/Screenshots/`.
- Screen recording: press `Super+Shift+5` to select an area and start or stop recording under `~/Videos/Recordings/`.
- Window switcher: press `Ctrl+S` for a wide Wofi list with application icons and window titles.
- btop: custom colors match Quickshell, while the terminal supplies the transparent background.
- fastfetch: the Arch logo, labels, and values use the Quickshell palette while preserving terminal transparency.
- Thunar: dark GTK colors, compact controls, and matching selection accents.
- Video playback: mpv is the default player for common video formats.
- Idle power saving: locks after 5 minutes, suspends 5 seconds later, and turns the display off after 10 minutes as a fallback.

## Requirements

Arch Linux packages:

```sh
sudo pacman -S --needed - < packages.txt
```

The bar expects a Wayland session with PipeWire, its PulseAudio compatibility service, and NetworkManager running.

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
Restart Thunar after applying the settings to load the new GTK theme.

## Files

```text
arch-config/
├── check.sh                         # Run all validation checks
├── checks/
│   ├── commands.sh                  # Check commands and installed packages
│   ├── config.sh                    # Check rendered user configuration
│   ├── syntax.sh                    # Check shell, Python, and Git syntax
│   └── session.sh                   # Check the running Hyprland and Quickshell session
├── install.sh                       # Render user configs and apply the SDDM theme
├── packages.txt                     # Required Arch packages
├── home/atolix/.config/
│   ├── btop/
│   │   ├── btop.conf                  # Custom theme selection and transparent background
│   │   └── themes/arch-config.theme   # Colors shared with Quickshell
│   ├── fastfetch/
│   │   └── config.jsonc                # Quickshell-matched logo and text colors
│   ├── gtk-3.0/
│   │   ├── settings.ini             # Shared GTK theme settings
│   │   └── gtk.css                  # Shared GTK colors and selection styling
│   ├── hypr/
│   │   ├── hyprland.conf            # Hyprland key bindings and window rules
│   │   └── hyprlock.conf             # Lock screen appearance
│   └── wofi/style.css                # Launcher and window switcher styling
├── quickshell/
│   ├── shell.qml                     # Services, panel instances, and popup wiring
│   ├── topbar/
│   │   ├── TopBar.qml                # Top bar layout
│   │   ├── StatusIndicators.qml      # Keyboard, volume, brightness, battery, and network
│   │   ├── MediaDisplay.qml          # Active MPRIS track with play/pause control
│   │   ├── WorkspaceSwitcher.qml     # Workspace indicators and switching
│   │   ├── ClockDisplay.qml          # Date, time, seconds, and timezone
│   │   └── BatteryStatus.qml          # Battery percentage and icon
│   ├── leftrail/
│   │   ├── LeftRail.qml              # Left-side application and statistics rail
│   │   ├── AppList.qml               # Focused application names
│   │   └── StatsText.qml             # CPU, memory, temperature, and fan text
│   ├── popups/
│   │   ├── CalendarPopup.qml
│   │   ├── VolumePopup.qml
│   │   ├── PowerPopup.qml
│   │   ├── MediaPopup.qml
│   │   └── NotificationPopup.qml
│   ├── shared/
│   │   ├── BarText.qml               # Shared text styling
│   │   ├── BatteryIcon.qml
│   │   ├── BrightnessIcon.qml
│   │   ├── VolumeIcon.qml
│   │   ├── AnimatedPopup.qml         # Shared fade and scale transition
│   │   ├── Osd.qml
│   │   ├── Theme.js                   # Shared colors
│   │   └── HyprlandHelpers.js         # Hyprland data helpers
│   ├── hypridle.conf                 # Idle locking and suspend timers
│   ├── hyprland-osd.conf             # Hardware key bindings for the OSD
│   ├── run.sh                         # Start Quickshell relative to this directory
│   └── scripts/
│       ├── paths.sh                  # Shared screenshot and recording directories
│       ├── audio-output.py           # Detect the active speaker or headphone output
│       ├── metrics.py                # Brightness, input, network, CPU, memory, and temperature
│       ├── osd-control.py             # Apply volume/brightness changes and show the OSD
│       ├── input-toggle.py            # Toggle Fcitx5 and update the layout label
│       ├── window-switcher.py         # List and focus Hyprland windows in Wofi
│       └── lock-and-suspend.sh        # Lock and suspend after idle timeouts
├── etc/sddm.conf.d/theme.conf        # SDDM theme selection
└── sddm/mysddm/                      # Tracked SDDM theme files
```

The bar uses JetBrainsMono and a translucent dark background matching the previous Waybar setup.

Reference: [Quickshell documentation](https://quickshell.org/docs/guide/introduction/)
