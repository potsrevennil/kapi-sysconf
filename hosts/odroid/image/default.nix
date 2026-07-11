# Bring-up config for the odroid host: builds a flashable NixOS+u-boot
# image from scratch (targets a virtual disk, disko's image-building mode).
# Not the day-2 config -- see ../default.nix for that (real disks, tailscale,
# openssh, etc.), deployed once this image has booted and is reachable.
{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    "${inputs.nixos-hardware}/rockchip"
    "${inputs.nixos-hardware}/rockchip/disko.nix"
  ];

  disko.devices.disk.main.imageSize = "3G";

  nix = {
    package = pkgs.nixVersions.stable;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce [ "btrfs" "vfat" "ext2" ];
    kernelParams = [ "debug" "console=ttyS2,1500000" ];
    initrd.availableKernelModules = [
      "nvme"
      "nvme-core"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  hardware = {
    deviceTree = {
      enable = true;
      name = "rockchip/rk3588s-odroid-m2.dtb";
    };
    rockchip = {
      enable = true;
      platformFirmware = lib.mkDefault pkgs.ubootOdroidM2;
      diskoExtraPostVM = ''
        dd if=${pkgs.ubootOdroidM2}/u-boot-rockchip.bin of=$out/${config.hardware.rockchip.diskoImageName} bs=32k seek=1 conv=notrunc,fsync
      '';
    };
  };

  system.stateVersion = "26.05";

  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  users.users.root = {
    extraGroups = [ "networkmanager" ];
    initialPassword = lib.mkForce "odroid";
  };
}
