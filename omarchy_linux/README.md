# ROG Flow Z13 - Arch Linux Setup

Complete automated setup and fixes for running Arch Linux on the ASUS ROG Flow Z13 (GZ302 series).

## Quick Start

### Fresh Install (Recommended)

For a new Arch Linux installation:

```bash
sudo ./fresh-install.sh
```

This will:
- ✓ Update system packages
- ✓ Install asusctl for hardware control
- ✓ Fix keyboard input issues
- ✓ Fix touchpad scrolling
- ✓ Optionally install AsusCtrl GUI
- ✓ Run post-install diagnostics

**After installation, reboot or restart your display manager.**

### Manual Installation

See [INSTALL.md](INSTALL.md) for step-by-step instructions.

## What Problems Does This Solve?

### 1. Keyboard Not Working ⌨️
**Problem:** Detachable keyboard doesn't type in Wayland/X11  
**Cause:** ASUS HID driver probe fails, libinput misclassifies device  
**Solution:** `keyd` virtual keyboard + udev rules

### 2. Touchpad Scrolling Broken 🖱️
**Problem:** Two-finger scrolling doesn't work after boot  
**Cause:** Touchpad bound to wrong driver during boot  
**Solution:** systemd service to reload `hid_asus` module

### 3. No Hardware Control ⚙️
**Problem:** Can't control performance, RGB, battery limits  
**Solution:** asusctl daemon for ASUS-specific features

## Directory Structure

```
omarchy_linux/
├── fresh-install.sh         # One-click automated setup
├── INSTALL.md               # Detailed installation guide
├── scripts/
│   ├── setup/              # Installation scripts (run in order)
│   ├── diagnostics/        # Testing and diagnostic tools
│   └── uninstall/          # Scripts to revert changes
├── config/
│   ├── systemd/            # systemd service files
│   └── udev/               # udev rules
├── docs/
│   ├── troubleshooting/    # Problem-specific guides
│   └── PROJECT_STRUCTURE.md
├── asusctrlGUI/            # GUI for asusctl
└── macOSVM/                # macOS VM setup
```

See [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md) for details.

## Troubleshooting

### Keyboard Issues
```bash
sudo ./scripts/diagnostics/test-input.sh
```
See [docs/troubleshooting/input-devices.md](docs/troubleshooting/input-devices.md)

### Boot Errors (beseed32)
```bash
sudo ./scripts/diagnostics/diagnose-boot.sh
```
See [docs/troubleshooting/boot-errors.md](docs/troubleshooting/boot-errors.md)

## Individual Script Usage

### Setup (must run as root)
```bash
sudo ./scripts/setup/01-install-asusctl.sh       # Install asusctl
sudo ./scripts/setup/02-fix-keyboard.sh          # Fix keyboard
sudo ./scripts/setup/03-fix-touchpad.sh          # Fix touchpad
sudo ./scripts/setup/04-install-gui.sh           # Install GUI (optional)
./scripts/setup/05-backup-restore-configs.sh     # Backup/restore Hyprland configs
```

### Diagnostics
```bash
sudo ./scripts/diagnostics/test-input.sh       # Test input devices
sudo ./scripts/diagnostics/diagnose-boot.sh    # Diagnose boot issues
```

### Uninstall
```bash
sudo ./scripts/uninstall/revert-keyboard-fix.sh
sudo ./scripts/uninstall/uninstall-touchpad-fix.sh
```

## Requirements

- ASUS ROG Flow Z13 (GZ302EA/GZ302EZ)
- Arch Linux (or Arch-based distro)
- Kernel 6.1+ (tested on 6.6+)
- Internet connection

## Known Working Configurations

- ✓ Hyprland (Wayland)
- ✓ GNOME (Wayland)
- ✓ KDE Plasma (Wayland/X11)
- ✓ Sway (Wayland)
- ✓ i3 (X11)

## Hardware Features

With asusctl installed, you can control:

- **Performance Profiles** (Quiet/Balanced/Performance)
- **Keyboard Backlight** (brightness control)
- **Battery Charge Limits** (preserve battery health)
- **Aura RGB Lighting** (keyboard colors/effects)
- **Fan Curves** (custom fan speeds)
- **GPU Switching** (Integrated/Hybrid modes, if dGPU model)

## Contributing

Issues and pull requests welcome! Please test on your ROG Flow Z13.

## License

MIT
