#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 10: Install GTK themes'

pacman_install adw-gtk-theme

if command -v gsettings >/dev/null 2>&1; then
    if gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && \
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'; then
        info 'Applied GTK theme defaults with gsettings.'
    else
        warn 'Could not apply gsettings defaults automatically. You can finish this step with nwg-look.'
    fi
else
    warn 'gsettings is unavailable. You can finish this step with nwg-look.'
fi