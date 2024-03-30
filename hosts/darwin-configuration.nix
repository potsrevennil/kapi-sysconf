{ pkgs, ... }:
{
  programs.zsh.enable = true;

  environment = {
    shells = with pkgs; [ bash zsh ];
    loginShell = pkgs.zsh;
    variables = {
      EDITOR = "vim";
    };
  };

  services.nix-daemon.enable = true;

  system = {
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
