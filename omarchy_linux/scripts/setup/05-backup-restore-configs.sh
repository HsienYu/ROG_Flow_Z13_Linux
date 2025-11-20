#!/usr/bin/env bash
#
# Backup and Restore ROG Z13-specific Hyprland Configurations
# Usage: 
#   ./05-backup-restore-configs.sh backup
#   ./05-backup-restore-configs.sh restore
#

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
BACKUP_DIR="$SCRIPT_DIR/config/hyprland"
CONFIG_DIR="${HOME}/.config/hypr"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo "Usage: $0 {backup|restore}"
    echo
    echo "Commands:"
    echo "  backup   - Backup ROG Z13 Hyprland configs to repo"
    echo "  restore  - Restore ROG Z13 Hyprland configs from repo"
    exit 1
}

backup_configs() {
    log_info "Backing up ROG Z13 Hyprland configurations..."
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Files to backup (ROG-specific only)
    FILES=(
        "hyprland-rog-z13.conf"
        "trackpad-fix.conf"
        "input.conf"
    )
    
    for file in "${FILES[@]}"; do
        if [[ -f "$CONFIG_DIR/$file" ]]; then
            cp -v "$CONFIG_DIR/$file" "$BACKUP_DIR/"
            log_info "Backed up: $file"
        else
            log_warn "File not found: $CONFIG_DIR/$file"
        fi
    done
    
    # Check if scripts directory exists
    if [[ -d "$CONFIG_DIR/scripts" ]]; then
        log_info "Backing up Hyprland scripts..."
        mkdir -p "$BACKUP_DIR/scripts"
        cp -rv "$CONFIG_DIR/scripts/"* "$BACKUP_DIR/scripts/" 2>/dev/null || true
    fi
    
    log_info "Backup complete! Files saved to: $BACKUP_DIR"
    echo
    echo "Remember to commit these changes to git:"
    echo "  cd $SCRIPT_DIR"
    echo "  git add config/hyprland/"
    echo "  git commit -m 'Update ROG Z13 Hyprland configs'"
}

restore_configs() {
    log_info "Restoring ROG Z13 Hyprland configurations..."
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_error "Backup directory not found: $BACKUP_DIR"
        log_error "Run 'backup' command first!"
        exit 1
    fi
    
    # Create config directory if it doesn't exist
    mkdir -p "$CONFIG_DIR"
    
    # Restore files
    FILES=(
        "hyprland-rog-z13.conf"
        "trackpad-fix.conf"
        "input.conf"
    )
    
    for file in "${FILES[@]}"; do
        if [[ -f "$BACKUP_DIR/$file" ]]; then
            cp -v "$BACKUP_DIR/$file" "$CONFIG_DIR/"
            log_info "Restored: $file"
        else
            log_warn "Backup file not found: $BACKUP_DIR/$file"
        fi
    done
    
    # Restore scripts if they exist
    if [[ -d "$BACKUP_DIR/scripts" ]]; then
        log_info "Restoring Hyprland scripts..."
        mkdir -p "$CONFIG_DIR/scripts"
        cp -rv "$BACKUP_DIR/scripts/"* "$CONFIG_DIR/scripts/" 2>/dev/null || true
        chmod +x "$CONFIG_DIR/scripts/"*.sh 2>/dev/null || true
    fi
    
    log_info "Restore complete!"
    echo
    echo "Next steps:"
    echo "  1. Make sure these are sourced in your main hyprland.conf:"
    echo "     source = ~/.config/hypr/hyprland-rog-z13.conf"
    echo "     source = ~/.config/hypr/input.conf"
    echo
    echo "  2. Reload Hyprland:"
    echo "     hyprctl reload"
}

# Main
case "${1:-}" in
    backup)
        backup_configs
        ;;
    restore)
        restore_configs
        ;;
    *)
        show_usage
        ;;
esac
