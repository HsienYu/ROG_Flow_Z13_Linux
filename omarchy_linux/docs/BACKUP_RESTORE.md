# Backup & Restore ROG Z13 Configs

This guide explains how to backup and restore your ROG Z13-specific Hyprland configurations.

## Why Backup?

When you reinstall your system, you'll lose your custom configurations. This script backs up **only** the ROG Z13-specific configs (not omarchy-managed configs) to this repository, so you can restore them after a fresh install.

## What Gets Backed Up?

The script backs up these ROG Z13-specific files:

- **`hyprland-rog-z13.conf`** - ROG-specific keybindings for:
  - Brightness control (F7/F8)
  - Volume control (F1/F2/F3)
  - Performance profiles (Quiet/Balanced/Performance)
  - Keyboard backlight control
  - Battery charge limits
  - GPU mode switching
  - Screen rotation (tablet mode)
  - Media keys
  
- **`input.conf`** - Input device settings:
  - Keyboard repeat rate
  - Touchpad configuration
  - Natural scrolling
  - Tap-to-click settings
  
- **`trackpad-fix.conf`** - ASUS keyboard trackpad configuration

- **`scripts/`** - Custom Hyprland scripts (e.g., toggle-touchpad.sh)

## Before Reinstalling

### Backup Your Configs

```bash
cd ~/GitRepos/ROG_Flow_Z13_Linux/omarchy_linux
./scripts/setup/05-backup-restore-configs.sh backup
```

This copies your configs to `config/hyprland/` in the repo.

### Commit to Git

```bash
git add config/hyprland/
git commit -m "Backup Hyprland configs before reinstall"
git push
```

Now your configs are safely stored in the repository!

## After Fresh Install

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/ROG_Flow_Z13_Linux.git
cd ROG_Flow_Z13_Linux/omarchy_linux
```

### 2. Run Fresh Install

```bash
sudo ./fresh-install.sh
```

### 3. Restore Your Configs

```bash
./scripts/setup/05-backup-restore-configs.sh restore
```

### 4. Update Your Main Hyprland Config

Make sure your `~/.config/hypr/hyprland.conf` includes these lines:

```conf
# Source ROG Z13 specific configs
source = ~/.config/hypr/hyprland-rog-z13.conf
source = ~/.config/hypr/input.conf
```

### 5. Reload Hyprland

```bash
hyprctl reload
```

## What About Omarchy Configs?

Omarchy manages most of your Hyprland configuration through its theme system. These configs are stored in `~/.config/omarchy/` and include:

- Main `hyprland.conf`
- `waybar` config and styles
- `hyprlock.conf`
- Terminal themes (alacritty, kitty, ghostty)
- And much more

**You don't need to backup omarchy configs** because:
1. They're part of the omarchy theme system
2. They get restored when you switch themes
3. The custom ROG Z13 configs are sourced separately

## Manual Backup (Alternative)

If you want to manually backup additional configs:

```bash
# Create a backup directory
mkdir -p ~/config-backup

# Copy specific configs
cp -r ~/.config/hypr ~/config-backup/
cp -r ~/.config/waybar ~/config-backup/
cp ~/.zshrc ~/config-backup/

# Create archive
cd ~
tar -czf config-backup-$(date +%Y%m%d).tar.gz config-backup/
```

## Troubleshooting

### Restore says "Backup directory not found"

Run the backup command first:
```bash
./scripts/setup/05-backup-restore-configs.sh backup
```

### Configs restored but keybindings don't work

Check that your main hyprland.conf sources the ROG configs:
```bash
grep "hyprland-rog-z13" ~/.config/hypr/hyprland.conf
```

If not found, add:
```bash
echo "source = ~/.config/hypr/hyprland-rog-z13.conf" >> ~/.config/hypr/hyprland.conf
```

### Want to backup other dotfiles?

For full dotfiles management, consider using:
- [GNU Stow](https://www.gnu.org/software/stow/)
- [chezmoi](https://www.chezmoi.io/)
- [yadm](https://yadm.io/)

But for a quick ROG Z13 reinstall, this script is sufficient!
