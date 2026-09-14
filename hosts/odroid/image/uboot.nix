{ lib, buildUBoot, armTrustedFirmwareRK3588, rkbin, ... }:
buildUBoot {
  defconfig = "odroid-m2-rk3588s_defconfig";
  extraMeta = {
    platforms = [ "aarch64-linux" ];
    license = lib.licenses.unfreeRedistributableFirmware;
  };
  # buildUBoot enables structuredAttrs, so top-level `BL31 = ...` lands only
  # as a bash var (via .attrs.json) and never reaches make/binman -- the FIT
  # assembly then fails with "missing external blobs: atf-bl31". `env = {}`
  # exports them as real env vars; matches every working RK3588 recipe in
  # nixpkgs' pkgs/misc/uboot/default.nix (ubootCM3588NAS, ubootROCK5A/B/ITX).
  env = {
    BL31 = "${armTrustedFirmwareRK3588}/bl31.elf";
    ROCKCHIP_TPL = rkbin.TPL_RK3588;
  };
  filesToInstall = [
    "u-boot.bin"
    "u-boot-rockchip.bin"
    "idbloader.img"
    "u-boot.itb"
  ];
}
