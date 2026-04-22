"""
config.py — Persistent state for Colorizer.

Stores the last-used scheme name and mode in:
    $XDG_CONFIG_HOME/colorizer/colorizer.json
    (falls back to ~/.config/colorizer/colorizer.json)
"""

from __future__ import annotations

import json
import os
from pathlib import Path

_CONFIG_DIR = Path(
    os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")
) / "colorizer"

CONFIG_PATH: Path = _CONFIG_DIR / "colorizer.json"
CURRENT_THEME_DIR: Path = _CONFIG_DIR / "current"
COLORSCHEMES_DIR: Path = _CONFIG_DIR / "schemes"

_DEFAULTS: dict = {
    "lastScheme": "",
    "lastMode": "dark",
}


def load() -> dict:
    """Return persisted config, merged with defaults for missing keys."""
    if not CONFIG_PATH.exists():
        return dict(_DEFAULTS)
    try:
        with CONFIG_PATH.open() as fh:
            data = json.load(fh)
        return {**_DEFAULTS, **data}
    except (json.JSONDecodeError, OSError):
        return dict(_DEFAULTS)


def save(scheme: str, mode: str) -> None:
    """Persist *scheme* and *mode* to disk."""
    _CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    data = load()
    data["lastScheme"] = scheme
    data["lastMode"] = mode
    with CONFIG_PATH.open("w") as fh:
        json.dump(data, fh, indent=2)
        fh.write("\n")
