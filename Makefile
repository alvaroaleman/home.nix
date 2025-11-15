.PHONY: update
update:
	@if [ "$$(uname)" = "Darwin" ]; then \
		nix run home-manager -- switch --flake .#$$(echo $(USER) | sed 's/\./_/g')@darwin; \
	else \
		nix run home-manager -- switch --flake .#$$(echo $(USER) | sed 's/\./_/g')@linux; \
	fi

darwin:
	sudo nix run nix-darwin \
		--extra-experimental-features nix-command \
		--extra-experimental-features flakes \
		-- switch --flake .#$$(echo $(USER) | sed 's/\./_/g')

.PHONY: diff
diff:
	@./hack/diff.sh

.PHONY: cleanup
cleanup:
	nix-env --delete-generations old
	nix-store --gc
