{
  config,
  lib,
  pkgs,
  ...
}:

{
  linuxConfig.desktop.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config = {
    allowUnfreePredicate = pkg: lib.getName pkg == "broadcom-sta";
    # BCM4360 requires the unmaintained wl driver. Review this exception when
    # updating nixpkgs because the driver has known security issues.
    permittedInsecurePackages = [ "broadcom-sta-6.30.223.271-63-6.18.56" ];
  };
  boot = {
    blacklistedKernelModules = [
      "b43"
      "b43legacy"
      "bcm43xx"
      "bcma"
      "brcm80211"
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
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  users.users.atolix = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "linux-config-before-home-manager";
    users.atolix = {
      linuxConfig.home.enable = true;
      home.stateVersion = "26.05";
    };
  };

  system.stateVersion = "26.05";
}
