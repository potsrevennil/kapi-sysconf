{ lib, buildUBoot, rkbin, uboot-src, ... }:
buildUBoot {
  # buildUBoot enables structuredAttrs, so top-level `BL31 = ...` lands only
  # as a bash var (via .attrs.json) and never reaches make/binman -- the FIT
  # assembly then fails with "missing external blobs: atf-bl31". `env = {}`
  # exports them as real env vars; matches every working RK3588 recipe in
  # nixpkgs' pkgs/misc/uboot/default.nix (ubootCM3588NAS, ubootROCK5A/B/ITX).
  env = {
    BL31 = "${rkbin}/bin/rk35/rk3588_bl31_v1.48.elf";
    ROCKCHIP_TPL = "${rkbin}/bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2400MHz_v1.18.bin";
  };
  extraMeta = {
    platforms = [ "aarch64-linux" ];
    license = lib.licenses.unfreeRedistributableFirmware;
  };
  src = uboot-src;
  version = uboot-src.rev;
  defconfig = "odroid-m2-rk3588s_defconfig";
  filesToInstall = [
    "u-boot.bin"
    "u-boot-rockchip.bin"
    "idbloader.img"
    "u-boot.itb"
  ];
}
