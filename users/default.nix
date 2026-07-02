{ inputs, withSystem, ... }:
{
  config = {
    flake = {
      darwinConfigurations = {
        wisdom-root-m4 = withSystem "aarch64-darwin" (ctx:
          inputs.darwin.lib.darwinSystem {
            inherit (ctx) system pkgs;
            modules = [
              (_: {
                system.stateVersion = 5;
                system.primaryUser = "thing-hanlim";
              })

              ./darwin.nix
            ];
          }
        );
      };

      homeConfigurations = {
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

        # CI-only: same config as thing-hanlim, but with kapi-vim's lite = true
        # so CI doesn't have to build the haskell/lean toolchain (GHC +
        # haskell-language-server for this specific package pin routinely
        # isn't covered by cache.nixos.org, forcing a slow local compile).
        # Not used for the real deployed system.
        thing-hanlim-ci = withSystem "aarch64-darwin" (ctx:
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit (ctx) pkgs;

            modules = [
              ({ config, ... }: {
                imports = [
                  (import ./home.nix {
                    dotfiles = "${config.home.homeDirectory}/Projects/kapi-sysconf/users/home/";
                    username = "thing-hanlim";
                    stateVersion = "24.11";
                    lite = true;
                  })
                ];
              })
            ];
          }
        );
      };

      nixosConfigurations = {
        nixos = withSystem "aarch64-linux" (ctx:
          inputs.nixpkgs.lib.nixosSystem {
            inherit (ctx) system;
            specialArgs = { inherit inputs; };
            modules = [
              ./odroid
            ];
          });
      };
    };
  };
}
