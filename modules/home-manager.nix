{ config, lib, inputs, withSystem, ... }:
let
  inherit lib;
  inherit (lib) types;

  homeOpts = { config, name, ... }: {
    options = {
      system = lib.mkOption {
        type = types.enum [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
        description = "System architecture for the configuration.";
      };

      stateVersion = lib.mkOption {
        type = types.str;
        description = "home-manager state version, changing this value DOES NOT update the system.";
      };

      modules = lib.mkOption {
        type = types.listOf types.unspecified;
        description = "List of home-manager modules to include in the configuration.";
      };

      _home = lib.mkOption {
        type = types.unspecified;
        readOnly = true;
        description = "Composed home-manager configuration.";
      };
    };

    config._home = withSystem config.system (ctx:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = ctx.inputs'.nixpkgs.legacyPackages;

        modules = config.modules ++ [
          ({ pkgs, ... }:
            let
              username = builtins.head (lib.strings.splitString "@" name);
            in
            {
              inherit (ctx) nixpkgs;
              home = {
                username = username;
                stateVersion = config.stateVersion;
                homeDirectory = lib.mkMerge [
                  (lib.mkIf pkgs.stdenv.isDarwin "/Users/${username}")
                  (lib.mkIf pkgs.stdenv.isLinux "/home/${username}")
                ];
              };
            })
        ];
      }
    );
  };
in
{
  options.homeConfigurations = lib.mkOption {
    type = types.attrsOf (types.submodule homeOpts);
  };

  config.flake.homeConfigurations = builtins.mapAttrs (_: value: value._home) config.homeConfigurations;
}
