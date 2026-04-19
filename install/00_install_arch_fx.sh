#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib/install_helpers.sh"

export INSTALL_REPO_ROOT="$REPO_ROOT"
export INSTALL_INVOKE_PWD="$PWD"

STEP_01="$SCRIPT_DIR/01_install_git_ssh.sh"
STEP_02="$SCRIPT_DIR/02_install_yay.sh"
STEP_03="$SCRIPT_DIR/03_install_automount.sh"
STEP_04="$SCRIPT_DIR/04_install_base_packages.sh"
STEP_05="$SCRIPT_DIR/05_install_btrfs_snapshots.sh"
STEP_06="$SCRIPT_DIR/06_install_login_manager.sh"
STEP_07="$SCRIPT_DIR/07_install_terminal_shell.sh"
STEP_08="$SCRIPT_DIR/08_install_niri.sh"
STEP_09="$SCRIPT_DIR/09_install_tool_packages.sh"
STEP_10="$SCRIPT_DIR/10_install_gtk_themes.sh"
STEP_11="$SCRIPT_DIR/11_install_browsers.sh"
STEP_12="$SCRIPT_DIR/12_install_file_explorers.sh"
STEP_13="$SCRIPT_DIR/13_install_dotfiles.sh"
STEP_14="$SCRIPT_DIR/14_post_install.sh"
STEP_15="$SCRIPT_DIR/15_install_optional_packages.sh"
STEP_16="$SCRIPT_DIR/16_install_steam.sh"

BASE_STEP_NUMBERS=(01 02 03 04 05 06 07 08 09 10 11 12 13)
OPTIONAL_STEP_NUMBERS=(15 16)

step_path() {
    case "$1" in
        01) printf '%s\n' "$STEP_01" ;;
        02) printf '%s\n' "$STEP_02" ;;
        03) printf '%s\n' "$STEP_03" ;;
        04) printf '%s\n' "$STEP_04" ;;
        05) printf '%s\n' "$STEP_05" ;;
        06) printf '%s\n' "$STEP_06" ;;
        07) printf '%s\n' "$STEP_07" ;;
        08) printf '%s\n' "$STEP_08" ;;
        09) printf '%s\n' "$STEP_09" ;;
        10) printf '%s\n' "$STEP_10" ;;
        11) printf '%s\n' "$STEP_11" ;;
        12) printf '%s\n' "$STEP_12" ;;
        13) printf '%s\n' "$STEP_13" ;;
        14) printf '%s\n' "$STEP_14" ;;
        15) printf '%s\n' "$STEP_15" ;;
        16) printf '%s\n' "$STEP_16" ;;
    esac
}

START_STEP="${1:-01}"
if ! validate_step_number "$START_STEP"; then
    die 'Usage: ./install/00_install_arch_fx.sh [01-16]'
fi

if [[ "$(step_to_int "$START_STEP")" -le 13 ]] && [[ "$PWD" != "$REPO_ROOT" ]]; then
    die "Runs that include the dotfiles step must start from the repo root: $REPO_ROOT"
fi

print_heading 'arch-fx installer'
info "Repository root: $REPO_ROOT"
info "Starting from step $START_STEP"

trap stop_sudo_keepalive EXIT
start_sudo_keepalive

if [[ "$START_STEP" == '14' ]]; then
    run_step "$STEP_14"
    pause_for_completion
    exit 0
fi

for step_number in "${BASE_STEP_NUMBERS[@]}"; do
    if [[ "$(step_to_int "$step_number")" -lt "$(step_to_int "$START_STEP")" ]]; then
        continue
    fi
    run_step "$(step_path "$step_number")"
done

selected_optional_steps=()
if [[ "$START_STEP" == '15' ]]; then
    selected_optional_steps+=(15)
    if confirm 'Run Steam install after optional packages?' 'N'; then
        selected_optional_steps+=(16)
    fi
elif [[ "$START_STEP" == '16' ]]; then
    selected_optional_steps+=(16)
elif [[ "$(step_to_int "$START_STEP")" -lt 15 ]]; then
    while IFS= read -r selected_step; do
        [[ -n "$selected_step" ]] && selected_optional_steps+=("$selected_step")
    done < <(choose_optional_steps)
fi

for step_number in "${selected_optional_steps[@]}"; do
    run_step "$(step_path "$step_number")"
done

run_step "$STEP_14"
pause_for_completion