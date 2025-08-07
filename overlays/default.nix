{ inputs, system, ... }:
let unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
in
[
  inputs.kapi-vim.overlays.default
  (_: _: {
    inherit (unstable)
      gemini-cli;
  })
]

