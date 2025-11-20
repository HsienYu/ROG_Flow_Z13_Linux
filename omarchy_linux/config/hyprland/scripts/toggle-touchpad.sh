#!/bin/bash

# =============================================================================
# Touchpad Toggle Script for Hyprland
# =============================================================================
# This script toggles the touchpad on/off for ROG Flow Z13
# Place in ~/.config/hypr/scripts/toggle-touchpad.sh and make executable
# =============================================================================

# Get touchpad device ID
TOUCHPAD=$(hyprctl devices -j | jq -r '.mice[] | select(.name | contains("ouchpad") or contains("ASUE")) | .name' | head -n1)

if [ -z "$TOUCHPAD" ]; then
    notify-send "Touchpad" "Touchpad device not found" -i input-touchpad
    exit 1
fi

# Get current touchpad state
CURRENT_STATE=$(hyprctl getoption "device:$TOUCHPAD:enabled" -j | jq -r '.int')

if [ "$CURRENT_STATE" -eq 1 ]; then
    # Disable touchpad
    hyprctl keyword "device:$TOUCHPAD:enabled" false
    notify-send "Touchpad" "Disabled" -i input-touchpad-off
else
    # Enable touchpad
    hyprctl keyword "device:$TOUCHPAD:enabled" true
    notify-send "Touchpad" "Enabled" -i input-touchpad
fi
