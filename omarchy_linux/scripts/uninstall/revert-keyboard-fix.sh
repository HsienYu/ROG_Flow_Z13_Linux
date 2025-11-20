#!/usr/bin/env bash
#
# ROG Flow Z13 Keyboard Fix Revert Script
# Removes all changes made by fix-keyboard-input.sh
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root"
    echo "Usage: sudo $0"
    exit 1
fi

log_info "ROG Flow Z13 Keyboard Fix Revert Script"
echo "========================================"
echo

# Stop and disable keyd
log_info "Stopping keyd service..."
if systemctl is-active --quiet keyd; then
    systemctl stop keyd
    log_info "keyd service stopped"
fi

if systemctl is-enabled --quiet keyd 2>/dev/null; then
    systemctl disable keyd
    log_info "keyd service disabled"
fi
echo

# Remove udev rule
log_info "Removing udev rule..."
UDEV_RULE="/etc/udev/rules.d/99-rog-flow-z13-input.rules"
if [[ -f "$UDEV_RULE" ]]; then
    rm "$UDEV_RULE"
    log_info "udev rule removed"
else
    log_warn "udev rule not found (already removed?)"
fi
echo

# Reload udev
log_info "Reloading udev rules..."
udevadm control --reload
udevadm trigger -s input
log_info "udev rules reloaded"
echo

# Ask about removing keyd package
echo "========================================"
echo "Do you want to uninstall keyd package? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    log_info "Uninstalling keyd..."
    pacman -R --noconfirm keyd || log_warn "Could not uninstall keyd"
else
    log_info "Keeping keyd installed (disabled)"
fi
echo

echo "========================================"
log_info "Revert complete!"
echo
echo "Restart your display manager to apply changes:"
echo "  sudo systemctl restart sddm    # for SDDM"
echo "  sudo systemctl restart gdm     # for GDM"
echo
echo "Or simply reboot your system."
