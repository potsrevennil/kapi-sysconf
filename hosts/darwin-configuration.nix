{ pkgs, ... }:
{
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
    ];
  };

  services.nix-daemon.enable = true;

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
      nerd-fonts.agave
      roboto
      source-sans-pro
      python311Packages.fontawesomefree
    ];
  };

  homebrew = {
    enable = true;
    brewPrefix =
      if pkgs.stdenv.hostPlatform.isAarch64 then "/opt/homebrew"
      else "/usr/local";
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    casks = [
      "raycast"
      "arc"
      "1password"
    ];
    onActivation.cleanup = "zap";
  };
}
