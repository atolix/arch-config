{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.archConfig.home;
  quickshellConfig = pkgs.callPackage ../packages/quickshell-config.nix { };
  quickshellRoot = "${quickshellConfig}/quickshell";

  renderText =
    text:
    builtins.replaceStrings
      [
        "@ARCH_CONFIG_DIR@"
        "@HOME@"
      ]
      [
        (toString quickshellConfig)
        config.home.homeDirectory
      ]
      text;
  render = source: renderText (builtins.readFile source);
  renderHyprland =
    source:
    renderText (
      builtins.replaceStrings
        [
          "exec-once = @ARCH_CONFIG_DIR@/quickshell/run.sh --no-duplicate --daemonize"
          "exec-once = hypridle"
        ]
        [
          "exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && ${pkgs.systemd}/bin/systemctl --user start arch-config-session.target"
          ""
        ]
        (builtins.readFile source)
    );
in
{
  options.archConfig.home.enable = lib.mkEnableOption "the arch-config Home Manager profile";

  config = lib.mkIf cfg.enable {
    programs.home-manager.enable = true;
    fonts.fontconfig.enable = true;

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
      nerd-fonts.jetbrains-mono
      noto-fonts
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
      "hypr/hyprland.conf".text = renderHyprland ../../home/atolix/.config/hypr/hyprland.conf;
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

    systemd.user.services.arch-config-quickshell = {
      Unit = {
        Description = "arch-config Quickshell desktop shell";
        PartOf = [ "arch-config-session.target" ];
      };
      Service = {
        ExecStart = "${quickshellRoot}/run.sh --no-duplicate";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "arch-config-session.target" ];
    };

    systemd.user.services.arch-config-hypridle = {
      Unit = {
        Description = "arch-config Hypridle daemon";
        PartOf = [ "arch-config-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "arch-config-session.target" ];
    };

    systemd.user.targets.arch-config-session.Unit.Description =
      "arch-config graphical session services";

    home.sessionVariables.ARCH_CONFIG_QUICKSHELL = quickshellRoot;
  };
}
