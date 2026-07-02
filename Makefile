.PHONY: all os home nixos check build diff update update-core bump-kapi-vim clean distclean

Q ?= @
HOST ?= wisdom-root-m4
NIXOS_HOST ?= odroid

all: os home

check:
	$(Q)nix flake check

build:
	$(Q)darwin-rebuild build --flake .#$(HOST)

diff: build
	$(Q)nix store diff-closures /run/current-system ./result

os:
	$(Q)darwin-rebuild switch --flake .#$(HOST)

nixos:
	$(Q)nixos-rebuild switch --flake .#$(NIXOS_HOST)

home:
	$(Q)home-manager switch --flake .

update:
	$(Q)nix flake update

update-core:
	$(Q)nix flake lock --update-input nixpkgs --update-input darwin --update-input home-manager

bump-kapi-vim:
	$(Q)git submodule update --remote users/home/kapi-vim
	$(Q)nix flake lock --update-input kapi-vim

clean:
	$(Q)nix-store --gc

distclean:
	$(Q)nix-collect-garbage -d --delete-old
