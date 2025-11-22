# ROG Flow Z13 Keyboard RGB Control

Simple GUI application to control the keyboard backlight colors on ROG Flow Z13 GZ302EA.

## Features

- 🎨 RGB sliders for precise color control
- 🖱️ Color picker dialog
- ⚡ 8 quick color presets
- 🔴 Real-time color preview
- ✨ Instant color application

## Installation

Dependencies are already installed in the `.venv` directory.

## Usage

Simply run the launcher script:

```bash
./launch_rgb_control.sh
```

Or run directly:

```bash
sudo DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY .venv/bin/python3 keyboard_rgb_simple.py
```

## Files

- `keyboard_rgb_simple.py` - Main GUI application (recommended)
- `keyboard_rgb_control.py` - Original version with effect modes (not fully working)
- `test_keyboard_hid.py` - Test script for HID communication
- `launch_rgb_control.sh` - Convenient launcher script

## Requirements

- Python 3.10+
- PyQt6
- hidapi
- Root privileges (for HID device access)

## Notes

- The app requires root/sudo to access the HID device
- Only static color mode is fully functional
- Effect modes (breathe, pulse, rainbow) are not working on this hardware
