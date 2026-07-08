{ pkgs, ... }:
{
  nix.enable = false;

  # nix-darwin aborts activation rather than overwrite an unrecognized /etc
  # file (system/etc.nix's `checks` script), requiring a manual rename to
  # `.before-nix-darwin` first. This runs earlier (preActivation, before
  # checks) and does that automatically -- mirrors the exact condition
  # etc.nix itself uses (file exists and isn't already the managed
  # symlink), so it only ever touches files nix-darwin is about to replace
  # anyway, and only once (a real symlink from a prior switch is left
  # alone).
  system.activationScripts.preActivation.text = ''
    while IFS= read -r -d "" configFile; do
      subPath=''${configFile#"$systemConfig"/etc/}
      etcFile=/etc/$subPath
      etcStaticFile=/etc/static/$subPath

      if [[ -e $etcFile && $(readlink -- "$etcFile") != "$etcStaticFile" ]]; then
        mv "$etcFile" "$etcFile.before-nix-darwin"
      fi
    done < <(find -H "$systemConfig/etc" -type l -print0)
  '';
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
      nerd-fonts.agave
      roboto
      source-sans-pro
      python311Packages.fontawesomefree
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      sarasa-gothic
    ];
  };
}
