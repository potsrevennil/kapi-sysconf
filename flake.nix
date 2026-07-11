{
  description = "Han's system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

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
    # NixOS+u-boot image for the odroid host from scratch. uboot-src is
    # Kwiboo's patched rk3xxx u-boot fork; nixos-hardware provides the
    # rockchip platform module. Both unused until that config lands.
    uboot-src = {
      flake = false;
      url = "github:Kwiboo/u-boot-rockchip/rk3xxx-2025.04";
    };

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

    };
  };
}
