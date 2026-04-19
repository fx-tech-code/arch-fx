#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

enable_multilib
pacman_install xorg-xwayland xwayland-satellite steam

if ! lsmod | grep -Eq '^(amdgpu|i915|nouveau|nvidia|xe)\b'; then
    warn 'No common GPU driver module is currently loaded. Verify your GPU drivers before starting Steam.'
fi