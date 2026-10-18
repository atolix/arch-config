{
  description = "Reproducible Arch config modules for NixOS and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      nixosModules = {
        arch-config = import ./nix/modules/nixos.nix;
        default = self.nixosModules.arch-config;
      };

      nixosConfigurations.archlinux = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nix/hosts/archlinux/hardware-configuration.nix
          ./nix/hosts/archlinux/configuration.nix
          self.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.sharedModules = [ self.homeManagerModules.default ];
          }
        ];
      };

      homeManagerModules = {
        arch-config = import ./nix/modules/home-manager.nix;
        default = self.homeManagerModules.arch-config;
      };

      homeConfigurations.atolix = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          self.homeManagerModules.default
          {
            archConfig.home.enable = true;
            archConfig.home.quickshell.executable = "/usr/bin/quickshell";
            home = {
              username = "atolix";
              homeDirectory = "/home/atolix";
              stateVersion = "26.05";
            };
          }
        ];
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          quickshell-config = pkgs.callPackage ./nix/packages/quickshell-config.nix { };
          sddm-theme = pkgs.callPackage ./nix/packages/sddm-theme.nix { };
          live-check = pkgs.writeShellApplication {
            name = "arch-config-check";
            runtimeInputs = [ pkgs.bash ];
            text = ''
              exec ${pkgs.bash}/bin/bash ${self}/check.sh
            '';
          };
          default = sddm-theme;
        }
      );

      apps = forAllSystems (system: {
        check = {
          type = "app";
          program = "${self.packages.${system}.live-check}/bin/arch-config-check";
          meta.description = "Check the installed arch-config environment and session";
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.bash
              pkgs.kdePackages.qtdeclarative
              pkgs.nixfmt-tree
              pkgs.python3
              pkgs.shellcheck
              pkgs.shfmt
            ];
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          homeProfile = self.homeConfigurations.atolix.config.home.path;
          nixosTest = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              self.nixosModules.default
              {
                archConfig.desktop.enable = true;
                boot.loader.grub.enable = false;
                fileSystems."/".device = "/dev/null";
                system.stateVersion = "26.05";
              }
            ];
          };
        in
        {
          nixos-module =
            assert nixosTest.config.programs.hyprland.enable;
            assert nixosTest.config.programs.hyprland.withUWSM;
            assert nixosTest.config.services.displayManager.sddm.enable;
            assert nixosTest.config.services.displayManager.sddm.wayland.enable;
            assert nixosTest.config.networking.networkmanager.enable;
            assert nixosTest.config.services.pipewire.enable;
            assert nixosTest.config.services.upower.enable;
            assert nixosTest.config.i18n.inputMethod.type == "fcitx5";
            pkgs.runCommand "arch-config-nixos-module-check" { } ''
              touch "$out"
            '';

          source =
            pkgs.runCommand "arch-config-source-check"
              {
                nativeBuildInputs = [
                  pkgs.bash
                  pkgs.python3
                  pkgs.shellcheck
                ];
                src = self;
              }
              ''
                cp -r "$src" source
                chmod -R u+w source
                cd source

                bash -n \
                  install.sh \
                  bootstrap-nix.sh \
                  apply-home-manager.sh \
                  check.sh \
                  checks/*.sh \
                  quickshell/run.sh \
                  quickshell/scripts/*.sh
                shellcheck -x -P quickshell/scripts \
                  install.sh \
                  bootstrap-nix.sh \
                  apply-home-manager.sh \
                  check.sh \
                  checks/*.sh \
                  quickshell/run.sh \
                  quickshell/scripts/*.sh
                python3 -m py_compile quickshell/scripts/*.py

                touch "$out"
              '';

          quickshell-theme =
            let
              themedQuickshell = pkgs.callPackage ./nix/packages/quickshell-config.nix {
                theme.accent = "#123456";
                theme.onAccent = "#654321";
              };
            in
            pkgs.runCommand "arch-config-quickshell-theme-check" { } ''
              grep -F 'var accent = "#123456"' \
                ${themedQuickshell}/quickshell/shared/Theme.js
              grep -F 'var onAccent = "#654321"' \
                ${themedQuickshell}/quickshell/shared/Theme.js
              touch "$out"
            '';

          sddm-theme =
            let
              themedSddm = pkgs.callPackage ./nix/packages/sddm-theme.nix {
                theme.accent = "#123456";
              };
            in
            pkgs.runCommand "arch-config-sddm-theme-check" { } ''
              grep -F 'border.color: username.activeFocus ? "#123456"' \
                ${themedSddm}/share/sddm/themes/mysddm/Main.qml
              touch "$out"
            '';
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          home-manager = self.homeConfigurations.atolix.activationPackage;

          home-commands = pkgs.runCommand "arch-config-home-command-check" { } ''
            for command_name in \
              awww awww-daemon brightnessctl btop cliphist eza fastfetch fzf ghostty git \
              glslViewer gopls grim home-manager hypridle hyprlock lua-language-server \
              mise mpv nvim nm-applet pactl python3 rg rust-analyzer sensors \
              slurp solargraph tsc typescript-language-server thunar upower \
              wf-recorder wpctl wl-copy wl-paste wofi zls; do
              test -x "${homeProfile}/bin/$command_name"
            done
            test -e "${homeProfile}/lib/fcitx5/fcitx5-mozc.so"
            touch "$out"
          '';
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
