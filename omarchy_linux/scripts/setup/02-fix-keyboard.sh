#!/usr/bin/env bash
#
# ROG Flow Z13 Keyboard/Trackpad Auto-Fix Script
# Fixes the detachable keyboard not working on Linux (Arch-based)
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    echo "Usage: sudo $0"
    exit 1
fi

# Check if on Arch Linux
if ! command -v pacman &> /dev/null; then
    log_error "This script is designed for Arch Linux (pacman required)"
    exit 1
fi

log_info "ROG Flow Z13 Keyboard/Trackpad Fix Script"
echo "=========================================="
echo

# Step 1: Install keyd
log_info "Step 1: Installing keyd..."
if pacman -Q keyd &> /dev/null; then
    log_info "keyd is already installed"
else
    pacman -Sy --noconfirm --needed keyd
    log_info "keyd installed successfully"
fi
echo

# Step 2: Configure keyd
log_info "Step 2: Configuring keyd..."
mkdir -p /etc/keyd
cat > /etc/keyd/default.conf <<'KEYD_EOF'
[ids]
*

[main]
# No remaps by default - this just creates a reliable virtual keyboard
# Customize this file if you want to remap keys
KEYD_EOF
log_info "keyd configuration created at /etc/keyd/default.conf"
echo

# Step 3: Enable and start keyd
log_info "Step 3: Enabling keyd service..."
systemctl enable keyd
systemctl start keyd
if systemctl is-active --quiet keyd; then
    log_info "keyd service is running"
else
    log_warn "keyd service failed to start - check: sudo journalctl -u keyd"
fi
echo

# Step 4: Create udev rule
log_info "Step 4: Creating udev rule..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UDEV_RULE="/etc/udev/rules.d/99-rog-flow-z13-input.rules"
cp "$SCRIPT_DIR/config/udev/99-rog-flow-z13-input.rules" "$UDEV_RULE"
log_info "udev rule installed at $UDEV_RULE"
echo

# Step 5: Reload udev rules
log_info "Step 5: Reloading udev rules..."
udevadm control --reload
udevadm trigger -s input
log_info "udev rules reloaded"
echo

# Step 6: Ensure hid_asus is loaded
log_info "Step 6: Checking hid_asus driver..."
if lsmod | grep -q hid_asus; then
    log_info "hid_asus driver is loaded"
else
    log_warn "hid_asus driver not loaded - attempting to load..."
    modprobe hid_asus || log_warn "Could not load hid_asus (this may be OK)"
fi
echo

# Step 7: Verify setup
log_info "Step 7: Verifying setup..."
echo

if libinput list-devices 2>/dev/null | grep -q "keyd virtual keyboard"; then
    log_info "✓ keyd virtual keyboard detected"
else
    log_warn "✗ keyd virtual keyboard NOT detected"
fi

if [[ -f "$UDEV_RULE" ]]; then
    log_info "✓ udev rule installed"
else
    log_warn "✗ udev rule NOT found"
fi

if systemctl is-active --quiet keyd; then
    log_info "✓ keyd service is running"
else
    log_warn "✗ keyd service is NOT running"
fi

echo
echo "=========================================="
log_info "Fix applied successfully!"
echo
echo "Next steps:"
echo "1. Restart your display manager:"
echo "   sudo systemctl restart sddm    # for SDDM"
echo "   sudo systemctl restart gdm     # for GDM"
echo "   sudo systemctl restart lightdm # for LightDM"
echo
echo "2. Or simply reboot your system"
echo
echo "3. After restart, your keyboard should work!"
echo
echo "If issues persist, see: docs/keyboard-trackpad-fix.md"
echo "To revert changes, run: sudo ./scripts/revert-keyboard-fix.sh"
