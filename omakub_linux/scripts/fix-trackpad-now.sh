#!/bin/bash
# Fix ROG Flow Z13 trackpad when it gets stuck after Fn key toggle
# This reloads the hid_asus module to restore full trackpad functionality

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    # Try to run with sudo if not root
    if command -v pkexec &> /dev/null; then
        pkexec "$0" "$@"
        exit $?
    elif command -v sudo &> /dev/null; then
        sudo "$0" "$@"
        exit $?
    else
        notify-send "Trackpad Fix" "Error: Need root permissions" -u critical
        exit 1
    fi
fi

# Reload hid_asus module
modprobe -r hid_asus
sleep 0.5
modprobe hid_asus

# Notify user
if [ -n "$SUDO_USER" ] && command -v notify-send &> /dev/null; then
    REAL_USER="$SUDO_USER"
    USER_ID=$(id -u "$REAL_USER")
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"
    sudo -u "$REAL_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" notify-send "Trackpad Fixed" "hid_asus module reloaded" -u normal 2>/dev/null || true
fi

exit 0
