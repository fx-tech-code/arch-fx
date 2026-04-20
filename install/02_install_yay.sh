#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 02: Install yay'

if command -v yay >/dev/null 2>&1; then
    info 'yay is already installed.'
    exit 0
fi

pacman_install git base-devel

build_root="$(mktemp -d /tmp/yay.XXXXXX)"
trap 'rm -rf "$build_root"' EXIT

git clone https://aur.archlinux.org/yay.git "$build_root/yay"
cd "$build_root/yay"
makepkg -si --noconfirm
info 'Installed yay from AUR.'