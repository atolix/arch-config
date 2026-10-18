{
  config,
  lib,
  pkgs,
  ...
}:

{
  archConfig.desktop.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.enableRedistributableFirmware = true;
  nixpkgs.config = {
    allowUnfreePredicate = pkg: lib.getName pkg == "broadcom-sta";
    # BCM4360 requires the unmaintained wl driver. Keep this version-pinned so
    # a nixpkgs update requires an explicit review of its security status.
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

  networking.hostName = "archlinux";
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
    backupFileExtension = "arch-config-before-home-manager";
    users.atolix = {
      archConfig.home.enable = true;
      home.stateVersion = "26.05";
    };
  };

  system.stateVersion = "26.05";
}
