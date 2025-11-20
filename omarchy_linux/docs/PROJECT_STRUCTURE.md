# Project Structure

This document describes the organization of the ROG Flow Z13 Linux repository.

## Directory Layout

```
omarchy_linux/
├── README.md                    # Quick start guide
├── INSTALL.md                   # Comprehensive installation guide
├── fresh-install.sh             # Automated fresh install script
│
├── scripts/
│   ├── setup/                   # Installation scripts
│   │   ├── 01-install-asusctl.sh
│   │   ├── 02-fix-keyboard.sh
│   │   ├── 03-fix-touchpad.sh
│   │   └── 04-install-gui.sh
│   ├── diagnostics/             # Diagnostic and testing scripts
│   │   ├── diagnose-boot.sh
│   │   └── test-input.sh
│   └── uninstall/               # Uninstallation scripts
│       ├── revert-keyboard-fix.sh
│       └── uninstall-touchpad-fix.sh
│
├── config/
│   ├── systemd/                 # systemd service files
│   │   └── hid-asus-reload.service
│   └── udev/                    # udev rules
│       └── 99-rog-flow-z13-input.rules
│
├── docs/
│   ├── troubleshooting/         # Troubleshooting guides
│   │   ├── boot-errors.md
│   │   └── input-devices.md
│   └── hardware/                # Hardware documentation (future)
│       └── (planned)
│
├── asusctrlGUI/                 # AsusCtrl GUI application
│   ├── asusctrl_gui.py
│   └── README.md
│
└── macOSVM/                     # macOS VM documentation
    └── (various files)
```

## Script Organization

### Setup Scripts (`scripts/setup/`)

Numbered scripts that should be run in order during fresh installation:

1. **01-install-asusctl.sh** - Installs asusctl for hardware control
2. **02-fix-keyboard.sh** - Fixes keyboard input issues with keyd
3. **03-fix-touchpad.sh** - Fixes touchpad scrolling with systemd service
4. **04-install-gui.sh** - Installs AsusCtrl GUI (optional)

### Diagnostic Scripts (`scripts/diagnostics/`)

Scripts for testing and diagnosing issues:

- **test-input.sh** - Tests keyboard and touchpad functionality
- **diagnose-boot.sh** - Diagnoses boot errors (beseed32, UEFI issues)

### Uninstall Scripts (`scripts/uninstall/`)

Scripts to revert changes made by setup scripts:

- **revert-keyboard-fix.sh** - Removes keyd and udev rules
- **uninstall-touchpad-fix.sh** - Removes touchpad systemd service

## Configuration Files (`config/`)

### systemd/

Contains systemd service files:

- **hid-asus-reload.service** - Reloads hid_asus module on boot for touchpad

### udev/

Contains udev rules:

- **99-rog-flow-z13-input.rules** - Forces correct keyboard device classification

## Documentation (`docs/`)

### troubleshooting/

Problem-specific guides:

- **boot-errors.md** - BIOS/UEFI boot issues (beseed32 error)
- **input-devices.md** - Keyboard/touchpad issues and fixes

### hardware/

Hardware specifications and quirks (planned):

- To be populated with detailed hardware documentation

## Usage Patterns

### Fresh Installation

```bash
cd omarchy_linux
sudo ./fresh-install.sh
```

### Manual Step-by-Step

```bash
cd omarchy_linux
sudo ./scripts/setup/01-install-asusctl.sh
sudo ./scripts/setup/02-fix-keyboard.sh
sudo ./scripts/setup/03-fix-touchpad.sh
sudo ./scripts/setup/04-install-gui.sh  # optional
```

### Diagnostics

```bash
sudo ./scripts/diagnostics/test-input.sh
sudo ./scripts/diagnostics/diagnose-boot.sh
```

### Reverting Changes

```bash
sudo ./scripts/uninstall/revert-keyboard-fix.sh
sudo ./scripts/uninstall/uninstall-touchpad-fix.sh
```

## Design Principles

1. **Separation of Concerns**: Setup, diagnostics, and uninstall are clearly separated
2. **Numbered Scripts**: Setup scripts are numbered to indicate execution order
3. **Self-Contained**: Each script can run independently (except dependencies)
4. **Path-Agnostic**: Scripts use relative paths from their location
5. **Idempotent**: Scripts can be run multiple times safely
6. **Documented**: Each script has clear comments explaining purpose

## Migration from Old Structure

If you're updating from the old structure:

- `scripts/fix-keyboard-input.sh` → `scripts/setup/02-fix-keyboard.sh`
- `scripts/install-touchpad-fix.sh` → `scripts/setup/03-fix-touchpad.sh`
- `scripts/diagnose-boot-error.sh` → `scripts/diagnostics/diagnose-boot.sh`
- `scripts/test-input-devices.sh` → `scripts/diagnostics/test-input.sh`
- `systemd/` → `config/systemd/`
- `udev/` → `config/udev/`
- `docs/beseed32-boot-error.md` → `docs/troubleshooting/boot-errors.md`
- `docs/keyboard-trackpad-fix.md` → `docs/troubleshooting/input-devices.md`

## Contributing

When adding new functionality:

1. **Setup scripts**: Add to `scripts/setup/` with appropriate numbering
2. **Diagnostic tools**: Add to `scripts/diagnostics/`
3. **Configuration**: Add to `config/systemd/` or `config/udev/`
4. **Documentation**: Add to `docs/troubleshooting/` or `docs/hardware/`
5. **Update** this document and INSTALL.md accordingly
