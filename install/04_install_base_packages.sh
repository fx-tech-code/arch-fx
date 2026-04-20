#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 04: Install base packages'

pacman_install nano fzf btop fastfetch accountsservice
info 'Installed base utility packages.'