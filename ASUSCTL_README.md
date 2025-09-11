# ASUSCTL for ROG Flow Z13 - Complete Guide

## Overview

ASUSCTL is a comprehensive Linux control utility for ASUS ROG laptops, providing both command-line and GUI interfaces for managing your ROG Flow Z13's hardware features. This implementation includes the complete source code, installation scripts, and optimization guides specific to the ROG Flow Z13 (2025).

## Features

### ✅ Supported ROG Flow Z13 Features
- **Power Profile Management**: Performance/Balanced/Quiet modes with TDP control
- **Keyboard Backlight Control**: Off/Low/Med/High brightness levels
- **Battery Charge Control**: Set charging limits (20-100%) for battery longevity
- **Fan Curve Management**: Custom fan profiles for optimal cooling
- **GUI Integration**: ROG Control Center with system tray support
- **GNOME Integration**: Compatible with GNOME desktop environment

### 🎯 ROG Flow Z13 Specific Optimizations
- **Performance Mode**: ~120W TDP for gaming, rendering, ML training
- **Balanced Mode**: ~70W TDP for general computing with good battery life
- **Quiet Mode**: ~45W TDP for maximum battery life and minimal fan noise
- **Hardware Detection**: Automatic detection of Z13-specific components
- **Thermal Management**: Intelligent fan curve adjustments

## Installation

### Quick Installation
```bash
# Navigate to the repository directory
cd ~/GitRepos/ROG_Flow_Z13_Linux

# Run the installation script
./Install_ASUSCTL.sh
```

### Manual Installation
If you prefer to install manually or need to troubleshoot:

1. **Install Dependencies**:
   ```bash
   sudo apt update
   sudo apt install -y git build-essential curl libclang-dev libudev-dev libgtk-3-dev \
       libglib2.0-dev libpango1.0-dev libgdk-pixbuf-2.0-dev libatk1.0-dev \
       libcairo-gobject2 libgtk-3-0 libglib2.0-0 gnome-shell-extension-manager \
       power-profiles-daemon
   ```

2. **Install Rust** (if not already installed):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
   source $HOME/.cargo/env
   rustup default stable
   ```

3. **Build ASUSCTL**:
   ```bash
   cd asusctl
   cargo build --release
   ```

4. **Install Binaries**:
   ```bash
   sudo cp target/release/{asusctl,asusd,asusd-user,rog-control-center} /usr/bin/
   sudo chmod +x /usr/bin/{asusctl,asusd,asusd-user,rog-control-center}
   ```

5. **Configure Services**:
   ```bash
   sudo cp data/asusd.service /etc/systemd/system/
   sudo cp data/asusd-user.service /etc/systemd/user/
   sudo cp data/asusd.conf /usr/share/dbus-1/system.d/
   sudo cp data/asusd.rules /etc/udev/rules.d/99-asusd.rules
   sudo systemctl daemon-reload
   sudo systemctl start asusd
   systemctl --user enable asusd-user
   systemctl --user start asusd-user
   ```

## Usage Guide

### Command Line Interface

#### Power Profile Management
```bash
# Check current profile
asusctl profile -p

# List available profiles
asusctl profile -l

# Set specific profile
sudo asusctl profile -P Performance  # Maximum performance
sudo asusctl profile -P Balanced     # Balanced performance/battery
sudo asusctl profile -P Quiet        # Maximum battery life

# Toggle to next profile
sudo asusctl profile -n
```

#### Keyboard Backlight Control
```bash
# Check current brightness
asusctl -k

# Set brightness levels
sudo asusctl -k off   # Turn off backlight
sudo asusctl -k low   # Low brightness
sudo asusctl -k med   # Medium brightness
sudo asusctl -k high  # High brightness

# Toggle brightness
sudo asusctl -n       # Next brightness level
sudo asusctl -p       # Previous brightness level
```

#### Battery Management
```bash
# Set charge limit (recommended: 80-85% for longevity)
sudo asusctl -c 80    # Limit charging to 80%
sudo asusctl -c 100   # Allow full charge

# One-shot charge to 100% (bypasses limit once)
sudo asusctl -o
```

#### System Information
```bash
# Show all supported features
asusctl -s

# Show version information
asusctl --version

