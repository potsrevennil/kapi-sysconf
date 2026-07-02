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
        # (skips haskell/lean/python/etc toolchains -- GHC, haskell-language-server,
        # and the python-lsp-server ecosystem for these specific package pins
        # routinely aren't covered by cache.nixos.org, forcing slow local
        # compiles) and built for aarch64-linux instead of aarch64-darwin,
        # since Hydra's Linux binary cache coverage is far more complete than
        # macOS's for these packages. home.nix is already OS-portable
        # (handles isDarwin/isLinux for homeDirectory), and nothing else it
        # references is Darwin-specific. Not used for the real deployed
        # system.
        thing-hanlim-ci = withSystem "aarch64-linux" (ctx:
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
