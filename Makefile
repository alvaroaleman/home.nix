.PHONY: update
update:
	@if [ "$$(uname)" = "Darwin" ]; then \
		nix run home-manager -- switch --flake .#$(USER)@darwin; \
	else \
		nix run home-manager -- switch --flake .#$(USER)@linux; \
	fi
