#!/bin/bash
set -e

echo "Reverting display wake fix..."

# Disable and remove the service
sudo systemctl disable fix-display-wake.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/fix-display-wake.service
sudo systemctl daemon-reload

# Find the most recent backup
BACKUP_FILE=$(ls -t /etc/default/grub.backup.* 2>/dev/null | head -1)

if [ -n "$BACKUP_FILE" ]; then
    echo "Restoring GRUB config from $BACKUP_FILE"
    sudo cp "$BACKUP_FILE" /etc/default/grub
    sudo update-grub
    echo "GRUB restored successfully"
else
    echo "No backup found. Manually removing amdgpu.dc=0 parameter..."
    sudo sed -i 's/ amdgpu\.dc=0//g' /etc/default/grub
    sudo update-grub
fi

echo ""
echo "Revert complete! Please reboot."
