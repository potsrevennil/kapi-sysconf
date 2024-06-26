{
  description = "Han's system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kapi-vim = {
      url = "github:potsrevennil/kapi-vim?rev=996b356f66c88d1f9c2760fcf90ce0920e9cdab4";
    };
  };
  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ ./modules ./hosts ./users ];
    systems = [ "aarch64-darwin" "x86_64-darwin" ];
    perSystem = { pkgs, lib, ... }: {
      _module.args = {
        nix = {
          extraOptions = ''
            experimental-features = nix-command flakes
          '';

          settings = {
            auto-optimise-store = true;
            trusted-users = [
              "root"
              "thing-hanlim"
            ];
          };
        };
        nixpkgs = {
          config = lib.mkForce {
            allowBroken = true;
            allowUnfree = true;
          };

          overlays = lib.mkForce [
            inputs.kapi-vim.overlays.default
          ];
        };
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
            export PATH=$PWD/bin:$PATH
          '';
        };

    };
  };
}
