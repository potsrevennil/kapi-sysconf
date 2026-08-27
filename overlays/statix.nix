_final: prev: {
  # statix's insta snapshot tests fail against the newer Rust toolchain
  # shipped in the current nixpkgs pin, though the upstream source rev is
  # unchanged. Skip the checkPhase until nixpkgs' statix is rebuilt with
  # matching snapshots.
  statix = prev.statix.overrideAttrs (_: { doCheck = false; });
}
