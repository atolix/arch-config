{
  lib,
  stdenvNoCC,
  makeWrapper,
  awww,
  bash,
  brightnessctl,
  cliphist,
  coreutils,
  fcitx5,
  grim,
  hyprland,
  hyprlock,
  lm_sensors,
  networkmanager,
  procps,
  pulseaudio,
  python3,
  quickshell,
  slurp,
  systemd,
  wf-recorder,
  wireplumber,
  wl-clipboard,
  wofi,
  writeText,
  theme ? { },
}:

let
  themeDefaults = import ../quickshell-theme.nix;
  resolvedTheme = themeDefaults // theme;
  themeJs = writeText "arch-config-quickshell-theme.js" ''
    .pragma library

    var background = ${builtins.toJSON resolvedTheme.background}
    var surface = ${builtins.toJSON resolvedTheme.surface}
    var text = ${builtins.toJSON resolvedTheme.text}
    var accent = ${builtins.toJSON resolvedTheme.accent}
    var muted = ${builtins.toJSON resolvedTheme.muted}
    var border = ${builtins.toJSON resolvedTheme.border}
    var danger = ${builtins.toJSON resolvedTheme.danger}
    var warning = ${builtins.toJSON resolvedTheme.warning}
    var success = ${builtins.toJSON resolvedTheme.success}
    var button = ${builtins.toJSON resolvedTheme.button}
    var buttonHover = ${builtins.toJSON resolvedTheme.buttonHover}
    var white = ${builtins.toJSON resolvedTheme.white}
    var onAccent = ${builtins.toJSON resolvedTheme.onAccent}
    var disabled = ${builtins.toJSON resolvedTheme.disabled}
    var secondaryText = ${builtins.toJSON resolvedTheme.secondaryText}
    var calendarWeekday = ${builtins.toJSON resolvedTheme.calendarWeekday}
    var closeIcon = ${builtins.toJSON resolvedTheme.closeIcon}
  '';
  runtimePath = lib.makeBinPath [
    awww
    bash
    brightnessctl
    cliphist
    coreutils
    fcitx5
    grim
    hyprland
    hyprlock
    lm_sensors
    networkmanager
    procps
    pulseaudio
    python3
    quickshell
    slurp
    systemd
    wf-recorder
    wireplumber
    wl-clipboard
    wofi
  ];
in
stdenvNoCC.mkDerivation {
  pname = "arch-config-quickshell";
  version = "1.0.0";

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/sddm/mysddm/pictures/wallpapers"
    cp -r ${../../quickshell} "$out/quickshell"
    chmod -R u+w "$out/quickshell"
    cp ${themeJs} "$out/quickshell/shared/Theme.js"
    cp ${../../sddm/mysddm/pictures/wallpapers/v1.jpg} \
      "$out/sddm/mysddm/pictures/wallpapers/v1.jpg"

    for program in \
      "$out/quickshell/run.sh" \
      "$out/quickshell/scripts/clipboard-picker.sh" \
      "$out/quickshell/scripts/input-toggle.py" \
      "$out/quickshell/scripts/lock-and-suspend.sh" \
      "$out/quickshell/scripts/osd-control.py" \
      "$out/quickshell/scripts/screen-record.sh" \
      "$out/quickshell/scripts/screenshot.sh" \
      "$out/quickshell/scripts/window-switcher.py"; do
      wrapProgram "$program" --prefix PATH : ${lib.escapeShellArg runtimePath}
    done

    runHook postInstall
  '';

  meta = {
    description = "Packaged Quickshell desktop configuration and runtime dependencies";
    platforms = lib.platforms.linux;
  };
}
