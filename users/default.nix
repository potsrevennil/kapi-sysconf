{ inputs, withSystem, ... }:
let
  # Real user, or the CI runner's user under --impure (mirrors home.nix's
  # `lite`) -- lets darwin/home-manager switch activate on CI as "runner"
  # without a separate ci-only flake output.
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

        # Same config, aarch64-linux, to check portability (home.nix is
        # OS-portable) and use Hydra's fuller Linux cache coverage.
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
