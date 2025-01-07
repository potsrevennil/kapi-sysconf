{ inputs, withSystem, ... }:
{
  config.flake.homeConfigurations = {
    "thing-hanlim@Thing-hans-MacBook-Pro" = withSystem "aarch64-darwin" (ctx:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = ctx.inputs'.nixpkgs.legacyPackages;

        modules = [
          # NOTE: any way of making this conciser... ?
          ({ config, pkgs, ... }: {
            inherit (ctx) nixpkgs;
            imports = [
              (import ./home {
                inherit config pkgs;
                dotfiles = "${config.home.homeDirectory}/Projects/kapi-sysconf/users/home/";
                username = "thing-hanlim";
                stateVersion = "24.11";
              })
            ];
          })
        ];
      }
    );
  };
}
