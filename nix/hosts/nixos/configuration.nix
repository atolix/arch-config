{
  config,
  lib,
  pkgs,
  ...
}:

let
  userName = "atolix";
in
{
  linuxConfig.desktop.enable = true;
  # linuxConfig.home.username = userName;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.enableRedistributableFirmware = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "broadcom-sta" "google-chrome" ];
    # BCM4360 requires the unmaintained wl driver. Review this exception when
    # updating nixpkgs because the driver has known security issues.
    permittedInsecurePackages = [ "broadcom-sta-6.30.223.271-63-6.18.56" ];
  };
  boot = {
    blacklistedKernelModules = [
      "b43"
      "b43legacy"
      "bcma"
      "brcmfmac"
      "brcmsmac"
      "ssb"
    ];
    kernelModules = [ "wl" ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  };

  networking.hostName = "nixos";
  time.timeZone = "Asia/Tokyo";
  zramSwap = {
    enable = false;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # Run toolchains downloaded by mise on NixOS.
  programs.nix-ld.enable = true;
  environment.systemPackages = [ pkgs.gcc ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "linux-config-before-home-manager";
    users.${userName} = {
      linuxConfig.home.enable = true;
      home.username = userName;
      home.homeDirectory = "/home/${userName}";
      home.stateVersion = "26.05";
    };
  };

  system.stateVersion = "26.05";
}
