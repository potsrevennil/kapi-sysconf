_final: prev: {
  # statix's insta snapshot tests fail against the newer Rust toolchain
  # shipped in the current nixpkgs pin, though the upstream source rev is
  # unchanged. Skip the checkPhase until nixpkgs' statix is rebuilt with
  # matching snapshots. Darwin only: Hydra builds it fine on Linux, so
  # Linux keeps cache.nixos.org's statix instead of compiling it.
  statix =
    if prev.stdenv.hostPlatform.isDarwin
    then prev.statix.overrideAttrs (_: { doCheck = false; })
    else prev.statix;
}
