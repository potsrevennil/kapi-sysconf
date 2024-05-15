_:
{
  homeConfigurations =
    {
      "thing-hanlim@Thing-hans-MacBook-Pro" = {
        system = "aarch64-darwin";
        stateVersion = "24.05";
        modules = [
          # NOTE: any way of making this conciser... ?
          ({ config, pkgs, ... }: {
            imports = [
              (import ./home {
                inherit config pkgs;
                dotfiles = "${config.home.homeDirectory}/Projects/kapi-sysconf/users/home/";
              })
            ];
          })
        ];
      };
    };
}
