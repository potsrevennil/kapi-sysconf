# kapi-sysconf

Personal system configuration, managed with Nix flakes.

- **[nix-darwin](https://github.com/nix-darwin/nix-darwin)** for macOS
- **[home-manager](https://github.com/nix-community/home-manager)** for user dotfiles/packages (cross-platform)
- **NixOS** for a home server

Neovim config ([kapi-vim](https://github.com/potsrevennil/kapi-vim)) lives in its own repo, pulled in as both a git submodule and a flake input.

## Layout

```
flake.nix        Inputs and flake-output plumbing
users/
  default.nix    Generates every darwin/home/nixos config from the host lists
  home.nix       Shared home-manager profile
  home/          Dotfiles
modules/         Config shared across hosts: darwin/, nixos/, shells/
hosts/           Per-machine config
overlays/        kapi-vim's package overlay
```

## Hosts

| Host | Flake output | OS | Arch |
|---|---|---|---|
| Mac (M4) | `darwinConfigurations.wisdom-root-m4` | macOS | aarch64-darwin |
| Home server | `nixosConfigurations.nixos` (dir: `hosts/odroid`) | NixOS | aarch64-linux |

The flake-output key must equal the machine's real hostname — `darwin-rebuild`/`nixos-rebuild` resolve `--flake .` by matching it. To add a host: one entry in `users/default.nix` plus a `hosts/<dir>/default.nix`; everything else comes from the matching `modules/`.

## Usage

```sh
make check          # nix flake check
make build          # dry-build the darwin system (no switch)
make diff           # build, then diff against the running system
make os             # darwin-rebuild switch (this machine)
make nixos          # nixos-rebuild switch (run on odroid)
make home           # home-manager switch
make update         # relock everything (update-core: core inputs only)
make bump-kapi-vim  # update kapi-vim submodule + relock its input
```

## The kapi-vim submodule

`users/home/kapi-vim` is wired both as a git submodule (so `xdg.configFile."nvim"` symlinks into a real checkout) and as a local-path flake input following this flake's own `nixpkgs`. Moving the submodule pointer alone isn't enough — `flake.lock` needs relocking too; `make bump-kapi-vim` does both.

## CI

Every push/PR: lint → `nix flake check` → real builds of every host and profile, with darwin and home-manager also activated. See [`.github/workflows/ci.yml`](.github/workflows/ci.yml).
