{ inputs, withSystem, ... }:
{
  config.flake.darwinConfigurations = {
    wisdom-root-m4 = withSystem "aarch64-darwin" (ctx:
      inputs.darwin.lib.darwinSystem {
        inherit (ctx) system pkgs;
        modules = [
          ({ ... }: {
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
        inherit (ctx) pkgs;

        modules = [
          ({ config, ... }: {
            imports = [
              (import ./home.nix {
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

  config.flake.nixosConfigurations = {
    nixos = withSystem "aarch64-linux" (ctx:
      inputs.nixpkgs.lib.nixosSystem {
        inherit (ctx) system;
        specialArgs = { inherit inputs; };
        modules = [
          ./odroid
        ];
      });
  };
}
