_:
{
  darwinConfigurations = {
    Thing-hans-MacBook-Pro = {
      system = "aarch64-darwin";
      nixVersion = "nix_2_19";
      stateVersion = 4;
      modules = [ ./darwin-configuration.nix ];
    };
  };
}
