#source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
#   echo "Welcome to Arch Linux! Type 'fastfetch' to see your system info."
end

function fish_prompt
    set -l last_status $status

    set -l c_reset (set_color normal)
    set -l c_path (set_color blue)
    set -l c_git (set_color brblack)
    set -l c_ok (set_color magenta)
    set -l c_err (set_color red)

    # First line: current directory + git info
    #echo -n $c_path(pwd)
    echo -n $c_path(string replace --regex "^$HOME" "~" $PWD)

    if command -sq git; and command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null; or command git rev-parse --short HEAD 2>/dev/null)
        if test -n "$branch"
            echo -n " " $c_git$branch

            command git diff --no-ext-diff --quiet --exit-code 2>/dev/null
            or echo -n "*"

            command git diff --no-ext-diff --cached --quiet --exit-code 2>/dev/null
            or echo -n "*"
        end
    end

    # Prompt symbol, colored by last exit status
    if test $last_status -eq 0
        echo -n " " $c_ok"❯ "
    else
        echo -n " " $c_err"❯ "
    end

    echo -n $c_reset
end