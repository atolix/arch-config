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
}:

let
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
    cp ${../../sddm/mysddm/pictures/wallpapers/v1.jpg} \
      "$out/sddm/mysddm/pictures/wallpapers/v1.jpg"
    chmod -R u+w "$out/quickshell"

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
