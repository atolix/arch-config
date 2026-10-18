# Linux desktop configuration

Hyprland desktop configuration, managed as a Git repository. The Quickshell bar lives in `quickshell/`.
The existing Arch installer and an additive Nix flake share the same configuration sources.

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

## Install Nix on Arch Linux

The bootstrap script installs the Arch `nix` package when necessary, initializes `/nix/store`, enables the Nix daemon, enables flakes for the current user, and checks this repository:

```sh
./bootstrap-nix.sh
```

It is safe to run the script again. Existing Nix configuration is preserved, and the required flake features are appended only when missing.

## NixOS and Home Manager

The flake exports two opt-in modules:

- `nixosModules.default` enables Hyprland with UWSM, SDDM and the tracked theme, NetworkManager, PipeWire, UPower, and Fcitx5 with Mozc.
- `homeManagerModules.default` installs the desktop applications and renders the same user configuration files used by `install.sh`.

Import both modules from a host flake and enable them as follows:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    linux-config = {
      url = "github:atolix/linux-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, linux-config, ... }:
    {
      nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          linux-config.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            archConfig.desktop.enable = true;

            users.users.atolix = {
              isNormalUser = true;
              extraGroups = [ "networkmanager" "wheel" ];
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.atolix = {
              imports = [ linux-config.homeManagerModules.default ];
              archConfig.home.enable = true;
              home.stateVersion = "26.05";
            };

            system.stateVersion = "26.05";
          }
        ];
      };
    };
}
```

Replace the host name, hardware configuration, user, and state versions for the target machine. Then evaluate and apply it from the host flake:

```sh
nix flake check
sudo nixos-rebuild switch --flake .#my-host
```

The repository itself can be checked with `nix flake check`. This validates the
Shell and Python sources, Nix configuration, generated Home Manager profile,
and packaged Quickshell configuration. Its default package is the tracked SDDM
theme, so `nix build` also verifies that the theme can be installed into the
Nix store.

Enter the reproducible development environment for `qmllint`, `qmlformat`,
`nixfmt`, `shellcheck`, `shfmt`, and Python:

```sh
nix develop
```

### Current machine host

`nixosConfigurations.archlinux` is the migration target generated for the
current MacBookAir7,1. It includes the detected NVMe filesystems, systemd-boot,
Intel microcode, the Broadcom BCM4360 `wl` driver, and a zstd zram swap device.
Build the complete system without applying it to the running Arch installation:

```sh
nix build path:.#nixosConfigurations.archlinux.config.system.build.toplevel --no-link
```

Do not run `nixos-rebuild switch` against the current Arch installation. Before
installing from NixOS installation media:

- confirm that the root and boot UUIDs in
  `nix/hosts/archlinux/hardware-configuration.nix` still match the target disk;
- review the version-pinned `broadcom-sta` insecure-package exception—the
  unmaintained driver has known CVE-2019-9501 and CVE-2019-9502 issues;
- set a password for `atolix` during installation because no password or secret
  is committed to this repository.

The flake also exports a standalone `homeConfigurations.atolix` profile. On Arch, build the complete Home Manager generation without changing the active user configuration:

```sh
nix build path:.#homeConfigurations.atolix.activationPackage --no-link
```

This build validates every managed dotfile and desktop package. The activation step remains separate so the existing Arch configuration is not replaced during validation.

The standalone profile currently manages the Hyprland desktop files and user
services, Git identity, Zsh aliases and completion, Mise, Fzf, Powerlevel10k,
Ghostty colors, the Neovim executable and language servers, desktop fonts, and
the CLI tools referenced by those configurations. Neovim's Lua configuration
and plugins remain in the separate dotfiles repository.

Quickshell components remain native QML so that editor support and hot reload
continue to work. Nix generates `shared/Theme.js` inside the packaged copy from
Home Manager options. For example:

```nix
archConfig.home.quickshell.theme = {
  background = "#cc141414";
  accent = "#a5b4fc";
  danger = "#f38ba8";
};
```

The available keys are `background`, `surface`, `text`, `accent`, `muted`,
`border`, `danger`, `warning`, `success`, `button`, `buttonHover`, `white`,
`onAccent`, `disabled`, `secondaryText`, `calendarWeekday`, and `closeIcon`.
Running Quickshell directly from the repository continues to use the tracked
`quickshell/shared/Theme.js` defaults.

The standalone Arch profile runs `/usr/bin/quickshell` so it can use the host
graphics stack. NixOS uses the Quickshell executable from nixpkgs. Other module
consumers can select an absolute executable path with
`archConfig.home.quickshell.executable` while keeping the packaged QML and user
service under Nix management.

The packaged SDDM theme also derives its colors from Nix while keeping the QML
layout intact. NixOS consumers can override individual values, for example:

```nix
archConfig.desktop.sddm.theme.accent = "#a5b4fc";
```

Preview activation without replacing the current files:

```sh
./apply-home-manager.sh
```

After reviewing the dry-run output, activate the profile explicitly:

```sh
./apply-home-manager.sh --switch
```

Existing managed files are backed up beside the originals with a timestamped `arch-config-before-home-manager-*` extension. The default mode is always `--dry-run`.

Home Manager deliberately refuses to replace symbolic links owned by another
dotfiles setup. If the dry-run reports that such a link would be clobbered,
move that link to a backup name and run the dry-run again. The link target is
left untouched, so it remains available as a pre-Nix fallback.

Start a new login shell or sign in again after the first activation so that
`~/.nix-profile/bin` is added to `PATH`. Home Manager keeps each activated
generation, which can be inspected and rolled back:

```sh
home-manager generations
home-manager -n switch --rollback # preview
home-manager switch --rollback    # activate the previous generation
```

The timestamped files remain available as a separate fallback for the original
pre-Home-Manager configuration.

The Nix modules do not replace the Arch workflow. On Arch Linux, continue to use `packages.txt` and `install.sh`; on NixOS, the modules render the placeholders to immutable Nix store paths.

## Run

```sh
cd ~/development/linux-config/quickshell
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

`./check.sh` checks the currently installed Arch packages, deployed
configuration files, and running Hyprland/Quickshell session. Use
`nix flake check` separately for source and Nix build validation. The same live
checks can be launched through the flake with:

```sh
nix run .#check
```

## Files

```text
linux-config/
├── flake.nix                         # Export NixOS/Home Manager modules and checks
├── apply-home-manager.sh             # Preview or activate the Home Manager profile
├── bootstrap-nix.sh                  # Install and initialize Nix on Arch Linux
├── check.sh                         # Check the installed and running Arch environment
├── checks/
│   ├── commands.sh                  # Check commands and installed packages
│   ├── config.sh                    # Check rendered user configuration
│   └── session.sh                   # Check the running Hyprland and Quickshell session
├── install.sh                       # Render user configs and apply the SDDM theme
├── nix/
│   ├── modules/
│   │   ├── nixos.nix                # System services and SDDM integration
│   │   └── home-manager.nix          # User packages and rendered dotfiles
│   ├── hosts/archlinux/
│   │   ├── configuration.nix          # MacBookAir7,1 system and user settings
│   │   └── hardware-configuration.nix # Detected filesystems and boot hardware
│   └── packages/
│       └── sddm-theme.nix            # Package the tracked theme for the Nix store
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
