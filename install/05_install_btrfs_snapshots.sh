#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

pacman_install btrfs-progs snap-pac btrfs-assistant limine-mkinitcpio-hook
yay_install limine-snapper-sync

sudo limine-update
sudo limine-snapper-sync

if sudo test -f /boot/limine/limine.conf.backup; then
    warn 'Skipping limine.conf backup because /boot/limine/limine.conf.backup already exists.'
elif sudo test -f /boot/limine/limine.conf; then
    sudo mv /boot/limine/limine.conf /boot/limine/limine.conf.backup
    info 'Backed up /boot/limine/limine.conf to /boot/limine/limine.conf.backup'
else
    warn 'Skipping limine.conf backup because /boot/limine/limine.conf is missing.'
fi