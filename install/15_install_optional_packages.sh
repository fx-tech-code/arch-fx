#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 15: Install optional packages'

pacman_install gnome-calculator gnome-text-editor loupe libreoffice-still showtime thunderbird
info 'Installed optional desktop applications.'