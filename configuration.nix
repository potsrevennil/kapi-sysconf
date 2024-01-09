{ pkgs, lib, ... }:
{
  programs.zsh.enable = true;
  environment.shells = [ pkgs.bash pkgs.zsh ];
  environment.loginShell = pkgs.zsh;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  services.nix-daemon.enable = true;
  system.stateVersion = 4;
  system.defaults = {
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
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [ (nerdfonts.override { fonts = [ "Agave" ]; }) ];
  };
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    casks = [ "raycast" ];
  };
}
