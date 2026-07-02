{ inputs, withSystem, ... }:
let
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
