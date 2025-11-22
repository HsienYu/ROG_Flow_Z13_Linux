#!/bin/bash

# Installation script for ASUS HID resume fix
# Fixes keyboard, touchscreen, and keyboard backlight after suspend

set -e

echo "Installing ASUS HID resume fix..."

# Create the reset script
cat > /tmp/asus-hid-reset.sh << 'EOF'
#!/bin/bash

# Wait for system to fully resume
sleep 2

# Find ASUS keyboard device (0b05:1a30)
DEVICE_PATH=""
for device in /sys/bus/usb/devices/*; do
    if [ -f "$device/idVendor" ] && [ -f "$device/idProduct" ]; then
        vendor=$(cat "$device/idVendor")
        product=$(cat "$device/idProduct")
        if [ "$vendor" = "0b05" ] && [ "$product" = "1a30" ]; then
            DEVICE_PATH=$(basename "$device")
            break
        fi
    fi
done

if [ -n "$DEVICE_PATH" ]; then
    echo "Resetting ASUS HID device: $DEVICE_PATH"
    
    # Unbind the device
    echo "$DEVICE_PATH" > /sys/bus/usb/drivers/usb/unbind 2>/dev/null
    
    # Wait a moment
    sleep 1
    
    # Rebind the device
    echo "$DEVICE_PATH" > /sys/bus/usb/drivers/usb/bind 2>/dev/null
    
    echo "ASUS HID device reset complete"
else
    echo "ASUS HID device not found"
fi

# Also reload hid_multitouch module as backup
modprobe -r hid_multitouch 2>/dev/null
sleep 0.5
modprobe hid_multitouch 2>/dev/null

# Trigger udev refresh for keyboard backlight
udevadm trigger --subsystem-match=leds 2>/dev/null
udevadm settle 2>/dev/null
EOF

# Create the systemd service
cat > /tmp/asus-hid-resume.service << 'EOF'
[Unit]
Description=Reset ASUS HID devices after resume from suspend
After=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/asus-hid-reset.sh

[Install]
WantedBy=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
EOF

# Install the script
echo "Installing reset script to /usr/local/bin/..."
sudo cp /tmp/asus-hid-reset.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/asus-hid-reset.sh

# Install the systemd service
echo "Installing systemd service..."
sudo cp /tmp/asus-hid-resume.service /etc/systemd/system/

# Enable the service
echo "Enabling service..."
sudo systemctl daemon-reload
sudo systemctl enable asus-hid-resume.service

# Clean up temp files
rm /tmp/asus-hid-reset.sh /tmp/asus-hid-resume.service

echo ""
echo "✓ Installation complete!"
echo ""
echo "The service will automatically fix keyboard, touchscreen, and keyboard backlight"
echo "after waking from suspend."
echo ""
echo "To manually run the fix: sudo /usr/local/bin/asus-hid-reset.sh"
echo "To check service status: systemctl status asus-hid-resume.service"
echo "To uninstall: sudo systemctl disable --now asus-hid-resume.service && sudo rm /usr/local/bin/asus-hid-reset.sh /etc/systemd/system/asus-hid-resume.service"
