# ROG Flow Z13 Fresh Install Guide

Complete guide for setting up Linux on your ROG Flow Z13 (GZ302 series) from scratch.

## Prerequisites

- ASUS ROG Flow Z13 (GZ302EA/GZ302EZ)
- Arch Linux (or Arch-based distro) installed
- Internet connection
- Root/sudo access

## Quick Install (Recommended)

For a fresh system, run the automated installer:

```bash
cd ~/GitRepos/ROG_Flow_Z13_Linux/omarchy_linux
sudo ./fresh-install.sh
```

This will:
1. Update system packages
2. Install asusctl for hardware control
3. Fix keyboard input issues
4. Fix touchpad scrolling
5. Optionally install AsusCtrl GUI
6. Run post-install diagnostics

After installation, **reboot or restart your display manager**.

## Manual Installation

If you prefer step-by-step control:

### Step 1: Install asusctl

```bash
sudo ./scripts/setup/01-install-asusctl.sh
```

**What it does:**
- Installs `asusctl` from official repos or AUR
- Enables and starts `asusd` service
- Provides control over:
  - Performance profiles (Quiet/Balanced/Performance)
  - Keyboard backlight
  - Battery charge limits
  - Aura RGB lighting

**Verify:**
```bash
systemctl status asusd
asusctl -h
```

### Step 2: Fix Keyboard Input

```bash
sudo ./scripts/setup/02-fix-keyboard.sh
```

**What it does:**
- Installs `keyd` virtual keyboard daemon
- Creates udev rules to fix device classification
- Ensures keyboard works with Wayland/X11 compositors

**Problem it solves:**
The detachable keyboard doesn't produce input in Wayland due to ASUS HID driver probe failures (error -12) and libinput misclassification.

**Verify:**
```bash
systemctl status keyd
sudo libinput list-devices | grep "keyd virtual keyboard"
```

### Step 3: Fix Touchpad Scrolling

```bash
sudo ./scripts/setup/03-fix-touchpad.sh
```

**What it does:**
- Installs systemd service to reload `hid_asus` module on boot
- Ensures two-finger scrolling works every time

**Problem it solves:**
Touchpad interface gets bound to `hid-generic` instead of `hid_asus` during boot, breaking multi-touch gestures.

**Verify:**
```bash
systemctl status hid-asus-reload
sudo libinput list-devices | grep -A10 "Touchpad"
```

### Step 4: Install GUI (Optional)

```bash
sudo ./scripts/setup/04-install-gui.sh
```

**What it does:**
- Installs Python GTK4 dependencies
- Creates desktop launcher for AsusCtrl GUI
- Provides graphical interface for asusctl features

**Launch GUI:**
```bash
./asusctrlGUI/asusctrl_gui.py
# Or from application menu: "AsusCtrl GUI"
```

### Step 5: Restore Hyprland Configs (Optional)

If you backed up your ROG Z13 Hyprland configs before:

```bash
./scripts/setup/05-backup-restore-configs.sh restore
```

**What it restores:**
- `hyprland-rog-z13.conf` - ROG-specific keybindings
- `input.conf` - Input device settings
- `trackpad-fix.conf` - Trackpad configuration
- `scripts/` - Custom Hyprland scripts

**To backup before reinstall:**
```bash
./scripts/setup/05-backup-restore-configs.sh backup
```

### Step 6: Restart

```bash
# Restart display manager
sudo systemctl restart sddm  # or gdm/lightdm

# OR reboot
sudo reboot
```

## Post-Install Verification

Run diagnostics to ensure everything works:

```bash
sudo ./scripts/diagnostics/test-input.sh
```

**Test checklist:**
- [ ] Keyboard types correctly
- [ ] Two-finger scrolling works
- [ ] Keyboard backlight control works
- [ ] Performance profiles switch (asusctl profile -p Quiet/Balanced/Performance)
- [ ] Function keys work (brightness, volume, etc.)

## BIOS Settings (Recommended)

Before installing Linux, configure BIOS:

