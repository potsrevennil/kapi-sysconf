{ pkgs, ... }:
{
  nix.enable = false;
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableBashCompletion = false;
    promptInit = "";
  };

  environment = {
    shells = with pkgs; [ bash zsh ];
    variables = {
      EDITOR = "vim";
    };

    systemPackages = with pkgs; [
      home-manager
      wezterm
      emacs
      alacritty
      libsixel
      raycast
      arc-browser
    ];
  };

  system = {
    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXPreferredViewStyle = "iconv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 14;
        KeyRepeat = 2;
      };
      dock = {
        autohide = true;
        show-recents = false;
      };
      menuExtraClock = {
        Show24Hour = false;
        ShowAMPM = true;
        ShowDate = 0;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
      };
    };
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "Agave" ]; })
      roboto
      source-sans-pro
      python311Packages.fontawesomefree
    ];
  };
}
