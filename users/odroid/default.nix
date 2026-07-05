{ inputs, pkgs, lib, ... }:
let
  # See users/default.nix's ciUsername for the same pattern (requires
  # --impure; GitHub Actions always sets $CI=true). hardware-configuration
  # and disko.nix are bound to real Odroid M2 hardware (device tree, a
  # specific NVMe device path, u-boot-style bootloader) that doesn't exist
  # on a CI runner, so switching a container variant needs them swapped
  # out for boot.isContainer instead.
  isCI = builtins.getEnv "CI" == "true";
in
{
  imports =
    if isCI
    then [ ]
    else [
      inputs.disko.nixosModules.disko
      ./hardware-configuration.nix
      ./disko.nix
    ];

  boot.isContainer = isCI;

  networking = {
    useDHCP = lib.mkForce true;
    networkmanager.enable = true;
    hostName = "nixos";
    nat = {
      enable = true;
      enableIPv6 = true;
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 8000 ];
    };
  };

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

  environment.systemPackages = with pkgs; [ git vim neovim wireguard-tools ];


  programs.zsh = {
    enable = true;
    promptInit = "";
  };

  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    tailscale = {
      enable = true;
      useRoutingFeatures = "server";
    };
  };

  system.stateVersion = "25.11";

  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
