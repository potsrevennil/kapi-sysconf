{ pkgs, lib, ... }:
{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "thing-hanlim"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  environment = {
    shells = with pkgs; [ bash zsh ];
    loginShell = pkgs.zsh;
    variables = {
      EDITOR = "vim";
    };
    systemPackages = with pkgs; [
      home-manager
    ];
  };

  services.nix-daemon.enable = true;

  system = {
    stateVersion = 4;
    defaults = {
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 14;
        KeyRepeat = 2;
      };
      dock.autohide = true;
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [ (nerdfonts.override { fonts = [ "Agave" ]; }) ];
  };

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    casks = [ "raycast" ];
    onActivation.cleanup = "zap";
  };
}
