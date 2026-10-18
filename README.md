# NixOS desktop configuration

Hyprland desktop configuration for NixOS, managed as a Git repository. The
Quickshell bar lives in `quickshell/` and the system is applied through the
flake's NixOS configuration.

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
- fastfetch: the NixOS logo, labels, and values use the Quickshell palette while preserving terminal transparency.
- Thunar: dark GTK colors, compact controls, and matching selection accents.
- Video playback: mpv is the default player for common video formats.
- Idle power saving: locks after 5 minutes, suspends 5 seconds later, and turns the display off after 10 minutes as a fallback.

## NixOS

The flake exports a NixOS module and a Home Manager module. The NixOS module
enables Hyprland with UWSM, SDDM and the tracked theme, NetworkManager,
PipeWire, UPower, and Fcitx5 with Mozc. Home Manager installs the desktop
applications and renders the tracked configuration files.

The included host is a complete NixOS configuration for the current machine.

- `nixosModules.default` provides the system services.
- `homeManagerModules.default` provides the user environment.

### Clone and apply

On a fresh NixOS installation, clone the repository and apply the included
host configuration:

```sh
git clone <repository-url> ~/linux-config
cd ~/linux-config
sudo nixos-rebuild switch --flake .#nixos
```

Before the first activation, confirm that the filesystem UUIDs in
`nix/hosts/nixos/hardware-configuration.nix` match the target machine. Set a
password for the configured user during installation; passwords are not stored
in this repository.

Apply the included host as follows:

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
            linuxConfig.desktop.enable = true;

            users.users.atolix = {
              isNormalUser = true;
              extraGroups = [ "networkmanager" "wheel" ];
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.atolix = {
              imports = [ linux-config.homeManagerModules.default ];
              linuxConfig.home.enable = true;
              home.stateVersion = "26.05";
            };

            system.stateVersion = "26.05";
          }
        ];
      };
    };
}
```

The included host can be evaluated and applied directly:

```sh
nix flake check
sudo nixos-rebuild switch --flake .#nixos
```

The host user is defined once as `userName` in
`nix/hosts/nixos/configuration.nix`. Change that value, and optionally the
`linuxConfig.home.git.email` option, before the first activation on another
machine.

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

`nixosConfigurations.nixos` is the host configuration for the
current MacBookAir7,1. It includes the detected NVMe filesystems, systemd-boot,
Intel microcode, the Broadcom BCM4360 `wl` driver, and a zstd zram swap device.
Build the complete system without applying it:

```sh
nix build path:.#nixosConfigurations.nixos.config.system.build.toplevel --no-link
```

Before installing from NixOS installation media:

- confirm that the root and boot UUIDs in
  `nix/hosts/nixos/hardware-configuration.nix` still match the target disk;
- review the version-pinned `broadcom-sta` insecure-package exception—the
  unmaintained driver has known CVE-2019-9501 and CVE-2019-9502 issues;
- set a password for `atolix` during installation because no password or secret
  is committed to this repository.

The flake also exports a standalone `homeConfigurations.atolix` profile for
validating the user configuration without changing the active system:

```sh
nix build path:.#homeConfigurations.atolix.activationPackage --no-link
```

This build validates every managed dotfile and desktop package. On NixOS,
Home Manager is activated by `nixos-rebuild`; the standalone profile is useful
for checks and development.

The standalone profile currently manages the Hyprland desktop files and user
services, Git identity, Zsh aliases and completion, Mise, Fzf, Powerlevel10k,
Ghostty, Google Chrome, Codex CLI (`codex`), NetworkManager CLI (`nmcli`), the
Neovim executable and language servers, desktop fonts, and the CLI tools
referenced by those configurations. Ghostty loads its settings from
`~/dotfiles/ghostty/config`; Neovim's Lua configuration and plugins also remain
in the separate dotfiles repository.

Google Chrome is installed through Home Manager. The standalone profile
explicitly permits this non-free package; the included NixOS host permits
Google Chrome and `broadcom-sta`.

Quickshell components remain native QML so that editor support and hot reload
continue to work. Nix generates `shared/Theme.js` inside the packaged copy from
Home Manager options. For example:

```nix
linuxConfig.home.quickshell.theme = {
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

The profile uses the Quickshell executable from nixpkgs, so the packaged QML
and user service are managed entirely by Nix.

The packaged SDDM theme also derives its colors from Nix while keeping the QML
layout intact. NixOS consumers can override individual values, for example:

```nix
linuxConfig.desktop.sddm.theme.accent = "#a5b4fc";
```

Preview activation without replacing the current files:

```sh
./apply-home-manager.sh
```

After reviewing the dry-run output, activate the profile explicitly:

```sh
./apply-home-manager.sh --switch
```

Existing managed files are backed up beside the originals with a timestamped
`linux-config-before-home-manager-*` extension. The default mode is always
`--dry-run`.

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

All system packages, services, themes, and user configuration are managed by
NixOS and Home Manager.

## Run

```sh
cd ~/development/linux-config/quickshell
./run.sh
```

Quickshell hot-reloads QML changes when files are saved. Stop it with Ctrl+C.
Quickshell owns the desktop notification service.

## Volume and brightness OSD

The Hyprland key bindings are kept in `hyprland-osd.lua` and are already enabled in this setup:

```lua
dofile(os.getenv("HOME") .. "/.config/hypr/hyprland-osd.lua")
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

`~/.config/hypr/hyprland.lua` starts `linux-config-session.target` on
`hyprland.start`. Home Manager manages Quickshell and the other session services
through that target.

## Apply on NixOS

```sh
nix flake check
sudo nixos-rebuild switch --flake .#nixos
```

Home Manager renders the user configuration and NixOS installs the SDDM theme
and system packages declaratively. Restart the graphical session after the
first activation so that all user services are started.

`./check.sh` checks deployed configuration files and the running
Hyprland/Quickshell session. Use `nix flake check` for source and Nix build
validation. The same live checks can be launched through the flake with:

```sh
nix run .#check
```

## Files

```text
linux-config/
├── flake.nix                         # Export NixOS/Home Manager modules and checks
├── apply-home-manager.sh             # Preview or activate the Home Manager profile
├── check.sh                          # Check the installed NixOS desktop session
├── checks/
│   ├── commands.sh                  # Check commands and installed packages
│   ├── config.sh                    # Check rendered user configuration
│   └── session.sh                   # Check the running Hyprland and Quickshell session
├── nix/
│   ├── modules/
│   │   ├── nixos.nix                # System services and SDDM integration
│   │   └── home-manager.nix          # User packages and rendered dotfiles
│   ├── hosts/nixos/
│   │   ├── configuration.nix          # NixOS system and user settings
│   │   └── hardware-configuration.nix # Detected filesystems and boot hardware
│   └── packages/
│       └── sddm-theme.nix            # Package the tracked theme for the Nix store
├── home/atolix/.config/
│   ├── btop/
│   │   ├── btop.conf                  # Custom theme selection and transparent background
│   │   └── themes/linux-config.theme   # Colors shared with Quickshell
│   ├── fastfetch/
│   │   └── config.jsonc                # Quickshell-matched logo and text colors
│   ├── gtk-3.0/
│   │   ├── settings.ini             # Shared GTK theme settings
│   │   └── gtk.css                  # Shared GTK colors and selection styling
│   ├── hypr/
│   │   ├── hyprland.lua             # Hyprland key bindings and window rules
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
│   ├── hyprland-osd.lua              # Hardware key bindings for the OSD
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
