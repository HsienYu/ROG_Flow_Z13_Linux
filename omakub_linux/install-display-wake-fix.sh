#!/bin/bash
set -e

echo "Installing display wake fix for ROG Flow Z13..."

# Copy service file
sudo cp fix-display-wake.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable the service
sudo systemctl enable fix-display-wake.service

# Add kernel parameters to help with GPU resume
GRUB_FILE="/etc/default/grub"
BACKUP_FILE="/etc/default/grub.backup.$(date +%s)"

echo "Backing up GRUB config to $BACKUP_FILE"
sudo cp "$GRUB_FILE" "$BACKUP_FILE"

# Add amdgpu.dc=0 to disable Display Core (can help with wake issues)
if ! grep -q "amdgpu.dc=0" "$GRUB_FILE"; then
    echo "Adding amdgpu kernel parameters..."
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 amdgpu.dc=0"/' "$GRUB_FILE"
    sudo update-grub
    echo "GRUB updated. Reboot required for kernel parameters to take effect."
else
    echo "AMD GPU parameters already present in GRUB."
fi

echo ""
echo "Installation complete!"
echo ""
echo "Additional manual options to try if issue persists:"
echo "1. Edit /etc/default/grub and add: amdgpu.dcdebugmask=0x10"
echo "2. Or try: amdgpu.ppfeaturemask=0xffffffff"
echo "3. After editing, run: sudo update-grub"
echo ""
echo "Then reboot and test suspend/resume."
