{ inputs, pkgs, ... }:

{
  imports =
    [
      inputs.disko.nixosModules.disko
      ./hardware-configuration.nix
      ./disko.nix
    ];

  networking.hostName = "nixos";

  users = {
    defaultUserShell = pkgs.zsh;
    users.root = {
      extraGroups = [ "networkmanager" ];
      initialPassword = "odroid";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGfF2ouJnCnpjYLfQ73S+C1/vG3AgQmlbMhuCRm2YlBu thing-hanlim@wisdom-root-m4"
      ];
    };
  };

  environment.systemPackages = with pkgs; [ git vim neovim ];


  programs.zsh = {
    enable = true;
    # enableCompletion = false;
    # enableBashCompletion = false;
    promptInit = "";
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  system.stateVersion = "25.11";

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}

