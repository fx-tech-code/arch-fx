#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 08: Install Niri'

pacman_install niri xdg-desktop-portal-gnome
info 'Installed xdg-desktop-portal-gnome as the default portal for Niri.'