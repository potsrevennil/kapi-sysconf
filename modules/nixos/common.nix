{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ git vim neovim wireguard-tools ];

  programs.zsh = {
    enable = true;
    promptInit = "";
  };

  services.openssh.enable = true;

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
