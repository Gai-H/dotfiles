#!/bin/bash
set -euo pipefail

version=v0.11.6
archive_root=nvim-linux-x86_64
sha256=2fc90b962327f73a78afbfb8203fd19db8db9cdf4ee5e2bef84704339add89cc

sudo apt-get install --yes --no-install-recommends \
    ca-certificates curl git unzip ripgrep fd-find build-essential tar gzip

temporary_directory="$(mktemp -d)"
trap 'rm -rf -- "$temporary_directory"' EXIT
curl --fail --silent --show-error --location --retry 3 \
    --output "$temporary_directory/nvim.tar.gz" \
    "https://github.com/neovim/neovim/releases/download/$version/$archive_root.tar.gz"
printf '%s  %s\n' "$sha256" "$temporary_directory/nvim.tar.gz" | sha256sum --check --status
tar -xzf "$temporary_directory/nvim.tar.gz" -C "$temporary_directory"

sudo mkdir -p /usr/local
sudo cp -a --no-preserve=ownership \
    "$temporary_directory/$archive_root/." \
    /usr/local/

if ! command -v fd >/dev/null; then
    sudo ln -sfn /usr/bin/fdfind /usr/local/bin/fd
fi
