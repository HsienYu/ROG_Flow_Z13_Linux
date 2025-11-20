#!/bin/bash

set -e

echo "[INFO] Uninstalling ROG Flow Z13 Touchpad Fix"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "[ERROR] Please run as root or with sudo"
    exit 1
fi

# Stop and disable service
echo "[INFO] Stopping and disabling service..."
systemctl stop hid-asus-reload.service || true
systemctl disable hid-asus-reload.service || true

# Remove systemd service
echo "[INFO] Removing systemd service..."
rm -fv /etc/systemd/system/hid-asus-reload.service

# Reload systemd
echo "[INFO] Reloading systemd..."
systemctl daemon-reload

echo ""
echo "=========================================="
echo "[SUCCESS] Touchpad fix uninstalled!"
echo ""
echo "The hid_asus module will no longer be reloaded automatically."
