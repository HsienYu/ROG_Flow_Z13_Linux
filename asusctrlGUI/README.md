# AsusCtrl GUI

A graphical control interface for asusctl on ROG laptops.

## Features

- **Performance Profiles**: Switch between Quiet, Balanced, and Performance modes
- **Keyboard Brightness**: Control keyboard backlight brightness levels
- **Battery Management**: Set charge limits and enable one-shot full charge
- **Aura Lighting**: Control keyboard RGB lighting modes and colors

## Dependencies

Install the required dependencies on Arch Linux:

```bash
sudo pacman -S python gtk4 libadwaita python-gobject
```

## Installation

Make the script executable:

```bash
chmod +x asusctrl_gui.py
```

## Usage

Run the GUI:

```bash
./asusctrl_gui.py
```

Or with Python:

```bash
python asusctrl_gui.py
```

## Features Overview

### Performance Profile
Switch between three performance modes:
- **Quiet**: Lower power consumption, quieter fans
- **Balanced**: Balance between performance and efficiency
- **Performance**: Maximum performance

### Keyboard Brightness
Control keyboard backlight with four levels (Off, Low, Med, High) or use Previous/Next buttons to cycle through levels.

### Battery Management
- Set charge limit (20-100%) to preserve battery health
- Enable one-shot 100% charge for times when you need full capacity

### Keyboard Lighting (Aura)
- Cycle through different lighting modes
- Set custom static colors with the color picker

## Desktop Integration

To add a desktop launcher, create `~/.local/share/applications/asusctrl-gui.desktop`:

```desktop
[Desktop Entry]
Name=AsusCtrl GUI
Comment=Control panel for ASUS ROG laptops
Exec=/home/chenghsienyu/GitRepos/ROG_Flow_Z13_Linux/asusctrlGUI/asusctrl_gui.py
Icon=preferences-system
Terminal=false
Type=Application
Categories=System;Settings;
```

## Permissions

Some asusctl commands may require root privileges. If you encounter permission errors, you may need to configure sudo or polkit rules.

## License

MIT
