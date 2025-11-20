#!/usr/bin/env bash
#
# Install AsusCtrl GUI for ROG Flow Z13
# Provides graphical interface for asusctl features
#

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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
    exit 1
fi

log_info "Installing AsusCtrl GUI dependencies..."

# Install required packages
pacman -S --noconfirm --needed python gtk4 libadwaita python-gobject

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
GUI_SCRIPT="$SCRIPT_DIR/asusctrlGUI/asusctrl_gui.py"

if [[ ! -f "$GUI_SCRIPT" ]]; then
    log_error "GUI script not found at $GUI_SCRIPT"
    exit 1
fi

# Make executable
chmod +x "$GUI_SCRIPT"

# Create desktop entry
log_info "Creating desktop entry..."
DESKTOP_FILE="/usr/share/applications/asusctrl-gui.desktop"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=AsusCtrl GUI
Comment=Control panel for ASUS ROG laptops
Exec=$GUI_SCRIPT
Icon=preferences-system
Terminal=false
Type=Application
Categories=System;Settings;
EOF

log_info "AsusCtrl GUI installed successfully"
log_info "Launch from application menu or run: $GUI_SCRIPT"

exit 0
