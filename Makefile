.PHONY: all os home clean distclean

Q ?= @

all: os home

os:
	$(Q)darwin-rebuild switch --flake .

home:
	$(Q)home-manager switch --flake .

clean:
	$(Q)nix-store --gc

distclean:
	$(Q)nix-collect-garbage -d --delete-old
