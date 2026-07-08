{ inputs, withSystem, ... }:
let
  # Real user, or CI's actual user under --impure (mirrors home.nix's
  # `lite`) -- avoids a separate ci-only output.
  ciUsername =
    if builtins.getEnv "CI" == "true"
    then builtins.getEnv "USER"
    else "thing-hanlim";

  mkHomeConfig = { system, username, stateVersion ? "25.05" }: withSystem system (ctx:
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

  # Adding a host: one entry here + a hosts/<dir>/default.nix with whatever
  # is genuinely specific to that machine. Everything else comes from
  # modules/<class>/common.nix, shared by every host of that class.
  #
  # The attrset key is the flake output name and must equal the machine's
  # actual hostname -- darwin-rebuild/nixos-rebuild resolve `--flake .`
  # (no `#name` suffix) by matching it. `dir` is just the hosts/ directory
  # name and is free to be more descriptive (e.g. "nixos" the hostname vs.
  # "odroid" the directory, since "odroid" is more recognizable to a human
  # than the generic hostname it happens to be installed with).
  darwinHosts = {
    wisdom-root-m4 = { system = "aarch64-darwin"; dir = "wisdom-root-m4"; };
  };

  nixosHosts = {
    nixos = { system = "aarch64-linux"; dir = "odroid"; };
  };
in
{
  config = {
    flake = {
      # system.primaryUser is injected here (not in hosts/<dir>) so every
      # darwin host picks up ciUsername uniformly, the same way CI needs it.
      darwinConfigurations = builtins.mapAttrs
        (_: host: withSystem host.system (ctx:
          inputs.darwin.lib.darwinSystem {
            inherit (ctx) system pkgs;
            modules = [
              (_: { system.primaryUser = ciUsername; })
              ../modules/darwin/common.nix
              ../hosts/${host.dir}
            ];
          }
        ))
        darwinHosts;

      homeConfigurations = {
        thing-hanlim = mkHomeConfig { system = "aarch64-darwin"; username = ciUsername; };

        # Same config, aarch64-linux: portability check, plus Hydra's
        # fuller Linux cache coverage.
        thing-hanlim-linux = mkHomeConfig { system = "aarch64-linux"; username = ciUsername; };
      };

      nixosConfigurations = builtins.mapAttrs
        (_: host: withSystem host.system (ctx:
          inputs.nixpkgs.lib.nixosSystem {
            inherit (ctx) system;
            specialArgs = { inherit inputs; };
            modules = [
              ../modules/nixos/common.nix
              ../hosts/${host.dir}
            ];
          }
        ))
        nixosHosts;
    };
  };
}
