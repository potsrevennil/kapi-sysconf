{
  description = "Han's system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kapi-vim = {
      url = "git+file:users/home/kapi-vim?shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    # odroid-image (hosts/odroid/image) bring-up config: builds a flashable
    # NixOS+u-boot image for the odroid host from scratch. nixos-hardware
    # provides the rockchip platform module; u-boot, ATF, and rkbin come
    # from nixpkgs directly (mainline 26.05 has odroid-m2-rk3588s_defconfig).
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };
  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ ./users ];
    systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
    perSystem = { pkgs, lib, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;

        config = lib.mkForce {
          allowBroken = true;
          allowUnfree = true;
        };

        overlays = import ./overlays { inherit inputs system; };
      };

      devShells.default =
        pkgs.mkShellNoCC {
          packages = builtins.attrValues {
            inherit (pkgs)
              direnv
              nix-direnv

              nixpkgs-fmt
              nixd
              deadnix
              statix;
          };

          shellHook = ''
            export PATH=$PWD/scripts:$PATH
          '';
        };

      # Lean shell for CI: just the lint/format tools, no editor (nixd) or
      # interactive-shell (direnv) tooling, so `nix develop .#ci` pulls the
      # smallest closure the lint job needs.
      devShells.ci =
        pkgs.mkShellNoCC {
          packages = builtins.attrValues {
            inherit (pkgs)
              nixpkgs-fmt
              deadnix
              statix;
          };
        };

      # What CI builds from source, by name, for scripts/cache-deps: each
      # member's output path is its cache key. Everything else is either on
      # cache.nixos.org or config glue that builds in seconds. ubootOdroidM2
      # comes from odroid-image's own pkgs -- nixosSystem doesn't share this
      # pkgs -- so the cached path is the one the image uses.
      packages.ci-cache =
        let
          members = { inherit (pkgs) statix; }
            // lib.optionalAttrs (system == "aarch64-linux") {
            inherit (inputs.self.nixosConfigurations.odroid-image.pkgs) ubootOdroidM2;
          };
        in
        pkgs.symlinkJoin {
          name = "ci-cache";
          paths = builtins.attrValues members;
          passthru = { inherit members; };
        };
    };
  };
}
