#!/bin/bash
set -euo pipefail

sudo apt-get install --yes --no-install-recommends \
    ca-certificates curl git file unzip ripgrep fd-find

temporary_directory="$(mktemp -d)"
trap 'rm -rf -- "$temporary_directory"' EXIT
keyring=/usr/share/keyrings/yazi-keyring.gpg
repository_file=/etc/apt/sources.list.d/chezmoi-agent-sandbox-yazi.sources
repository_changed=false
# https://yazi-rs.github.io/docs/installation/#debian-and-ubuntu
if [[ ! -s "$keyring" ]]; then
    curl --fail --silent --show-error --location --retry 3 \
        --output "$temporary_directory/yazi-keyring.gpg" \
        https://yazi-rs.github.io/builds/yazi-keyring.gpg
    test -s "$temporary_directory/yazi-keyring.gpg"
    sudo install -m 0644 "$temporary_directory/yazi-keyring.gpg" "$keyring"
    repository_changed=true
fi
cat > "$temporary_directory/yazi.sources" <<'EOF'
Types: deb
URIs: https://yazi-rs.github.io/builds/
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/yazi-keyring.gpg
EOF
if ! cmp -s "$temporary_directory/yazi.sources" "$repository_file"; then
    sudo install -m 0644 "$temporary_directory/yazi.sources" "$repository_file"
    repository_changed=true
fi
if [[ "$repository_changed" == true ]]; then
    sudo apt-get -o APT::Update::Error-Mode=any update
fi
sudo apt-get install --yes --no-install-recommends yazi

if ! command -v fd >/dev/null; then
    sudo ln -sfn /usr/bin/fdfind /usr/local/bin/fd
fi
