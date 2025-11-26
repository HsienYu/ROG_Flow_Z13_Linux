# ROG Flow Z13 (GZ302) Linux Setup & Fixes

Comprehensive documentation and automated fixes for running Linux on the ASUS ROG Flow Z13 (2025 models, GZ302 series).

## 🚀 Fresh Install (Recommended)

For a new Arch Linux installation, run the automated setup:

```bash
cd omarchy_linux
sudo ./fresh-install.sh
```

This installs everything needed: asusctl, keyboard/touchpad fixes, and optional GUI.

**See [INSTALL.md](omarchy_linux/INSTALL.md) for detailed installation guide.**

## Quick Fix: Keyboard/Touchpad Not Working

> **💎 Omarchy users (as of Nov 26, 2025):** The latest Omarchy Arch Linux update has fixed the keyboard issue! Test your keyboard first—you may not need to run the fix below.

If your detachable keyboard isn't typing (but trackpad works), run:

```bash
cd omarchy_linux
sudo ./scripts/setup/02-fix-keyboard.sh
sudo systemctl restart sddm  # or your display manager
```

## Issues Addressed

### 1. Keyboard Not Working (Trackpad Works)
**Symptoms:**
- Detachable keyboard doesn't type
- Trackpad works fine
- `evtest` shows key events but Wayland/X11 doesn't receive them

**Root Cause:**
- ASUS `hid_asus` driver probe fails with error -12 (ENOMEM)
- libinput misclassifies keyboard devices as touchpads/mice
- Hyprland/Wayland compositor doesn't grab the input device

**Solution:**
- Use `keyd` virtual keyboard daemon to forward input events
- Add udev rules to force correct device classification
- Keep `hid_asus` driver loaded (don't blacklist)

**Note:** Fixed out-of-the-box in Omarchy as of Nov 26, 2025.

## Documentation

### Installation
- **[INSTALL.md](omarchy_linux/INSTALL.md)** - Complete fresh install guide
- **[fresh-install.sh](omarchy_linux/fresh-install.sh)** - Automated setup script

### Troubleshooting
- **[Input Devices](omarchy_linux/docs/troubleshooting/input-devices.md)** - Keyboard/trackpad troubleshooting
- **[Boot Errors](omarchy_linux/docs/troubleshooting/boot-errors.md)** - BIOS/UEFI issues (beseed32)

## Scripts

### Setup
- `scripts/setup/01-install-asusctl.sh` - Install ASUS control daemon
- `scripts/setup/02-fix-keyboard.sh` - Fix keyboard input (usually not needed on Omarchy as of Nov 2025)
- `scripts/setup/03-fix-touchpad.sh` - Fix touchpad scrolling
- `scripts/setup/04-install-gui.sh` - Install AsusCtrl GUI

### Diagnostics
- `scripts/diagnostics/test-input.sh` - Test keyboard/trackpad
- `scripts/diagnostics/diagnose-boot.sh` - Diagnose boot issues

### Uninstall
- `scripts/uninstall/revert-keyboard-fix.sh` - Remove keyboard fix
- `scripts/uninstall/uninstall-touchpad-fix.sh` - Remove touchpad fix

## System Requirements

- Arch Linux (scripts are Arch-specific, but docs apply to other distros)
- Test on Omarchy linux
- Kernel 6.1+

## Contributing

Issues and pull requests welcome! Please test on your ROG Flow Z13 and report results.

## License

MIT
