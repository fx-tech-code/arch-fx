#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 09: Install tool packages'

yay_install systemd-manager-tui-bin visual-studio-code-bin
pacman_install waybar awww mako caligula hypridle hyprlock hyprpicker hyprshot impala bluetui wiremix fuzzel nwg-look polkit-gnome gum
info 'Installed workstation tool packages.'