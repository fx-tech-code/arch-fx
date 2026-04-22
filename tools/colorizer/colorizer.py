#!/usr/bin/env python3
"""
colorizer.py — CLI entry point for Colorizer.

Usage
-----
  Colorizer --list-colorschemas
  Colorizer --list-apps
  Colorizer <scheme> <dark|light> --all-apps
  Colorizer <scheme> <dark|light> <app1,app2,...>

Examples
--------
  Colorizer --list-colorschemas
  Colorizer --list-apps
  Colorizer Dracula dark --all-apps
  Colorizer Dracula dark kitty
  Colorizer Nord light gtk,fuzzel,niri
  Colorizer "Catppuccin" dark kitty,alacritty,gtk,code
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

import config
import registry

# ── Paths (templates from repo, user data from config) ───────────────────────
SCRIPT_DIR = Path(__file__).resolve().parent
TEMPLATES_DIR = SCRIPT_DIR / "Asset" / "Templates"
COLORSCHEME_DIR = config.COLORSCHEMES_DIR
OUTPUT_DIR = config.CURRENT_THEME_DIR
TEMPLATE_PROCESSOR = SCRIPT_DIR / "template-processor.py"

CACHE_DIR = Path(
    os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")
) / "colorizer"


# ── Scheme discovery ──────────────────────────────────────────────────────────

def _scheme_display_name(path: Path) -> str:
    """Convert a scheme JSON path to the display name shown to users."""
    stem = path.stem
    if stem.lower().endswith("-default"):
        return "Colorizer (default)"
    return stem


def list_colorschemas() -> list[tuple[str, Path]]:
    """
    Return all discovered colour schemes as (display_name, path) pairs,
    sorted by display name (case-insensitive).
    """
    schemes: list[tuple[str, Path]] = []
    for json_file in COLORSCHEME_DIR.rglob("*.json"):
        schemes.append((_scheme_display_name(json_file), json_file))
    schemes.sort(key=lambda x: x[0].lower())
    return schemes


def resolve_scheme(name: str) -> Path | None:
    """
    Resolve a user-supplied scheme name to a JSON file path.

    Matching rules (in priority order):
    1. Exact display name match (e.g. "Dracula", "Colorizer (default)")
    2. Case-insensitive display name match
    3. Stem match regardless of case (e.g. "dracula" → Dracula.json)
    """
    schemes = list_colorschemas()
    name_lower = name.lower().strip()

    # 1. Exact
    for display, path in schemes:
        if display == name:
            return path

    # 2. Case-insensitive display
    for display, path in schemes:
        if display.lower() == name_lower:
            return path

    # 3. Stem
    for display, path in schemes:
        if path.stem.lower() == name_lower:
            return path

    return None


# ── TOML config building ──────────────────────────────────────────────────────

def _escape_toml(value: str) -> str:
    """Escape backslashes and double-quotes for TOML basic strings."""
    return value.replace("\\", "\\\\").replace('"', '\\"')


def _expand_path(p: str) -> str:
    """Expand leading ~ to $HOME."""
    home = str(Path.home())
    return p.replace("~", home, 1)


def _artifact_output_path(artifact_name: str) -> str:
    """Return the absolute path for a generated artifact in current-theme/."""
    return str(OUTPUT_DIR / artifact_name)


def build_toml(app_ids: list[str], mode: str) -> str:
    """
    Build a TOML configuration string for template-processor.py.

    Mirrors the logic of TemplateProcessor.qml::buildPredefinedTemplateConfig
    and addApplicationTheming.
    """
    lines: list[str] = ["[config]"]

    for app_id in app_ids:
        entry = registry.get_app(app_id)
        if entry is None:
            continue  # already validated upstream

        # ── terminals ────────────────────────────────────────────────────────
        if entry.get("category") == "terminal":
            template_name = entry["id"]
            input_rel = entry["predefined_input"]
            input_path = str(TEMPLATES_DIR / input_rel)
            output_path = _artifact_output_path(entry["outputs"][0]["artifact"])

            lines.append(f"\n[templates.{template_name}]")
            lines.append(f'input_path = "{_escape_toml(input_path)}"')
            lines.append(f'output_path = "{_escape_toml(output_path)}"')

        # ── code / VSCode special case ────────────────────────────────────────
        elif entry["id"] == "code":
            input_path = str(TEMPLATES_DIR / entry["input"])
            for client in entry["clients"]:
                section = f"code_{client['name']}"
                artifact_name = f"{client['name']}.colorizer.json"
                out_path = _artifact_output_path(artifact_name)
                lines.append(f"\n[templates.{section}]")
                lines.append(f'input_path = "{_escape_toml(input_path)}"')
                lines.append(f'output_path = "{_escape_toml(out_path)}"')

        # ── regular apps with outputs list ────────────────────────────────────
        else:
            for idx, output in enumerate(entry.get("outputs", [])):
                section = f"{entry['id']}_{idx}"
                input_rel = output.get("input", entry["input"])
                input_path = str(TEMPLATES_DIR / input_rel)
                output_path = _artifact_output_path(output["artifact"])

                lines.append(f"\n[templates.{section}]")
                lines.append(f'input_path = "{_escape_toml(input_path)}"')
                lines.append(f'output_path = "{_escape_toml(output_path)}"')

    return "\n".join(lines) + "\n"


# ── Apply ─────────────────────────────────────────────────────────────────────

def apply_scheme(scheme_name: str, mode: str, app_ids: list[str]) -> int:
    """
    Main apply pipeline.  Returns exit code (0 = success).
    """
    # 1. Resolve scheme path
    scheme_path = resolve_scheme(scheme_name)
    if scheme_path is None:
        known = [name for name, _ in list_colorschemas()]
        print(
            f"Error: Unknown colour scheme '{scheme_name}'.\n"
            f"Run --list-colorschemas to see available schemes.",
            file=sys.stderr,
        )
        return 1

    # 2. Validate app IDs
    unknown_apps = [a for a in app_ids if registry.get_app(a) is None]
    if unknown_apps:
        print(
            f"Error: Unknown app(s): {', '.join(unknown_apps)}\n"
            f"Run --list-apps to see supported app IDs.",
            file=sys.stderr,
        )
        return 1

    # 3. Load scheme JSON and extract the correct mode variant
    try:
        with scheme_path.open() as fh:
            scheme_data: dict = json.load(fh)
    except (OSError, json.JSONDecodeError) as exc:
        print(f"Error reading scheme file: {exc}", file=sys.stderr)
        return 1

    if "dark" in scheme_data or "light" in scheme_data:
        # Dual-mode scheme; fall back to the other mode if requested one is absent
        variant = scheme_data.get(mode) or scheme_data.get(
            "light" if mode == "dark" else "dark"
        )
    else:
        # Single-mode scheme — use as-is
        variant = scheme_data

    if variant is None:
        print(f"Error: Scheme '{scheme_name}' contains no '{mode}' variant.", file=sys.stderr)
        return 1

    # 4. Prepare cache directory
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    scheme_json_path = CACHE_DIR / "predefined-scheme.json"
    toml_config_path = CACHE_DIR / "theming.predefined.toml"

    # Write the full scheme data (both modes) so template-processor.py can
    # resolve "default" references correctly.
    try:
        with scheme_json_path.open("w") as fh:
            json.dump(scheme_data, fh, indent=2)
            fh.write("\n")
    except OSError as exc:
        print(f"Error writing scheme JSON: {exc}", file=sys.stderr)
        return 1

    # 5. Build and write TOML config
    toml_content = build_toml(app_ids, mode)
    try:
        with toml_config_path.open("w") as fh:
            fh.write(toml_content)
    except OSError as exc:
        print(f"Error writing TOML config: {exc}", file=sys.stderr)
        return 1

    # 6. Ensure output directory exists and clean old generated files
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    if OUTPUT_DIR.exists():
        for f in OUTPUT_DIR.iterdir():
            if f.is_file():
                f.unlink()

    # 7. Run template-processor.py
    cmd = [
        sys.executable,
        str(TEMPLATE_PROCESSOR),
        "--scheme", str(scheme_json_path),
        "--config", str(toml_config_path),
        "--default-mode", mode,
    ]
    result = subprocess.run(cmd, cwd=str(SCRIPT_DIR))
    if result.returncode != 0:
        print("Error: template-processor.py exited with errors.", file=sys.stderr)
        return result.returncode

    # 8. Persist state
    config.save(scheme_name, mode)

    print(f"Applied '{scheme_name}' ({mode}) to: {', '.join(app_ids)}")
    return 0


# ── CLI ───────────────────────────────────────────────────────────────────────

def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="Colorizer",
        description="Apply colour schemes to desktop applications.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  Colorizer --list-colorschemas
  Colorizer --list-apps
  Colorizer Dracula dark --all-apps
  Colorizer Dracula dark kitty
  Colorizer Nord light gtk,fuzzel,niri
  Colorizer "Catppuccin" dark kitty,alacritty,gtk,code
""",
    )

    exclusive = parser.add_mutually_exclusive_group()
    exclusive.add_argument(
        "--list-colorschemas",
        action="store_true",
        help="List all available colour schemes",
    )
    exclusive.add_argument(
        "--list-apps",
        action="store_true",
        help="List all supported app IDs",
    )

    parser.add_argument(
        "scheme",
        nargs="?",
        metavar="SCHEME",
        help="Colour scheme name (e.g. Dracula, Nord, Catppuccin)",
    )
    parser.add_argument(
        "mode",
        nargs="?",
        metavar="MODE",
        choices=["dark", "light"],
        help="Colour mode: dark or light",
    )
    parser.add_argument(
        "apps",
        nargs="?",
        metavar="APPS",
        help="Comma-separated list of app IDs to theme (e.g. kitty,gtk,niri)",
    )
    parser.add_argument(
        "--all-apps",
        action="store_true",
        help="Apply the colour scheme to all supported app IDs",
    )

    return parser


