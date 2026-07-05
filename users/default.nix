{ inputs, withSystem, ... }:
let
  # Defaults to the real machine's user, or the CI runner's actual user
  # (matching home.nix's `lite` -- see there for why --impure is required)
  # when built with --impure in CI. This lets darwin/home-manager switch
  # activate on a GitHub Actions runner (whose user is "runner", not
  # "thing-hanlim") without a separate ci-only flake output to maintain.
  ciUsername =
    if builtins.getEnv "CI" == "true"
    then builtins.getEnv "USER"
    else "thing-hanlim";

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
        wisdom-root-m4 = mkDarwin { username = ciUsername; };
      };

      homeConfigurations = {
        thing-hanlim = mkHomeConfig { system = "aarch64-darwin"; username = ciUsername; };

        # Same config, but aarch64-linux, to also validate it on Linux --
        # home.nix is already OS-portable (handles isDarwin/isLinux for
        # homeDirectory), and Hydra's Linux binary cache coverage is far
        # more complete than macOS's, so this is fast even without lite.
        # Only used for real deployment on aarch64-darwin; the aarch64-linux
        # build exists purely for this portability check (and, like
        # thing-hanlim, doubles as CI's switch target via ciUsername).
        thing-hanlim-linux = mkHomeConfig { system = "aarch64-linux"; username = ciUsername; };
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
