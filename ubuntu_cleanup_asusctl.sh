#!/bin/bash

# Ubuntu asusctl Cleanup Script
# This script removes asusctl completely and restores Ubuntu default settings
# Use this to fix brightness control issues and other conflicts

set -e

echo "🔧 Ubuntu asusctl Cleanup Script"
echo "================================="
echo ""
echo "This script will:"
echo "- Remove all asusctl components"
echo "- Restore Ubuntu default GRUB settings" 
echo "- Clean up configuration files"
echo "- Reset system to Ubuntu defaults"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "📋 Creating backup before cleanup..."

# Create backup directory
BACKUP_DIR="$HOME/asusctl_cleanup_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup GRUB configuration
if [ -f /etc/default/grub ]; then
    sudo cp /etc/default/grub "$BACKUP_DIR/grub.backup"
    echo "✅ GRUB configuration backed up to $BACKUP_DIR/grub.backup"
fi

# Backup existing asusctl configs if they exist
if [ -d /etc/asusd ]; then
    sudo cp -r /etc/asusd "$BACKUP_DIR/asusd_config_backup"
    echo "✅ asusctl configuration backed up to $BACKUP_DIR/asusd_config_backup"
fi

# List current ASUS-related services
systemctl list-units | grep -i asus > "$BACKUP_DIR/services_before_cleanup.txt" 2>/dev/null || true
lsmod | grep -E "(asus|wmi)" > "$BACKUP_DIR/modules_before_cleanup.txt" 2>/dev/null || true

echo ""
echo "🛑 Stopping asusctl services..."

# Stop and disable asusd service
sudo systemctl stop asusd.service 2>/dev/null || true
sudo systemctl disable asusd.service 2>/dev/null || true
echo "✅ asusd service stopped"

# Stop user services if they exist
systemctl --user stop asusd-user.service 2>/dev/null || true
systemctl --user disable asusd-user.service 2>/dev/null || true
echo "✅ asusd user service stopped"

echo ""
echo "🗑️  Removing asusctl files..."

# Remove binaries
sudo rm -f /usr/bin/asusctl
sudo rm -f /usr/bin/asusd
sudo rm -f /usr/bin/asusd-user
echo "✅ asusctl binaries removed"

# Remove systemd service files
sudo rm -f /etc/systemd/system/asusd.service
sudo rm -f /etc/systemd/user/asusd-user.service
sudo rm -f /usr/lib/systemd/system/asusd.service
sudo rm -f /usr/lib/systemd/user/asusd-user.service
echo "✅ systemd service files removed"

# Remove configuration directories
sudo rm -rf /etc/asusd
sudo rm -f /etc/sudoers.d/asusctl
echo "✅ Configuration files removed"

# Remove udev rules
sudo rm -f /etc/udev/rules.d/99-asusd.rules
sudo rm -f /usr/lib/udev/rules.d/99-asusd.rules
echo "✅ udev rules removed"

# Remove desktop files and icons
sudo rm -f /usr/share/applications/*asusctl*
sudo rm -f /usr/share/applications/*asusd*
sudo rm -rf /usr/share/asusd
sudo rm -f /usr/share/icons/*/apps/*asus*
echo "✅ Desktop files and icons removed"

# Remove user configuration
rm -rf ~/.config/rog-control-center 2>/dev/null || true
rm -rf ~/.config/asusctl 2>/dev/null || true
echo "✅ User configuration cleaned"

echo ""
echo "⚙️  Restoring Ubuntu defaults..."

# Reset GRUB to Ubuntu defaults
echo "Restoring GRUB configuration..."
sudo cp /etc/default/grub "$BACKUP_DIR/grub_before_restore.backup"
sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"' /etc/default/grub
sudo update-grub
echo "✅ GRUB restored to Ubuntu defaults"

# Remove any custom module blacklists
sudo find /etc/modprobe.d -name "*amdgpu*" -delete 2>/dev/null || true
sudo find /etc/modprobe.d -name "*asus*" -delete 2>/dev/null || true
echo "✅ Module blacklists cleaned"

echo ""
echo "🔄 Reloading system configuration..."

# Reload systemd daemon
sudo systemctl daemon-reload
echo "✅ systemd daemon reloaded"

# Reload udev rules  
sudo udevadm control --reload-rules
echo "✅ udev rules reloaded"

# Update initramfs
sudo update-initramfs -u
echo "✅ initramfs updated"

echo ""
echo "📊 Cleanup Summary:"
echo "=================="
echo "✅ asusctl completely removed"
echo "✅ Ubuntu default settings restored"
echo "✅ System configuration reloaded" 
echo "✅ Backup created in: $BACKUP_DIR"
echo ""
echo "🔄 REBOOT REQUIRED"
echo "=================="
echo "Please reboot your system to complete the cleanup:"
echo "sudo reboot"
echo ""
echo "After reboot, your F7/F8 brightness keys should work with Ubuntu's native support."
echo ""

# Offer to reboot now
read -p "Reboot now? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting in 5 seconds..."
    sleep 5
    sudo reboot
else
    echo "Remember to reboot manually to complete the cleanup!"
fi
