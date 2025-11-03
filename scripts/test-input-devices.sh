#!/usr/bin/env bash
#
# ROG Flow Z13 Input Device Testing Script
# Diagnoses keyboard/trackpad issues
#

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_section() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

log_check() {
    local status="$1"
    local message="$2"
    if [[ "$status" == "OK" ]]; then
        echo -e "${GREEN}✓${NC} $message"
    elif [[ "$status" == "WARN" ]]; then
        echo -e "${YELLOW}⚠${NC} $message"
    else
        echo -e "${RED}✗${NC} $message"
    fi
}

# Check 1: Kernel driver status
log_section "1. Kernel Driver Status"
if lsmod | grep -q hid_asus; then
    log_check "OK" "hid_asus driver is loaded"
else
    log_check "FAIL" "hid_asus driver NOT loaded"
fi

if dmesg | grep -q "asus.*failed with error -12"; then
    log_check "WARN" "hid_asus probe errors detected (error -12)"
    echo "   Run: sudo dmesg | grep asus"
else
    log_check "OK" "No hid_asus probe errors"
fi

# Check 2: Input devices
log_section "2. Input Devices Detected"
echo "Keyboards:"
for dev in /dev/input/by-path/*kbd*; do
    if [[ -e "$dev" ]]; then
        echo "  - $(basename $dev) -> $(readlink $dev)"
    fi
done

if [[ ! -e /dev/input/by-path/*kbd* ]]; then
    log_check "FAIL" "No keyboard devices found"
fi

echo
echo "Touchpads:"
for dev in /dev/input/by-path/*mouse* /dev/input/by-path/*touchpad*; do
    if [[ -e "$dev" ]]; then
        echo "  - $(basename $dev) -> $(readlink $dev)"
    fi
done

# Check 3: libinput device classification
log_section "3. libinput Device Classification"
if command -v libinput &> /dev/null; then
    echo "ASUS Keyboard devices:"
    sudo libinput list-devices 2>/dev/null | grep -A 8 "GZ302EA-Keyboard\|Asus Keyboard" || echo "  None found"
    
    echo
    echo "keyd virtual keyboard:"
    sudo libinput list-devices 2>/dev/null | grep -A 8 "keyd virtual keyboard" || echo "  Not found"
    
    echo
    echo "AT Translated keyboard:"
    sudo libinput list-devices 2>/dev/null | grep -A 8 "AT Translated" || echo "  Not found"
else
    log_check "FAIL" "libinput not installed"
fi

# Check 4: keyd status
log_section "4. keyd Status"
if command -v keyd &> /dev/null; then
    log_check "OK" "keyd is installed"
    
    if systemctl is-active --quiet keyd; then
        log_check "OK" "keyd service is running"
    else
        log_check "FAIL" "keyd service is NOT running"
    fi
    
    if systemctl is-enabled --quiet keyd 2>/dev/null; then
        log_check "OK" "keyd service is enabled"
    else
        log_check "WARN" "keyd service is NOT enabled"
    fi
    
    if [[ -f /etc/keyd/default.conf ]]; then
        log_check "OK" "keyd config exists"
    else
        log_check "FAIL" "keyd config NOT found"
    fi
else
    log_check "FAIL" "keyd is NOT installed"
fi

# Check 5: udev rules
log_section "5. udev Rules"
if [[ -f /etc/udev/rules.d/99-rog-flow-z13-input.rules ]]; then
    log_check "OK" "ROG Flow Z13 udev rule installed"
else
    log_check "FAIL" "ROG Flow Z13 udev rule NOT found"
fi

# Check 6: Event testing
log_section "6. Keyboard Event Test"
echo "Testing keyboard events for 3 seconds..."
echo "Press some keys now!"
echo

KEYBOARD_EVENT=$(find /dev/input/by-path -name '*kbd*' 2>/dev/null | head -1)
if [[ -n "$KEYBOARD_EVENT" ]]; then
    echo "Testing: $KEYBOARD_EVENT"
    sudo timeout 3 evtest "$KEYBOARD_EVENT" 2>&1 | grep -E "type 1 \(EV_KEY\)" | head -5 || echo "No key events detected"
else
    log_check "FAIL" "No keyboard device found to test"
fi

# Summary
log_section "Summary & Recommendations"

if ! lsmod | grep -q hid_asus; then
    echo "• Load hid_asus driver: sudo modprobe hid_asus"
fi

if ! command -v keyd &> /dev/null; then
    echo "• Install keyd: sudo pacman -S keyd"
fi

if ! systemctl is-active --quiet keyd 2>/dev/null; then
    echo "• Start keyd: sudo systemctl start keyd"
fi

if [[ ! -f /etc/udev/rules.d/99-rog-flow-z13-input.rules ]]; then
    echo "• Run the fix script: sudo ./scripts/fix-keyboard-input.sh"
fi

echo
echo "For detailed troubleshooting, see: docs/keyboard-trackpad-fix.md"