# Get help for any command
asusctl --help
asusctl profile --help
```

### Graphical User Interface

#### ROG Control Center
- **Launch**: Search for "ROG Control Center" in your applications menu
- **Command**: Run `rog-control-center` in terminal
- **Features**: 
  - Profile switching with visual indicators
  - Keyboard backlight slider
  - Battery charge limit controls
  - Real-time system monitoring
  - Fan curve editor

#### GNOME Extension Integration
1. Open "Extension Manager" application
2. Search for ASUS or ROG-related extensions
3. Install extensions for:
   - System tray integration
   - Quick profile switching
   - Battery status with charge limits
   - Performance indicators

## ROG Flow Z13 Optimization Guide

### Performance Profiles Explained

#### Performance Mode (~120W TDP)
- **Best for**: Gaming, 3D rendering, ML model training, intensive computing
- **Battery life**: 1-2 hours under load
- **Fan noise**: Moderate to high
- **Use cases**: 
  - PyTorch/TensorFlow training
  - Blender rendering
  - Gaming at high settings
  - Video encoding

#### Balanced Mode (~70W TDP)
- **Best for**: General development, web browsing, office work
- **Battery life**: 4-6 hours
- **Fan noise**: Low to moderate
- **Use cases**:
  - Code development
  - Web development
  - Light photo editing
  - General productivity

#### Quiet Mode (~45W TDP)
- **Best for**: Reading, writing, light tasks, presentations
- **Battery life**: 8-10 hours
- **Fan noise**: Minimal
- **Use cases**:
  - Document editing
  - Web browsing
  - Email and communication
  - Presentations

### Battery Longevity Best Practices

1. **Set Charge Limit to 80-85%**:
   ```bash
   sudo asusctl -c 80
   ```
   This significantly extends battery lifespan by reducing stress on lithium cells.

2. **Use One-Shot Charge When Needed**:
   ```bash
   sudo asusctl -o
   ```
   Temporarily charges to 100% for long trips without changing the permanent limit.

3. **Profile-Based Power Management**:
   - Use Quiet mode when on battery
   - Switch to Performance mode only when plugged in
   - Use Balanced mode for general battery use

### ML Development Integration

#### Automatic Profile Switching
Create a script for your ML training workflow:

```bash
#!/bin/bash
# ml_training_start.sh

echo "Starting ML training session..."
sudo asusctl profile -P Performance
echo "Switched to Performance mode for optimal training"

# Your training command here
python train_model.py

echo "Training completed, switching to Balanced mode"
sudo asusctl profile -P Balanced
```

#### Integration with Popular Frameworks

**PyTorch Example**:
```python
import subprocess
import os

def set_performance_mode():
    """Set laptop to performance mode for training"""
    try:
        subprocess.run(['sudo', 'asusctl', 'profile', '-P', 'Performance'], check=True)
        print("✓ Switched to Performance mode")
    except subprocess.CalledProcessError:
        print("⚠ Failed to switch profile - continuing anyway")

def set_balanced_mode():
    """Return to balanced mode after training"""
    try:
        subprocess.run(['sudo', 'asusctl', 'profile', '-P', 'Balanced'], check=True)
        print("✓ Switched to Balanced mode")
    except subprocess.CalledProcessError:
        print("⚠ Failed to switch profile")

# Use in your training script
if __name__ == "__main__":
    set_performance_mode()
    # Your training code here
    train_model()
    set_balanced_mode()
```

## Troubleshooting

### Common Issues and Solutions

#### ASUSCTL Command Not Found
```bash
# Check if binaries are installed
ls -la /usr/bin/asusctl

# If missing, reinstall
cd ~/GitRepos/ROG_Flow_Z13_Linux
./Install_ASUSCTL.sh
```

#### Service Not Running
```bash
# Check service status
sudo systemctl status asusd
systemctl --user status asusd-user

# Restart services
sudo systemctl restart asusd
systemctl --user restart asusd-user

# Check logs for errors
journalctl -u asusd -f
```

#### Profile Changes Not Working
```bash
# Check if power-profiles-daemon conflicts with TLP
sudo systemctl status power-profiles-daemon
sudo systemctl status tlp

# If TLP is running, stop it (conflicts with power-profiles-daemon)
sudo systemctl stop tlp
sudo systemctl disable tlp
```

#### GUI Application Not Appearing
```bash
# Update desktop database
sudo update-desktop-database

# Check if desktop file exists
ls -la /usr/share/applications/rog-control-center.desktop

# Try launching from terminal
rog-control-center
```

#### Permission Issues
```bash
# Check D-Bus permissions
sudo systemctl restart dbus

# Check user groups
groups $USER

# If needed, add user to relevant groups
sudo usermod -a -G input,plugdev $USER
# Logout and login again
```

### Hardware-Specific Issues

#### Z13 Not Detected
```bash
# Check DMI information
sudo dmidecode -s system-product-name
sudo dmidecode -s baseboard-product-name

# Should show: ROG Flow Z13 (or similar)
# If not detected, check BIOS settings for ASUS mode
```

#### Fan Curves Not Working
```bash
# Check if fan curve support is detected
asusctl -s | grep -i fan

