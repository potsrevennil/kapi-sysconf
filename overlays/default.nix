{ inputs, ... }:
[
  inputs.kapi-vim.overlays.default
  (import ./statix.nix)
]

