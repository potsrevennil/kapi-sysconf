{ inputs, withSystem, ... }:
{
  config.flake.darwinConfigurations = {
    wisdom-root-m4 = withSystem "aarch64-darwin" (ctx:
      inputs.darwin.lib.darwinSystem {
        inherit inputs;
        inherit (ctx) system;
        modules = [
          ({ ... }: {
            inherit (ctx) nixpkgs;
            system.stateVersion = 5;
            system.primaryUser = "thing-hanlim";
          })

          ./darwin.nix
        ];
      }
    );
  };

  config.flake.homeConfigurations = {
    thing-hanlim = withSystem "aarch64-darwin" (ctx:
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = ctx.inputs'.nixpkgs.legacyPackages;

        modules = [
          # NOTE: any way of making this conciser... ?
          ({ config, pkgs, ... }: {
            inherit (ctx) nixpkgs;
            imports = [
              (import ./home.nix {
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
