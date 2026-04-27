# Install fx Arch

## Install git and ssh

```bash
sudo pacman -S git openssh
```

## Install yay

```bash
mkdir /tmp/yay
cd /tmp/yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
cd ~
```

## Install and configure automount

```bash
sudo pacman -S udiskie
```

`udiskie --automount` is started in Niri autostart.

## Install Base Packages

```bash
sudo pacman -S less nano fzf btop fastfetch accountsservice
```

## Install Btrfs Snapshots

```bash
sudo pacman -S btrfs-progs snap-pac btrfs-assistant
yay -S limine-mkinitcpio-hook limine-snapper-sync
sudo mv /boot/limine/limine.conf /boot/limine/limine.conf.backup
sudo limine-update
sudo limine-snapper-sync
```

## Install Login-Manager

```bash
sudo pacman -S ly
sudo systemctl enable ly@tty1
```

## Install Terminals and Shell

```bash
sudo pacman -S kitty foot fish
```

## Install Niri

```bash
sudo pacman -S niri xdg-desktop-portal-gnome
```

If prompted, choose `xdg-desktop-portal-gnome`.

## Install Tool Packages

```bash
yay -S systemd-manager-tui-bin visual-studio-code-bin
sudo pacman -S waybar awww mako caligula hypridle hyprlock hyprpicker hyprshot impala bluetui wiremix fuzzel nwg-look polkit-gnome gum ffmpegthumbnailer zenity
```

## Install GTK Themes

```bash
sudo pacman -S adw-gtk-theme
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

Or use `nwg-look`.

## Install Browsers

```bash
sudo pacman -S firefox noto-fonts
yay -S zen-browser-bin
```

If prompted for Firefox, choose `noto-fonts (2)`.

## Install File Explorers

```bash
sudo pacman -S yazi nautilus
```

## Bring in dotfiles

Using stow to manage dotfiles

```bash
sudo pacman -S stow
```

```bash
cd ~/arch-fx/script-dots
../deepstow *
```

```bash
cd ~/arch-fx/config-dots
../deepstow *
```

## Post Install

```bash
chsh -s /bin/fish
sudo echo 'export PATH="$HOME/.local/bin:$PATH"' > /etc/profile.d/local-bin.sh
```

## Install optional Packages

```bash
sudo pacman -S gnome-calculator gnome-text-editor loupe libreoffice-still showtime thunderbird
```

## Install Steam

Ensure multilib is enabled for pacman in `/etc/pacman.conf`.

```bash
sudo pacman -S xorg-xwayland xwayland-satellite steam
```

Ensure GPU drivers are installed.
