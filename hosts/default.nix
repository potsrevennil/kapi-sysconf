{ inputs, withSystem, ... }:
{
  config.flake.darwinConfigurations = {
    Thing-hans-MacBook-Pro = withSystem "aarch64-darwin" (ctx:
      inputs.darwin.lib.darwinSystem {
        inherit inputs;
        inherit (ctx) system;
        modules = [
          ({ ... }: {
            inherit (ctx) nixpkgs;
            system.stateVersion = 5;
          })

          ./darwin-configuration.nix
        ];
      }
    );
  };
}
