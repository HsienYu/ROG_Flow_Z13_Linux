# Ubuntu Troubleshooting Guide for asusctl

## ⚠️ Important Notice for Ubuntu Users

**Before installing asusctl on Ubuntu 24.04+**, please read this entire document. Ubuntu's native hardware support for ASUS ROG laptops has significantly improved and may work better than asusctl for many basic functions.

## Common Issues and Solutions

### 🔥 Brightness Control Not Working After asusctl Installation

**Symptoms:**
- F7/F8 brightness keys stop working after installing asusctl
- Brightness keys worked fine in fresh Ubuntu installation
- Screen brightness cannot be controlled via keyboard

**Root Cause:**
asusctl's `asusd` service intercepts ACPI brightness events and conflicts with Ubuntu's native brightness control.

**Solution:**
Complete removal of asusctl and restoration to Ubuntu defaults:

```bash
# 1. Stop and remove asusd service
sudo systemctl stop asusd.service
sudo rm -f /etc/systemd/system/asusd.service
sudo systemctl daemon-reload

# 2. Remove asusctl binaries (if installed from source)
sudo rm -f /usr/bin/asusctl /usr/bin/asusd

# 3. Remove configuration files
sudo rm -rf /etc/asusd
sudo rm -f /etc/sudoers.d/asusctl
sudo rm -f /etc/udev/rules.d/99-asusd.rules

# 4. Reload udev rules
sudo udevadm control --reload-rules

# 5. Restore Ubuntu default GRUB settings
sudo cp /etc/default/grub /etc/default/grub.backup
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub
sudo update-grub

# 6. Remove any AMD GPU blacklists (if created during troubleshooting)
sudo rm -f /etc/modprobe.d/blacklist-amdgpu.conf

# 7. Reboot to apply all changes
sudo reboot
```

### 🔧 Quick Cleanup Script

Use the provided cleanup script in this repository:
```bash
./ubuntu_cleanup_asusctl.sh
```

## When to Use asusctl vs Ubuntu Native Support

### ✅ Use Ubuntu Native Support When:
- **Basic brightness control** (F7/F8 keys) is needed
- **Volume controls** work fine
- **Power management** is satisfactory
- You want **maximum system stability**
- **Battery life optimization** is important
- You prefer **minimal system modifications**

### 🎮 Consider asusctl When:
- You need **per-key RGB lighting** control
- **AniMatrix display** control is required
- **Advanced fan curve** control is needed
- **GPU MUX switching** is essential
- **Custom LED effects** are desired
- **Fine-grained power profiles** are required

## Ubuntu Version Compatibility

### Ubuntu 24.04 LTS (Noble)
- ✅ **Excellent native hardware support**
- ✅ **Brightness controls work out-of-box**
- ✅ **Basic ASUS WMI functions** supported
- ⚠️ **asusctl may cause conflicts**

### Ubuntu 22.04 LTS (Jammy)  
- ✅ **Good native support**
- ⚠️ **Some features may need asusctl**
- ✅ **Generally stable with asusctl**

### Ubuntu 20.04 LTS (Focal)
- ❌ **Limited native support**
- ✅ **asusctl recommended for full functionality**

## Best Practices for Ubuntu Users

### 1. Try Ubuntu Native First
Always test Ubuntu's native hardware support before installing asusctl:
```bash
# Test brightness controls
echo "Test F7/F8 brightness keys"

# Check available backlight controls
ls /sys/class/backlight/

# Test with brightnessctl
brightnessctl -l
```

### 2. Backup System State
Before installing asusctl:
```bash
# Backup GRUB configuration
sudo cp /etc/default/grub /etc/default/grub.before-asusctl

# Note current kernel modules
lsmod | grep -E "(asus|wmi)" > ~/modules_before_asusctl.txt

# Check current services
systemctl list-units | grep -i asus > ~/services_before_asusctl.txt
```