1. **Enter BIOS**: Press F2/DEL during boot
2. **Disable Secure Boot**: Security → Secure Boot → Disabled
3. **Set Boot Mode**: Boot → Boot Mode → UEFI
4. **Fast Boot**: Disabled (optional, helps with boot issues)
5. **Save and Exit**: F10

## Bootloader Recommendations

### Using Limine (Recommended)

Limine is lightweight and reliable for UEFI systems.

**Install:**
```bash
sudo pacman -S limine
sudo limine-deploy /dev/nvme0n1  # Your boot drive
```

**Configure:** See [Limine documentation](https://github.com/limine-bootloader/limine)

### Using GRUB

Standard option, widely supported.

**Install:**
```bash
sudo pacman -S grub efibootmgr
sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Troubleshooting

### Keyboard Not Working

1. **Check keyd status:**
   ```bash
   systemctl status keyd
   sudo journalctl -u keyd -n 50
   ```

2. **Verify udev rule:**
   ```bash
   cat /etc/udev/rules.d/99-rog-flow-z13-input.rules
   sudo udevadm trigger -s input
   ```

3. **Re-run fix:**
   ```bash
   sudo ./scripts/setup/02-fix-keyboard.sh
   ```

4. **See detailed guide:** `docs/troubleshooting/input-devices.md`

### Touchpad Scrolling Not Working

1. **Manual test:**
   ```bash
   sudo modprobe -r hid_asus && sudo modprobe hid_asus
   ```
   If this fixes it, the systemd service should handle it automatically.

2. **Check service:**
   ```bash
   systemctl status hid-asus-reload
   sudo journalctl -u hid-asus-reload
   ```

3. **Re-install:**
   ```bash
   sudo ./scripts/setup/03-fix-touchpad.sh
   ```

### Boot Errors (beseed32)

See `docs/troubleshooting/boot-errors.md` for comprehensive solutions.

**Quick fixes:**
1. Reset BIOS to defaults
2. Clear Embedded Controller (hold power button 60s with AC unplugged)
3. Disable Secure Boot
4. Update BIOS firmware

### Performance Issues

**GPU Switching:**
If you have the dGPU model (RTX 3050):
```bash
# Check GPU status
asusctl graphics
supergfxctl -g  # if installed

# Switch modes
supergfxctl -m Integrated  # Power saving
supergfxctl -m Hybrid      # Automatic switching
```

**Performance Profiles:**
```bash
# Check current profile
asusctl profile -l

# Switch profiles
asusctl profile -p Quiet       # Quiet fans, lower power
asusctl profile -p Balanced    # Default
asusctl profile -p Performance # Max performance
```

## Reverting Changes

### Remove Keyboard Fix

```bash
sudo ./scripts/uninstall/revert-keyboard-fix.sh
```

### Remove Touchpad Fix

```bash
sudo ./scripts/uninstall/uninstall-touchpad-fix.sh
```

## Additional Resources

- **Troubleshooting Guides:** `docs/troubleshooting/`
- **Hardware Info:** `docs/hardware/`
- **Arch Wiki:** [ASUS Laptops](https://wiki.archlinux.org/title/ASUS_laptops)
- **asusctl GitHub:** [asusctl](https://gitlab.com/asus-linux/asusctl)

## System Requirements

- Kernel 6.1+ (tested on 6.6+)
- systemd (for service management)
- libinput (for input device handling)
- Wayland or X11 compositor

## Known Working Configurations

- **Hyprland** (Wayland) - Fully working
- **GNOME** (Wayland) - Fully working
- **KDE Plasma** (Wayland/X11) - Fully working
- **Sway** (Wayland) - Fully working
- **i3** (X11) - Fully working

## Support

If you encounter issues not covered in the documentation:

1. Run diagnostics: `sudo ./scripts/diagnostics/test-input.sh`
2. Check system logs: `sudo journalctl -xe`
3. Check boot logs: `sudo ./scripts/diagnostics/diagnose-boot.sh`
4. Open an issue on GitHub with diagnostic logs

## License

MIT
