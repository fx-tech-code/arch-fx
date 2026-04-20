#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 07: Install terminal and shell'

pacman_install kitty foot fish
info 'Installed terminal and shell packages (kitty, foot, fish).'
