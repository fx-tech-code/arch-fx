"""
registry.py — App/template registry for Colorizer.

Mirrors TemplateRegistry.qml. Each entry describes an app's template
input(s) and generated artifact name(s).

Conventions
-----------
- Templates are looked up relative to TEMPLATES_DIR (resolved at runtime).
- Generated theme files are written into the current-theme directory under
    XDG config (~/.config/colorizer/current-theme by default).
- Terminals use `predefined_template_path`; this is the version that already
    contains colour-mode-agnostic variables as used by template-processor.py
    with the --scheme flag.
- Apps with a `clients` key (code) are handled specially at apply time.
- Apps with multiple outputs list them in `outputs`, each optionally
    overriding `input` for that specific output and assigning an `artifact`
    filename for the generated file.
"""

from __future__ import annotations

# ── IDs exposed through --list-apps ──────────────────────────────────────────

TERMINALS: list[dict] = [
    {
        "id": "kitty",
        "name": "Kitty",
        "category": "terminal",
        "input": "terminal/kitty.conf",
        "predefined_input": "terminal/kitty-predefined.conf",
        "outputs": [
            {"artifact": "kitty.colorizer.conf"}
        ],
    },
    {
        "id": "foot",
        "name": "Foot",
        "category": "terminal",
        "input": "terminal/foot",
        "predefined_input": "terminal/foot-predefined",
        "outputs": [
            {"artifact": "foot.colorizer"}
        ],
    },
    {
        "id": "alacritty",
        "name": "Alacritty",
        "category": "terminal",
        "input": "terminal/alacritty.toml",
        "predefined_input": "terminal/alacritty-predefined.toml",
        "outputs": [
            {"artifact": "alacritty.colorizer.toml"}
        ],
    },
]

APPLICATIONS: list[dict] = [
    # ── system ────────────────────────────────────────────────────────────────
    {
        "id": "gtk",
        "name": "GTK",
        "category": "system",
        "input": "gtk4.css",
        "outputs": [
            {"artifact": "gtk-3.colorizer.css", "input": "gtk3.css"},
            {"artifact": "gtk-4.colorizer.css", "input": "gtk4.css"},
        ],
    },
    {
        "id": "qt",
        "name": "Qt",
        "category": "system",
        "input": "qtct.conf",
        "outputs": [
            {"artifact": "qt5.colorizer.conf"},
            {"artifact": "qt6.colorizer.conf"},
        ],
    },
    # ── launchers ─────────────────────────────────────────────────────────────
    {
        "id": "fuzzel",
        "name": "Fuzzel",
        "category": "launcher",
        "input": "fuzzel.conf",
        "outputs": [
            {"artifact": "fuzzel.colorizer"}
        ],
    },
    {
        "id": "walker",
        "name": "Walker",
        "category": "launcher",
        "input": "walker.css",
        "outputs": [
            {"artifact": "walker.colorizer.css"}
        ],
    },
    # ── compositors ────────────────────────────────────────────────────────────
    {
        "id": "waybar",
        "name": "Waybar",
        "category": "compositor",
        "input": "waybar.css",
        "outputs": [
            {"artifact": "waybar.colorizer.css"}
        ],
    },
    {
        "id": "hyprlock",
        "name": "Hyprlock",
        "category": "compositor",
        "input": "hyprlock.conf",
        "outputs": [
            {"artifact": "hyprlock.colorizer"}
        ],
    },
    {
        "id": "niri",
        "name": "Niri",
        "category": "compositor",
        "input": "niri.kdl",
        "outputs": [
            {"artifact": "niri.colorizer.kdl"}
        ],
    },
    # ── misc ───────────────────────────────────────────────────────────────────
    {
        "id": "mako",
        "name": "Mako",
        "category": "misc",
        "input": "mako.conf",
        "outputs": [
            {"artifact": "mako.colorizer"}
        ],
    },
    {
        "id": "btop",
        "name": "btop",
        "category": "misc",
        "input": "btop.theme",
        "outputs": [
            {"artifact": "btop.colorizer.theme"}
        ],
    },
    {
        "id": "yazi",
        "name": "Yazi",
        "category": "misc",
        "input": "yazi.toml",
        "outputs": [
            {"artifact": "yazi.colorizer.toml"}
        ],
    },
]


# Combined flat lookup table: id → entry
ALL_APPS: dict[str, dict] = {
    entry["id"]: entry
    for entry in TERMINALS + APPLICATIONS
}


def get_app(app_id: str) -> dict | None:
    """Return the registry entry for *app_id*, or None if unknown."""
    return ALL_APPS.get(app_id)


def list_all() -> list[dict]:
    """Return every registered app/terminal in display order."""
    return TERMINALS + APPLICATIONS
