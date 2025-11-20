#!/bin/bash

set -e

echo "[INFO] Installing ROG Flow Z13 Touchpad Fix"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "[ERROR] Please run as root or with sudo"
    exit 1
fi

# Copy systemd service
echo "[INFO] Installing systemd service..."
cp -v "$(dirname "$0")/../systemd/hid-asus-reload.service" /etc/systemd/system/

# Reload systemd
echo "[INFO] Reloading systemd..."
systemctl daemon-reload

# Enable service
echo "[INFO] Enabling service..."
systemctl enable hid-asus-reload.service

# Start service (test it)
echo "[INFO] Starting service..."
systemctl start hid-asus-reload.service

echo ""
echo "========================================"
echo "[SUCCESS] Touchpad fix installed!"
echo ""
echo "The hid_asus module will be automatically reloaded on every boot."
echo "Your touchpad two-finger scrolling should work after each restart."
echo ""
echo "To check status: sudo systemctl status hid-asus-reload"
echo "To uninstall: sudo ./scripts/uninstall-touchpad-fix.sh"
