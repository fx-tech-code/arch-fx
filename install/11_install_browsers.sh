#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

pacman_install firefox noto-fonts
yay_install zen-browser-bin
info 'Installed noto-fonts to match the documented Firefox font selection.'