# Some Z13 variants may have limited fan curve support
# Use profile switching as alternative
```

#### Keyboard Backlight Issues
```bash
# Check keyboard backlight support
asusctl -s | grep -i keyboard

# Test manual control
sudo asusctl -k low
sudo asusctl -k high

# If not working, check BIOS settings for keyboard LED
```

## Advanced Configuration

### Custom Systemd Services

Create automatic profile switching based on AC power:

```bash
# Create AC adapter monitor service
sudo tee /etc/systemd/system/asusctl-ac-monitor.service << EOF
[Unit]
Description=ASUSCTL AC Adapter Monitor
After=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/asusctl-ac-monitor.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
```

```bash
# Create monitoring script
sudo tee /usr/local/bin/asusctl-ac-monitor.sh << 'EOF'
#!/bin/bash
while true; do
    if cat /sys/class/power_supply/ADP*/online 2>/dev/null | grep -q 1; then
        # AC plugged in - Performance mode
        /usr/bin/asusctl profile -P Performance
    else
        # On battery - Quiet mode
        /usr/bin/asusctl profile -P Quiet
    fi
    sleep 30
done
EOF

sudo chmod +x /usr/local/bin/asusctl-ac-monitor.sh
sudo systemctl enable asusctl-ac-monitor.service
sudo systemctl start asusctl-ac-monitor.service
```

### GNOME Extension Development

For advanced users, you can create custom GNOME extensions:

```javascript
// Basic structure for ROG Flow Z13 GNOME extension
const { St, GObject } = imports.gi;
const Main = imports.ui.main;
const PanelMenu = imports.ui.panelMenu;
const PopupMenu = imports.ui.popupMenu;
const GLib = imports.gi.GLib;

var Extension = class Extension {
    enable() {
        this._indicator = new ProfileIndicator();
        Main.panel.addToStatusArea('rog-flow-indicator', this._indicator);
    }

    disable() {
        this._indicator.destroy();
        this._indicator = null;
    }
};

var ProfileIndicator = GObject.registerClass(
class ProfileIndicator extends PanelMenu.Button {
    _init() {
        super._init(0.0, 'ROG Flow Z13 Controls');
        
        // Add profile switching menu items
        this._addProfileMenuItems();
    }

    _addProfileMenuItems() {
        let performanceItem = new PopupMenu.PopupMenuItem('Performance Mode');
        performanceItem.connect('activate', () => {
            this._setProfile('Performance');
        });
        this.menu.addMenuItem(performanceItem);

        let balancedItem = new PopupMenu.PopupMenuItem('Balanced Mode');
        balancedItem.connect('activate', () => {
            this._setProfile('Balanced');
        });
        this.menu.addMenuItem(balancedItem);

        let quietItem = new PopupMenu.PopupMenuItem('Quiet Mode');
        quietItem.connect('activate', () => {
            this._setProfile('Quiet');
        });
        this.menu.addMenuItem(quietItem);
    }

    _setProfile(profile) {
        GLib.spawn_command_line_async(`pkexec asusctl profile -P ${profile}`);
    }
});
```

## Contributing

### Source Code Structure
```
asusctl/
├── asusctl/           # CLI tool source
├── asusd/             # System daemon
├── asusd-user/        # User service
├── rog-control-center/# GUI application
├── rog-aura/          # LED/lighting control
├── rog-anime/         # AniMe Matrix support
├── rog-platform/      # Hardware platform interface
├── rog-profiles/      # Performance profiles
└── data/              # Configuration files
```

### Development Setup
```bash
# Clone with submodules
git clone --recursive https://gitlab.com/asus-linux/asusctl.git

# Install development dependencies
sudo apt install -y rust-analyzer cargo-watch

# Run tests
cargo test

# Development build with logging
RUST_LOG=debug cargo run --bin asusd
```

### Submitting Issues

When reporting issues, include:
1. ROG Flow Z13 variant (GZ302EA, etc.)
2. Ubuntu version (`lsb_release -a`)
3. ASUSCTL version (`asusctl --version`)
4. Service status (`sudo systemctl status asusd`)
5. Hardware detection output (`asusctl -s`)

## Resources

- **Official ASUSCTL Project**: https://gitlab.com/asus-linux/asusctl
- **ASUS Linux Community**: https://asus-linux.org/
- **ROG Flow Z13 Support**: https://discord.gg/asus-linux
- **Documentation**: https://asus-linux.org/asusctl/
- **Bug Reports**: https://gitlab.com/asus-linux/asusctl/-/issues

## License

This project is licensed under the Mozilla Public License v2.0. See the `LICENSE` file in the asusctl directory for details.

---

*This documentation is specifically tailored for the ASUS ROG Flow Z13 (2025) running Ubuntu Linux. For other ASUS laptops or distributions, some features and instructions may vary.*
