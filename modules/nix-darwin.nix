{ config, lib, inputs, withSystem, ... }:
let
  inherit lib;
  inherit (lib) types;

  darwinOpts = { config, ... }: {
    options = {
      system = lib.mkOption {
        type = types.enum [ "aarch64-darwin" "x86_64-darwin" ];
        description = "System architecture for the configuration.";
      };

      nixVersion = lib.mkOption {
        type = types.str;
        description = "nix version";
      };

      stateVersion = lib.mkOption {
        type = types.int;
        description = "nix-darwin state version, changing this value DOES NOT update the system.";
      };

      modules = lib.mkOption {
        type = types.listOf types.unspecified;
        description = "List of nix-darwin modules to include in the configuration.";
      };

      _darwin = lib.mkOption {
        type = types.unspecified;
        readOnly = true;
        description = "Composed nix-darwin configuration.";
      };
    };

    config._darwin = withSystem config.system (ctx:
      inputs.darwin.lib.darwinSystem {
        inherit inputs;
        inherit (ctx) system;
        modules = config.modules ++ [
          ({ pkgs, ... }: {
            inherit (ctx) nixpkgs;
            nix = ctx.nix // { package = pkgs.nixVersions.${config.nixVersion}; };
            system.stateVersion = config.stateVersion;
            environment.systemPackages = [ pkgs.home-manager pkgs.alacritty ];
          })
        ];
      }
    );
  };
in
{
  options.darwinConfigurations = lib.mkOption {
    type = types.attrsOf (types.submodule darwinOpts);
  };

  config.flake.darwinConfigurations = builtins.mapAttrs (_: value: value._darwin) config.darwinConfigurations;
}
