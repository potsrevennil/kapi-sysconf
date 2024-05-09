.PHONY: all os home update clean distclean

Q ?= @

all: os home

os:
	$(Q)darwin-rebuild switch --flake .

home:
	$(Q)home-manager switch --flake .

update:
	$(Q)nix flake update

clean:
	$(Q)nix-store --gc

distclean:
	$(Q)nix-collect-garbage -d --delete-old
