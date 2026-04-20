#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 06: Install login manager'

pacman_install ly

if systemctl is-enabled ly@tty1 >/dev/null 2>&1; then
    info 'ly@tty1 is already enabled.'
else
    sudo systemctl enable ly@tty1
fi