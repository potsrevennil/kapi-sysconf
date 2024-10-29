{ inputs, withSystem, ... }:
{
  config.flake.darwinConfigurations = {
    Thing-hans-MacBook-Pro = withSystem "aarch64-darwin" (ctx:
      inputs.darwin.lib.darwinSystem {
        inherit inputs;
        inherit (ctx) system;
        modules = [
          ({ pkgs, ... }: {
            inherit (ctx) nixpkgs;

            nix = ctx.nix // {
              settings = {
                auto-optimise-store = false;
                trusted-users = [
                  "root"
                  "thing-hanlim"
                ];
              };

              package = pkgs.nixVersions.nix_2_23;
            };
            system.stateVersion = 5;
          })

          ./darwin-configuration.nix
        ];
      }
    );
  };
}
