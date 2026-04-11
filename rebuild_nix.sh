#!/usr/bin/env bash
set -euo pipefail

# REPO_PATH="${HOME}/nixos-config"
FLAKE_TARGET="wsl" # Match nixosConfigurations.wsl or nixosConfigurations.<anyvalue>
NIXOS_DIR="."

echo "🔧 Bootstrapping NixOS with Flakes..."
# NEW: Automatically clean CRLF before rebuilding
echo "🧼 Sanitizing line endings in .nix files..."
find . -name "*.nix" -type f -exec sed -i 's/\r$//' {} +

echo "⚙️ Rebuilding system from flake using temporary NIX_CONFIG..."
NIX_CONFIG="experimental-features = nix-command flakes" sudo nixos-rebuild switch --flake "$PWD#$FLAKE_TARGET"

echo "🔍 Checking system-managed experimental features..."
nix show-config | grep experimental-features

echo "🧼 Clean-up: No longer need external nix.conf if flake sets features declaratively."