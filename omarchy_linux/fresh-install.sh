#!/usr/bin/env bash
#
# ROG Flow Z13 Fresh Install Script for Arch Linux
# Complete automated setup for hardware fixes and optimizations
#
# Usage: sudo ./fresh-install.sh
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_header() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo
    echo -e "${CYAN}━━━ $1 ━━━${NC}"
    echo
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

clear
log_header "ROG Flow Z13 Fresh Install Setup"
echo
log_info "This script will configure your ROG Flow Z13 for optimal Linux performance"
echo
echo "What will be installed:"
echo "  ✓ asusctl (ASUS laptop control daemon)"
echo "  ✓ Keyboard input fix (keyd + udev rules)"
echo "  ✓ Touchpad scrolling fix (systemd service)"
echo "  ✓ AsusCtrl GUI (optional)"
echo
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Installation cancelled"
    exit 0
fi

# Create log file
LOG_FILE="/tmp/rog-flow-z13-install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

log_info "Installation log will be saved to: $LOG_FILE"
echo

# Step 1: Update system
log_step "Step 1/5: Updating system packages"
pacman -Syu --noconfirm
log_info "System updated"

# Step 2: Install asusctl
log_step "Step 2/5: Installing asusctl"
if "$SCRIPT_DIR/scripts/setup/01-install-asusctl.sh"; then
    log_info "asusctl installed successfully"
else
    log_warn "asusctl installation had issues, continuing..."
fi

# Step 3: Fix keyboard input
log_step "Step 3/5: Fixing keyboard input"
if "$SCRIPT_DIR/scripts/setup/02-fix-keyboard.sh"; then
    log_info "Keyboard fix applied successfully"
else
    log_error "Keyboard fix failed"
    exit 1
fi

# Step 4: Fix touchpad scrolling
log_step "Step 4/5: Fixing touchpad scrolling"
if "$SCRIPT_DIR/scripts/setup/03-fix-touchpad.sh"; then
    log_info "Touchpad fix applied successfully"
else
    log_warn "Touchpad fix had issues, continuing..."
fi

# Step 5: Optional GUI installation
log_step "Step 5/5: AsusCtrl GUI (optional)"
echo
read -p "Install AsusCtrl GUI? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if "$SCRIPT_DIR/scripts/setup/04-install-gui.sh"; then
        log_info "AsusCtrl GUI installed successfully"
    else
        log_warn "AsusCtrl GUI installation had issues"
    fi
else
    log_info "Skipping GUI installation"
fi

# Post-install diagnostics
echo
log_step "Running Post-Install Diagnostics"
"$SCRIPT_DIR/scripts/diagnostics/test-input.sh" || log_warn "Some diagnostics failed"

# Summary
echo
log_header "Installation Complete!"
echo
log_info "Your ROG Flow Z13 is now configured for Linux"
echo
echo "Next steps:"
echo "  1. Restart your display manager OR reboot:"
echo "     sudo systemctl restart sddm  # or gdm/lightdm"
echo "     # OR"
echo "     sudo reboot"
echo
echo "  2. After restart, test your keyboard and touchpad"
echo
echo "Troubleshooting:"
echo "  - Keyboard issues: see docs/troubleshooting/input-devices.md"
echo "  - Boot errors: see docs/troubleshooting/boot-errors.md"
echo "  - Run diagnostics: sudo $SCRIPT_DIR/scripts/diagnostics/test-input.sh"
echo
echo "To revert changes:"
echo "  - Keyboard fix: sudo $SCRIPT_DIR/scripts/uninstall/revert-keyboard-fix.sh"
echo "  - Touchpad fix: sudo $SCRIPT_DIR/scripts/uninstall/uninstall-touchpad-fix.sh"
echo
log_info "Full installation log: $LOG_FILE"
echo