### 3. Minimal Installation
If you decide to use asusctl, install only what you need:
```bash
# Install only the core daemon without GUI
make install-daemon

# Or install with specific features disabled
cargo build --no-default-features --features "daemon"
```

## ROG Flow Z13 Specific Notes

### Hardware Support Status
- ✅ **Brightness control**: Works perfectly with Ubuntu native
- ✅ **Volume controls**: Native support excellent
- ✅ **Power button**: Full Ubuntu integration
- ✅ **Sleep/wake**: Stable with Ubuntu defaults
- ⚠️ **RGB lighting**: Requires asusctl for advanced control
- ⚠️ **AniMatrix**: Not supported natively, needs asusctl

### Recommended Configuration for Z13
For most users, **stick with Ubuntu native support**:
- Excellent stability
- Better power management  
- No service conflicts
- Automatic updates via Ubuntu packages

## Recovery Procedures

### Full System Reset to Ubuntu Defaults
If you encounter issues after installing asusctl:

```bash
# Use the complete cleanup script
./ubuntu_cleanup_asusctl.sh

# Or manually follow these steps:

# 1. Remove all asusctl components
sudo systemctl stop asusd.service 2>/dev/null
sudo systemctl disable asusd.service 2>/dev/null
sudo rm -f /usr/bin/asusctl /usr/bin/asusd
sudo rm -rf /etc/asusd
sudo rm -f /etc/systemd/system/asusd.service
sudo rm -f /etc/sudoers.d/asusctl
sudo rm -f /etc/udev/rules.d/99-asusd.rules

# 2. Reset GRUB to defaults
echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' | sudo tee -a /tmp/grub_default
sudo cp /etc/default/grub /etc/default/grub.backup
sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' /etc/default/grub
sudo update-grub

# 3. Clean up any module blacklists
sudo find /etc/modprobe.d -name "*amdgpu*" -delete
sudo find /etc/modprobe.d -name "*asus*" -delete

# 4. Reload system configuration  
sudo systemctl daemon-reload
sudo udevadm control --reload-rules

# 5. Reboot to clean state
sudo reboot
```

## Performance Comparison

### Ubuntu Native vs asusctl

| Feature | Ubuntu Native | asusctl | Winner |
|---------|---------------|---------|--------|
| **Brightness Control** | ✅ Perfect | ❌ Conflicts | Ubuntu |
| **Battery Life** | ✅ Optimized | ⚠️ Variable | Ubuntu |
| **System Stability** | ✅ Excellent | ⚠️ Good | Ubuntu |
| **Memory Usage** | ✅ Minimal | ⚠️ +1MB RAM | Ubuntu |
| **Boot Time** | ✅ Fast | ⚠️ Slightly slower | Ubuntu |
| **RGB Lighting** | ❌ Limited | ✅ Full control | asusctl |
| **AniMatrix** | ❌ None | ✅ Full control | asusctl |
| **Fan Control** | ⚠️ Basic | ✅ Advanced curves | asusctl |

## Getting Help

### Ubuntu Native Issues
- 🐛 Report to: [Ubuntu Bug Tracker](https://bugs.launchpad.net/ubuntu)
- 💬 Ask on: [Ubuntu Forums](https://ubuntuforums.org/)
- 📖 Check: [Ubuntu Hardware Support](https://help.ubuntu.com/community/HardwareSupport)

### asusctl Issues  
- 🐛 Report to: [asusctl GitHub Issues](https://github.com/flukejones/asusctl/issues)
- 💬 Discord: [ASUS Linux Community](https://discord.gg/B8GftRW2Hd)
- 📖 Documentation: [ASUS Linux Website](https://asus-linux.org/)

---

## Summary

**For ROG Flow Z13 on Ubuntu 24.04**: Ubuntu's native support is excellent for daily use. Only install asusctl if you specifically need RGB lighting or AniMatrix control, and be prepared for potential brightness control conflicts.

**Golden Rule**: If Ubuntu native works for your needs, stick with it. It's more stable, uses less resources, and integrates better with the Ubuntu ecosystem.
