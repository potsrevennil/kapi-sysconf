# kapi-sysconf

Personal system configuration, managed with Nix flakes: [nix-darwin](https://github.com/nix-darwin/nix-darwin) for macOS, [home-manager](https://github.com/nix-community/home-manager) for user dotfiles/packages (cross-platform), and NixOS for a home server. Neovim config ([kapi-vim](https://github.com/potsrevennil/kapi-vim)) lives in a separate repo, pulled in as both a git submodule and a flake input.

## Structure

```
flake.nix                    inputs (nixpkgs, nix-darwin, home-manager, disko, kapi-vim) + flake outputs plumbing
users/
  default.nix                 generates darwinConfigurations/homeConfigurations/nixosConfigurations from the host lists below
  home.nix                    home-manager profile shared by every home config (cross-platform)
  home/                        dotfiles symlinked in via home.nix (git, wezterm, alacritty, emacs, kapi-vim submodule, ...)
modules/
  darwin/common.nix            shared by every darwin host (fonts, system defaults, base packages)
  nixos/common.nix             shared by every NixOS host (base packages, openssh, nix settings)
  shells/                      home-manager module: zsh + antidote + direnv setup
hosts/
  wisdom-root-m4/               darwin host: only what's genuinely specific to this Mac
  odroid/                       NixOS host: hardware-configuration.nix, disko.nix, networking, tailscale, root user
overlays/                      kapi-vim's package overlay
```

Adding a new host: one entry in `users/default.nix`'s `darwinHosts`/`nixosHosts`, plus a `hosts/<dir>/default.nix` with whatever's actually specific to that machine. Everything else comes from the matching `modules/<darwin|nixos>/common.nix`.

The flake-output attrset key (`wisdom-root-m4`, `nixos`) must equal the machine's real hostname — `darwin-rebuild`/`nixos-rebuild` resolve `--flake .` (no `#name` suffix) by matching it. The `hosts/` directory name is free to be more descriptive (e.g. `odroid` the directory vs. `nixos` the hostname it happens to be installed with).

## Hosts

| Host | Flake output | OS | Arch |
|---|---|---|---|
| Mac (M4) | `darwinConfigurations.wisdom-root-m4` | macOS | aarch64-darwin |
| Home server | `nixosConfigurations.nixos` (dir: `hosts/odroid`) | NixOS | aarch64-linux |

`homeConfigurations.thing-hanlim` is the real deployed home-manager profile (aarch64-darwin). `homeConfigurations.thing-hanlim-linux` is the same profile on aarch64-linux, built in CI only, to check portability against Linux's fuller binary cache coverage — not used for a real deployment.

## Usage

```sh
make check         # nix flake check
make build          # dry-build the darwin system (no switch)
make diff            # build + `nix store diff-closures` against the running system
make os               # darwin-rebuild switch (this machine)
make nixos             # nixos-rebuild switch (run on odroid itself)
make home                # home-manager switch

make update-core          # relock nixpkgs + darwin + home-manager only
make update                 # relock everything
make bump-kapi-vim            # pull the kapi-vim submodule to its remote tip + relock that input

make clean                     # nix-store --gc
make distclean                   # nix-collect-garbage -d --delete-old
```

Always `make build`/`make diff` before `make os` — review what's actually changing before switching. `darwin-rebuild` keeps prior generations, so `darwin-rebuild switch --flake . --rollback` is the way back out if a switch goes wrong.

## kapi-vim submodule

`users/home/kapi-vim` is a separate repo (own history, own CI, own PRs), consumed two ways here: as a git submodule (so `xdg.configFile."nvim"` can symlink straight into a real checkout) and as a local-path flake input (`git+file:users/home/kapi-vim`, with `nixpkgs`/`flake-parts` forced to follow this flake's own via `inputs.follows`, so its package build always tracks the same nixpkgs version as everything else here).

Because it's a local-path input, bumping the submodule pointer alone doesn't update what gets built — `flake.lock`'s `kapi-vim` entry also needs relocking. `make bump-kapi-vim` does both in one step; run it (then `make home` to verify) after merging changes in the kapi-vim repo.

## CI

Every push/PR runs, in order: lint (`nixpkgs-fmt`, `deadnix`, `statix`), a cheap `nix flake check --all-systems` eval pass, then real builds of every host/profile — darwin and both home-manager legs additionally *switch* (activate) what was built, not just build it, since a successful build doesn't guarantee a successful activation. odroid's NixOS build runs on GitHub's native arm64 runner rather than emulation.
