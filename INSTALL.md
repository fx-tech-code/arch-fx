# Install fx Arch

Run the installer from the repository root:

```bash
cd ~/arch-fx
./install/00_install_arch_fx.sh
```

Resume from a specific step by passing the two-digit step number:

```bash
cd ~/arch-fx
./install/00_install_arch_fx.sh 05
```

## Behavior

- `15_install_optional_packages.sh` and `16_install_steam.sh` are optional and are selected interactively.
- `14_post_install.sh` always runs at the end of a successful run.
- Any script failure stops the installer immediately and reports which step failed.
- Runs that include the dotfiles step must be started from the repo root.
- The installer uses `gum` when available. Before step `09`, it falls back to plain shell prompts.

## Step Scripts

| Step | Script | Purpose |
| --- | --- | --- |
| 00 | `install/00_install_arch_fx.sh` | Main installer orchestration |
| 01 | `install/01_install_git_ssh.sh` | Install `git` and `openssh` |
| 02 | `install/02_install_yay.sh` | Build and install `yay` |
| 03 | `install/03_install_automount.sh` | Install `udiskie` |
| 04 | `install/04_install_base_packages.sh` | Install base packages |
| 05 | `install/05_install_btrfs_snapshots.sh` | Install snapshot tooling and sync limine |
| 06 | `install/06_install_login_manager.sh` | Install and enable `ly@tty1` |
| 07 | `install/07_install_terminal_shell.sh` | Install `kitty` and `fish` |
| 08 | `install/08_install_niri.sh` | Install `niri` and `xdg-desktop-portal-gtk` |
| 09 | `install/09_install_tool_packages.sh` | Install desktop and tooling packages |
| 10 | `install/10_install_gtk_themes.sh` | Install GTK theme defaults |
| 11 | `install/11_install_browsers.sh` | Install Firefox, Zen, and `noto-fonts` |
| 12 | `install/12_install_file_explorers.sh` | Install `yazi` and `nautilus` |
| 13 | `install/13_install_dotfiles.sh` | Apply `script-dots` and `config-dots` with `deepstow` |
| 14 | `install/14_post_install.sh` | Set `fish` as the login shell and add `~/.local/bin` to `PATH` |
| 15 | `install/15_install_optional_packages.sh` | Install optional desktop applications |
| 16 | `install/16_install_steam.sh` | Enable multilib if needed and install Steam |

## Notes

- `udiskie --automount` is started from the Niri autostart config.
- If GTK theme settings cannot be written through `gsettings`, finish that step with `nwg-look`.
- The Steam step backs up `/etc/pacman.conf` to `/etc/pacman.conf.arch-fx.bak` before enabling multilib.
- GPU drivers are still expected to be installed separately before using Steam.