def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()

    # ── --list-colorschemas ───────────────────────────────────────────────────
    if args.list_colorschemas:
        schemes = list_colorschemas()
        if not schemes:
            print("No colour schemes found.", file=sys.stderr)
            return 1
        for name, _ in schemes:
            print(name)
        return 0

    # ── --list-apps ───────────────────────────────────────────────────────────
    if args.list_apps:
        for entry in registry.list_all():
            category = entry.get("category", "")
            print(f"{entry['id']:<20} {entry['name']:<18} [{category}]")
        return 0

    # ── apply ─────────────────────────────────────────────────────────────────
    if args.scheme is None or args.mode is None or args.apps is None:
        missing: list[str] = []
        if args.scheme is None:
            missing.append("SCHEME")
        if args.mode is None:
            missing.append("MODE (dark|light)")
        if args.apps is None and not args.all_apps:
            missing.append("APPS (comma-separated app IDs) or --all-apps")
        if missing:
            parser.error(
                f"Missing required argument(s): {', '.join(missing)}\n"
                "Run --list-colorschemas and --list-apps to see valid values."
            )

    if args.all_apps and args.apps is not None:
        parser.error(
            "APPS cannot be provided together with --all-apps.\n"
            "Use either a comma-separated APPS list or --all-apps."
        )

    if args.all_apps:
        app_ids = [entry["id"] for entry in registry.list_all()]
    else:
        app_ids = [a.strip() for a in args.apps.split(",") if a.strip()]
        if not app_ids:
            parser.error("APPS must contain at least one app ID.")

    return apply_scheme(args.scheme, args.mode, app_ids)


if __name__ == "__main__":
    sys.exit(main())
