#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Directory does not exist: $TARGET"
  exit 1
fi

echo "Cleaning Terraform cache under: $TARGET"

find "$TARGET" -type d -name ".terraform" -prune -exec rm -rf {} +

find "$TARGET" -type f -name ".terraform.tfstate.lock.info" -delete

echo "Done."