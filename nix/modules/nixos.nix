{ config, lib, pkgs, ... }:

let
  cfg = config.archConfig.desktop;
  sddmTheme = pkgs.callPackage ../packages/sddm-theme.nix { };
in
{
  options.archConfig.desktop.enable = lib.mkEnableOption "the arch-config NixOS desktop services";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "mysddm";
    };

    networking.networkmanager.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = pkgs.stdenv.hostPlatform.isx86_64;
      pulse.enable = true;
    };

    services.upower.enable = true;
    security.polkit.enable = true;
    security.rtkit.enable = true;

    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = [ pkgs.fcitx5-mozc ];
    };

    environment.systemPackages = [ sddmTheme ];
  };
}
