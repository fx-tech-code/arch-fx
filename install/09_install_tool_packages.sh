#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

yay_install systemd-manager-tui-bin visual-studio-code-bin
pacman_install waybar awww mako caligula gum hypridle hyprlock hyprpicker hyprshot impala bluetui wiremix fuzzel nwg-look stow polkit-gnome