{ inputs, ... }:
{
  homeConfigurations = {
    "thing-hanlim@Thing-hans-MacBook-Pro" = {
      system = "aarch64-darwin";
      stateVersion = "24.05";
      modules = [
        ./home

        # TODO: remove this after fixing kapi-vim overlay
        # {
        #   home.packages = [
        #     inputs.kapi-vim.packages."aarch64-darwin".default
        #     inputs.kapi-vim.packages."aarch64-darwin".lsp
        #   ];
        # }
      ];
    };
  };
}
