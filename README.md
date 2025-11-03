# ROG Flow Z13 (GZ302) Linux Setup & Fixes

Comprehensive documentation and automated fixes for running Linux on the ASUS ROG Flow Z13 (2022-2023 models, GZ302 series).

## Quick Fix: Keyboard/Trackpad Not Working

If your detachable keyboard isn't typing (but trackpad works), run:

```bash
sudo ./scripts/fix-keyboard-input.sh
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

## Documentation

- **[Keyboard/Trackpad Fix Guide](docs/keyboard-trackpad-fix.md)** - Detailed troubleshooting and fix
- **[Installation Guide](docs/installation.md)** - General Linux installation tips
- **[Hardware Quirks](docs/hardware-quirks.md)** - Known hardware issues and workarounds

## Scripts

- `scripts/fix-keyboard-input.sh` - Automated keyboard/trackpad fix
- `scripts/revert-keyboard-fix.sh` - Revert keyboard fix changes
- `scripts/test-input-devices.sh` - Test and diagnose input devices

## System Requirements

- Arch Linux (scripts are Arch-specific, but docs apply to other distros)
- Hyprland, GNOME, KDE Plasma, or other Wayland/X11 desktop
- Kernel 6.1+

## Contributing

Issues and pull requests welcome! Please test on your ROG Flow Z13 and report results.

## License

MIT
