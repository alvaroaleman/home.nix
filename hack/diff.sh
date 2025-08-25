#!/usr/bin/env bash

set -euo pipefail

CURRENT="$(home-manager generations | head -1 | awk '{print $7}')"
PREVIOUS="$(home-manager generations | head -2 | tail -1| awk '{print $7}')"

nix store diff-closures "$PREVIOUS" "$CURRENT"
