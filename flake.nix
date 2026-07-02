{
  description = "Han's system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
    perSystem = { pkgs, lib, system, config, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;

        config = lib.mkForce {
          allowBroken = true;
          allowUnfree = true;
        };

        overlays = import ./overlays { inherit inputs system; };
      };

      # kapi-vim is the only non-substitutable derivation this flake pulls in
      # (everything else comes from cache.nixos.org). Match the override used
      # by users/home.nix's default (lite = false) so CI caches exactly what
      # the real home-manager config builds.
      packages.kapi-vim = pkgs.kapi-vim.override {
        enable_haskell = true;
        enable_lean = true;
        enable_typst = true;
      };

      # Aggregate of every locally-defined package, so CI can populate the
      # cache for all of them with a single `nix build .#local-pkgs`.
      packages.local-pkgs = pkgs.symlinkJoin {
        name = "local-pkgs";
        paths = builtins.attrValues (builtins.removeAttrs config.packages [ "local-pkgs" ]);
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
