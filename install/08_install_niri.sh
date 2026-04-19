#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

pacman_install niri xdg-desktop-portal-gtk
info 'Installed xdg-desktop-portal-gtk as the default portal for Niri.'