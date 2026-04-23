#!/usr/bin/env sh
# Colorizer — thin wrapper that delegates to colorizer.py.
#
# Resolves the real directory of this script so the tool works regardless
# of the current working directory or how it is symlinked.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
exec python3 "$SCRIPT_DIR/colorizer.py" "$@"
