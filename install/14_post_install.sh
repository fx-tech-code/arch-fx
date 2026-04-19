#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

require_command fish

fish_path="$(command -v fish)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"

if [[ "$current_shell" != "$fish_path" ]]; then
    chsh -s "$fish_path"
    info "Changed login shell to $fish_path"
else
    info 'Login shell is already fish.'
fi

path_file='/etc/profile.d/local-bin.sh'
desired_path_line='export PATH="$HOME/.local/bin:$PATH"'
current_path_line=''

if sudo test -f "$path_file"; then
    current_path_line="$(sudo cat "$path_file")"
fi

if [[ "$current_path_line" != "$desired_path_line" ]]; then
    printf '%s\n' "$desired_path_line" | sudo tee "$path_file" >/dev/null
    info "Wrote $path_file"
else
    info "$path_file already contains the expected PATH export."
fi