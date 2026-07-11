# kapi-sysconf

Personal system configuration, managed with Nix flakes.

- **[nix-darwin](https://github.com/nix-darwin/nix-darwin)** for macOS
- **[home-manager](https://github.com/nix-community/home-manager)** for user dotfiles/packages (cross-platform)
- **NixOS** for a home server

Neovim config ([kapi-vim](https://github.com/potsrevennil/kapi-vim)) lives in its own repo, pulled in here as both a git submodule and a flake input.

## Layout

```
flake.nix         Inputs and flake-output plumbing
users/
  default.nix      Generates every darwin/home/nixos config from the host lists below
  home.nix         home-manager profile shared across all home configs
  home/            Dotfiles symlinked in via home.nix
modules/
  darwin/           Shared by every darwin host (fonts, system defaults, base packages)
  nixos/            Shared by every NixOS host (base packages, openssh, nix settings)
  shells/           home-manager module: zsh + antidote + direnv
hosts/
  wisdom-root-m4/    The Mac — only what's specific to this machine
  odroid/            The NixOS home server — hardware, disko, networking, tailscale
overlays/          kapi-vim's package overlay
```

**Adding a new host:**
1. One entry in `users/default.nix`'s `darwinHosts`/`nixosHosts`.
2. A `hosts/<dir>/default.nix` with whatever's actually specific to that machine.
3. Everything else comes for free from the matching `modules/<darwin|nixos>/common.nix`.

> **Naming note:** the flake-output key (`wisdom-root-m4`, `nixos`) must equal the machine's real hostname, since `darwin-rebuild`/`nixos-rebuild` resolve `--flake .` (no `#name`) by matching it. The `hosts/` directory name is just for humans and can be more descriptive — e.g. `hosts/odroid/` for the host whose actual hostname is `nixos`.

## Hosts

| Host | Flake output | OS | Arch |
|---|---|---|---|
| Mac (M4) | `darwinConfigurations.wisdom-root-m4` | macOS | aarch64-darwin |
| Home server | `nixosConfigurations.nixos` (dir: `hosts/odroid`) | NixOS | aarch64-linux |

`homeConfigurations.thing-hanlim` is the real, deployed home-manager profile. `homeConfigurations.thing-hanlim-linux` is the same profile built for aarch64-linux — CI-only, just to check portability against Linux's fuller binary cache coverage. Not something you'd ever deploy.

## Usage

```sh
make check          # nix flake check
make build           # dry-build the darwin system (no switch)
make diff             # build, then diff against the running system
make os                 # darwin-rebuild switch (this machine)
make nixos               # nixos-rebuild switch (run on odroid itself)
make home                  # home-manager switch

make update-core             # relock nixpkgs + darwin + home-manager only
make update                    # relock everything
make bump-kapi-vim                # pull kapi-vim's remote tip + relock that input

make clean                          # nix-store --gc
make distclean                        # nix-collect-garbage -d --delete-old
```

Always run `make build` / `make diff` before `make os` — see what's actually changing before you switch. If a switch goes wrong, `darwin-rebuild switch --flake . --rollback` gets you back to the previous generation.

## The kapi-vim submodule

`users/home/kapi-vim` is a separate repo, wired in two ways:

- **Git submodule**, so `xdg.configFile."nvim"` can symlink straight into a real checkout.
- **Local-path flake input**, with `nixpkgs`/`flake-parts` forced to follow this flake's own — so kapi-vim's package always builds against the same nixpkgs version as everything else here.

Because it's a local-path input, moving the submodule pointer alone isn't enough — `flake.lock`'s `kapi-vim` entry needs relocking too. `make bump-kapi-vim` does both; run `make home` afterward to verify.

## CI

Every push/PR: lint → `nix flake check` → real builds of every host and profile. Darwin and home-manager also get *switched* (activated), not just built — see the comments in [`.github/workflows/ci.yml`](.github/workflows/ci.yml) for the specifics.
