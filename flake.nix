{
  description = "Reproducible Arch config modules for NixOS and Home Manager";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
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

      homeManagerModules = {
        arch-config = import ./nix/modules/home-manager.nix;
        default = self.homeManagerModules.arch-config;
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          sddm-theme = pkgs.callPackage ./nix/packages/sddm-theme.nix { };
          default = sddm-theme;
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          source = pkgs.runCommand "arch-config-source-check" {
            nativeBuildInputs = [
              pkgs.bash
              pkgs.python3
            ];
            src = self;
          } ''
            cp -r "$src" source
            chmod -R u+w source
            cd source

            bash -n \
              install.sh \
              check.sh \
              checks/*.sh \
              quickshell/run.sh \
              quickshell/scripts/*.sh
            python3 -m py_compile quickshell/scripts/*.py

            touch "$out"
          '';
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
