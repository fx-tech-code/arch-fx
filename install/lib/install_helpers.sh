#!/usr/bin/env bash

if [[ -n "${ARCH_FX_INSTALL_HELPERS_LOADED:-}" ]]; then
    return 0
fi
readonly ARCH_FX_INSTALL_HELPERS_LOADED=1

has_gum() {
    command -v gum >/dev/null 2>&1
}

print_heading() {
    local message="$1"

    echo
    if has_gum; then
        gum style --bold --foreground 212 "$message"
    else
        printf '== %s ==\n' "$message"
    fi
}

info() {
    if has_gum; then
        gum style --foreground 45 "$*"
    else
        printf '%s\n' "$*"
    fi
}

warn() {
    if has_gum; then
        gum style --foreground 214 "$*" >&2
    else
        printf 'Warning: %s\n' "$*" >&2
    fi
}

die() {
    if has_gum; then
        gum style --bold --foreground 196 "$*" >&2
    else
        printf 'Error: %s\n' "$*" >&2
    fi
    exit 1
}

require_command() {
    local command_name="$1"

    command -v "$command_name" >/dev/null 2>&1 || die "Missing required command: $command_name"
}

step_to_int() {
    printf '%d\n' "$((10#$1))"
}

validate_step_number() {
    local step="$1"

    case "$step" in
        01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

confirm() {
    local prompt="$1"
    local default_answer="${2:-Y}"

    if has_gum; then
        if [[ "$default_answer" == "Y" ]]; then
            gum confirm "$prompt"
        else
            gum confirm --default=false "$prompt"
        fi
        return $?
    fi

    local suffix='[Y/n]'
    if [[ "$default_answer" == "N" ]]; then
        suffix='[y/N]'
    fi

    local answer=''
    read -r -p "$prompt $suffix " answer
    if [[ -z "$answer" ]]; then
        [[ "$default_answer" == "Y" ]]
        return $?
    fi

    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

choose_optional_steps() {
    if has_gum; then
        local choice
        while IFS= read -r choice; do
            case "$choice" in
                "15 - Install optional Packages")
                    printf '15\n'
                    ;;
                "16 - Install Steam")
                    printf '16\n'
                    ;;
            esac
        done < <(gum choose --no-limit --header "Select optional steps" "15 - Install optional Packages" "16 - Install Steam")
        return 0
    fi

    if confirm "Run optional packages step?" "N"; then
        printf '15\n'
    fi
    if confirm "Run Steam step?" "N"; then
        printf '16\n'
    fi
}

start_sudo_keepalive() {
    sudo -v
    while true; do
        sudo -n true
        sleep 60
    done 2>/dev/null &
    export INSTALL_SUDO_KEEPALIVE_PID=$!
}

stop_sudo_keepalive() {
    if [[ -n "${INSTALL_SUDO_KEEPALIVE_PID:-}" ]]; then
        kill "$INSTALL_SUDO_KEEPALIVE_PID" 2>/dev/null || true
        unset INSTALL_SUDO_KEEPALIVE_PID
    fi
}

pacman_install() {
    sudo pacman -S --needed --noconfirm "$@"
}

yay_install() {
    require_command yay
    yay -S --needed --noconfirm "$@"
}

run_step() {
    local step_path="$1"
    local step_name
    step_name="$(basename "$step_path")"

    print_heading "Running $step_name"
    if ! bash "$step_path"; then
        die "Installation failed in $step_name"
    fi

    info "Finished $step_name"
}

pause_for_completion() {
    echo
    if has_gum; then
        gum spin --spinner dot --title "Done. Press any key to close..." -- bash -c 'read -r -n 1 -s'
    else
        read -r -n 1 -s -p 'Done. Press any key to close...'
        echo
    fi
}

multilib_is_enabled() {
    awk '
        /^\[multilib\]$/ { in_multilib=1; next }
        /^\[/ { in_multilib=0 }
        in_multilib && /^Include = \/etc\/pacman.d\/mirrorlist$/ { found=1 }
        END { exit found ? 0 : 1 }
    ' /etc/pacman.conf
}

enable_multilib() {
    local pacman_conf='/etc/pacman.conf'
    local backup_conf='/etc/pacman.conf.arch-fx.bak'
    local temp_conf

    if multilib_is_enabled; then
        info 'multilib is already enabled.'
        return 0
    fi

    temp_conf="$(mktemp)"
    if ! sudo test -f "$backup_conf"; then
        sudo cp "$pacman_conf" "$backup_conf"
        info "Backed up pacman.conf to $backup_conf"
    fi

    awk '
        BEGIN { saw_multilib=0; in_multilib=0; include_written=0 }
        /^#?\[multilib\]$/ {
            saw_multilib=1
            in_multilib=1
            include_written=0
            print "[multilib]"
            next
        }
        in_multilib && /^[#[:space:]]*Include = \/etc\/pacman.d\/mirrorlist$/ {
            print "Include = /etc/pacman.d/mirrorlist"
            include_written=1
            in_multilib=0
            next
        }
        in_multilib && /^\[/ {
            if (!include_written) {
                print "Include = /etc/pacman.d/mirrorlist"
            }
            in_multilib=0
        }
        { print }
        END {
            if (in_multilib && !include_written) {
                print "Include = /etc/pacman.d/mirrorlist"
            }
            if (!saw_multilib) {
                print ""
                print "[multilib]"
                print "Include = /etc/pacman.d/mirrorlist"
            }
        }
    ' "$pacman_conf" > "$temp_conf"

    sudo install -m 644 "$temp_conf" "$pacman_conf"
    rm -f "$temp_conf"
    sudo pacman -Sy --noconfirm
    info 'Enabled multilib and refreshed package databases.'
}