{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.archConfig.home;
  repoRoot = ../..;
  quickshellRoot = "${repoRoot}/quickshell";

  render =
    source:
    builtins.replaceStrings
      [
        "@ARCH_CONFIG_DIR@"
        "@HOME@"
      ]
      [
        (toString repoRoot)
        config.home.homeDirectory
      ]
      (builtins.readFile source);
in
{
  options.archConfig.home.enable = lib.mkEnableOption "the arch-config Home Manager profile";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      awww
      brightnessctl
      btop
      cliphist
      fastfetch
      ghostty
      grim
      hypridle
      hyprlock
      lm_sensors
      mpv
      networkmanagerapplet
      procps
      pulseaudio
      python3
      quickshell
      slurp
      thunar
      upower
      wf-recorder
      wireplumber
      wl-clipboard
      wofi
    ];

    xdg.configFile = {
      "hypr/hyprland.conf".text = render ../../home/atolix/.config/hypr/hyprland.conf;
      "hypr/hyprlock.conf".text = render ../../home/atolix/.config/hypr/hyprlock.conf;
      "hypr/hypridle.conf".text = render ../../quickshell/hypridle.conf;
      "hypr/hyprland-osd.conf".text = render ../../quickshell/hyprland-osd.conf;

      "wofi/style.css".text = render ../../home/atolix/.config/wofi/style.css;
      "btop/btop.conf".text = render ../../home/atolix/.config/btop/btop.conf;
      "btop/themes/arch-config.theme".text =
        render ../../home/atolix/.config/btop/themes/arch-config.theme;
      "fastfetch/config.jsonc".text = render ../../home/atolix/.config/fastfetch/config.jsonc;
      "gtk-3.0/settings.ini".text = render ../../home/atolix/.config/gtk-3.0/settings.ini;
      "gtk-3.0/gtk.css".text = render ../../home/atolix/.config/gtk-3.0/gtk.css;
      "mimeapps.list".text = render ../../home/atolix/.config/mimeapps.list;
      "mpv/mpv.conf".text = render ../../home/atolix/.config/mpv/mpv.conf;

      "fcitx5/config".text = render ../../home/atolix/.config/fcitx5/config;
      "fcitx5/profile".text = render ../../home/atolix/.config/fcitx5/profile;
      "fcitx5/conf/notifications.conf".text =
        render ../../home/atolix/.config/fcitx5/conf/notifications.conf;
    };

    home.sessionVariables.ARCH_CONFIG_QUICKSHELL = quickshellRoot;
  };
}
