#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

print_heading 'Step 13: Apply dotfiles'

if [[ "${INSTALL_INVOKE_PWD:-}" != "$REPO_ROOT" ]]; then
    die "13_install_dotfiles.sh requires the installer to be started from the repo root: $REPO_ROOT"
fi

if [[ ! -x "$REPO_ROOT/deepstow" ]]; then
    die "Missing executable deepstow at $REPO_ROOT/deepstow"
fi

pacman_install stow

cd "$REPO_ROOT/script-dots"
"$REPO_ROOT/deepstow" *

cd "$REPO_ROOT/config-dots"
"$REPO_ROOT/deepstow" *

info 'Applied script-dots and config-dots from the current repo checkout.'