.PHONY: update
update:
	sudo nixos-rebuild switch --flake .#x1c

.PHONY: diff
diff:
	@./hack/diff.sh
