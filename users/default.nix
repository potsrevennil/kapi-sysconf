{ inputs, withSystem, ... }:
let
  mkDarwin = { username, hostPlatform ? "aarch64-darwin", stateVersion ? 5 }:
    withSystem hostPlatform (ctx:
      inputs.darwin.lib.darwinSystem {
        inherit (ctx) system pkgs;
        modules = [
          (_: {
            system.stateVersion = stateVersion;
            system.primaryUser = username;
          })

          ./darwin.nix
        ];
      }
    );

  mkHomeConfig = system: withSystem system (ctx:
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
in
{
  config = {
    flake = {
      darwinConfigurations = {
        wisdom-root-m4 = mkDarwin { username = "thing-hanlim"; };

        # Used by CI to smoke-test `nix run nix-darwin -- switch` on a
        # macos-latest runner, whose user/home is "runner"/"/Users/runner".
        ci = mkDarwin { username = "runner"; };
      };

      homeConfigurations = {
        thing-hanlim = mkHomeConfig "aarch64-darwin";

        # CI-only: same config, but aarch64-linux, to also validate it on
        # Linux -- home.nix is already OS-portable (handles isDarwin/isLinux
        # for homeDirectory), and Hydra's Linux binary cache coverage is far
        # more complete than macOS's, so this is fast even without lite. Not
        # used for the real deployed system.
        thing-hanlim-linux = mkHomeConfig "aarch64-linux";
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
