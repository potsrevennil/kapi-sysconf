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

  mkHomeConfig = { system, username, stateVersion ? "24.11" }: withSystem system (ctx:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit (ctx) pkgs;

      modules = [
        ({ config, ... }: {
          imports = [
            (import ./home.nix {
              dotfiles = "${config.home.homeDirectory}/Projects/kapi-sysconf/users/home/";
              inherit username stateVersion;
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
        thing-hanlim = mkHomeConfig { system = "aarch64-darwin"; username = "thing-hanlim"; };

        # CI-only: same config, but aarch64-linux, to also validate it on
        # Linux -- home.nix is already OS-portable (handles isDarwin/isLinux
        # for homeDirectory), and Hydra's Linux binary cache coverage is far
        # more complete than macOS's, so this is fast even without lite. Not
        # used for the real deployed system.
        thing-hanlim-linux = mkHomeConfig { system = "aarch64-linux"; username = "thing-hanlim"; };

        # CI-only: build-equivalent to thing-hanlim(-linux) -- home.nix never
        # branches on username beyond home.username/homeDirectory -- but
        # username "runner" to match the GitHub Actions runner's actual
        # user, so `home-manager switch` can activate without a username
        # mismatch. Used by the switch step in ci.yml.
        ci = mkHomeConfig { system = "aarch64-darwin"; username = "runner"; };
        ci-linux = mkHomeConfig { system = "aarch64-linux"; username = "runner"; };
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
