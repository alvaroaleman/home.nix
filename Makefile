.PHONY: update
update:
	@if [ "$$(uname)" = "Darwin" ]; then \
		nix run home-manager -- switch --flake .#$(USER)@darwin; \
	else \
		nix run home-manager -- switch --flake .#$(USER)@linux; \
	fi

darwin:
	sudo nix run nix-darwin \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		-- switch --flake .#$(USER)@darwin; \

.PHONY: diff
diff:
	@./hack/diff.sh
