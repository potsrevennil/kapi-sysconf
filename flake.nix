{
  description = "Han's system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kapi-vim = {
      url = "git+file:users/home/kapi-vim?shallow=1";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };
  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ ./users ];
    systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
    perSystem = { pkgs, lib, ... }: {
      _module.args.nixpkgs = {
        config = lib.mkForce {
          allowBroken = true;
          allowUnfree = true;
        };

        overlays = [
          inputs.kapi-vim.overlays.default
        ];
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
