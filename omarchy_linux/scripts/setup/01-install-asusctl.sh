#!/usr/bin/env bash
#
# Install asusctl for ROG Flow Z13
# Controls performance profiles, fan curves, keyboard RGB, battery limits, etc.
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

log_info "Installing asusctl and supergfxctl..."

# Install asusctl from official repo
if pacman -Q asusctl &> /dev/null; then
    log_info "asusctl already installed"
else
    # Install from AUR or community repo
    if pacman -Ss asusctl | grep -q "^community/"; then
        pacman -S --noconfirm --needed asusctl
    else
        log_warn "asusctl not found in official repos, checking AUR..."
        # Check if paru or yay is available
        if command -v paru &> /dev/null; then
            sudo -u "$SUDO_USER" paru -S --noconfirm asusctl
        elif command -v yay &> /dev/null; then
            sudo -u "$SUDO_USER" yay -S --noconfirm asusctl
        else
            log_error "No AUR helper found. Install paru or yay first:"
            echo "  sudo pacman -S --needed base-devel git"
            echo "  git clone https://aur.archlinux.org/paru.git"
            echo "  cd paru && makepkg -si"
            exit 1
        fi
    fi
fi

# Install supergfxctl for GPU switching (if available)
if pacman -Q supergfxctl &> /dev/null; then
    log_info "supergfxctl already installed"
else
    log_warn "supergfxctl not found, skipping (optional for hybrid GPU systems)"
fi

# Enable and start services
log_info "Enabling asusctl services..."
systemctl enable --now power-profiles-daemon.service || log_warn "power-profiles-daemon not available"
systemctl enable --now asusd.service

log_info "asusctl installed and configured"
log_info "Use 'asusctl' command to control your laptop"

exit 0
