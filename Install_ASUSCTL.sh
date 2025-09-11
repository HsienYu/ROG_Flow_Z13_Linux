#!/bin/bash

# =============================================================================
# ASUS ROG Flow Z13 - ASUSCTL Installation Script
# =============================================================================
# This script installs asusctl with GUI support for comprehensive laptop control
# Compatible with: ASUS ROG Flow Z13 (2025) - All variants
# Tested on: Ubuntu 24.04 LTS
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_status() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user."
    fi
}

# Check system requirements
check_requirements() {
    print_header "Checking System Requirements"
    
    # Check if running on ASUS laptop
    if ! dmidecode -s system-manufacturer 2>/dev/null | grep -qi "ASUS"; then
        print_warning "This script is designed for ASUS laptops. Continuing anyway..."
    fi
    
    # Check Ubuntu version
    if ! lsb_release -d | grep -qi ubuntu; then
        print_warning "This script is optimized for Ubuntu. Other distributions may work with modifications."
    fi
    
    # Check if we're in the correct directory
    if [[ ! -d "asusctl" ]]; then
        print_error "asusctl source directory not found. Please run this script from the ROG_Flow_Z13_Linux directory."
    fi
    
    print_status "System requirements check completed"
}

# Install dependencies
install_dependencies() {
    print_header "Installing Dependencies"
    
    # Update package list
    sudo apt update
    
    # Install build dependencies
    sudo apt install -y \
        git \
        build-essential \
        curl \
        libclang-dev \
        libudev-dev \
        libgtk-3-dev \
        libglib2.0-dev \
        libpango1.0-dev \
        libgdk-pixbuf-2.0-dev \
        libatk1.0-dev \
        libcairo-gobject2 \
        libgtk-3-0 \
        libglib2.0-0 \
        gnome-shell-extension-manager \
        power-profiles-daemon
    
    print_status "Dependencies installed successfully"
}

# Install Rust if not present
install_rust() {
    print_header "Setting up Rust Development Environment"
    
    if ! command -v cargo &> /dev/null; then
        print_status "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
        rustup default stable
    else
        print_status "Rust already installed"
        source $HOME/.cargo/env
    fi
    
    # Verify Rust installation
    if command -v cargo &> /dev/null; then
        print_status "Rust $(rustc --version) is ready"
    else
        print_error "Rust installation failed"
    fi
}

# Build asusctl from source
build_asusctl() {
    print_header "Building ASUSCTL from Source"
    
    cd asusctl
    
    # Clean any previous builds
    if [[ -d "target" ]]; then
        print_status "Cleaning previous build..."
        cargo clean
    fi
    
    # Build in release mode
    print_status "Compiling ASUSCTL (this may take several minutes)..."
    source $HOME/.cargo/env
    cargo build --release
    
    print_status "ASUSCTL compiled successfully"
    cd ..
}

# Install binaries and configuration files
install_asusctl() {
    print_header "Installing ASUSCTL System Components"
    
    cd asusctl
    
    # Copy main binaries (excluding asusd-user which is not needed for ROG Flow Z13)
    sudo cp target/release/asusctl /usr/bin/
    sudo cp target/release/asusd /usr/bin/
    
    # Set proper permissions
    sudo chmod +x /usr/bin/asusctl
    sudo chmod +x /usr/bin/asusd
    
    # Copy systemd service files
    sudo cp data/asusd.service /etc/systemd/system/
    
    # Copy D-Bus configuration
    sudo mkdir -p /usr/share/dbus-1/system.d/
    sudo cp data/asusd.conf /usr/share/dbus-1/system.d/
    
    # Copy udev rules
    sudo cp data/asusd.rules /etc/udev/rules.d/99-asusd.rules
    
    # Copy layout files for keyboard detection
    sudo mkdir -p /usr/share/rog-gui/layouts /usr/share/rog-gui
    sudo cp rog-aura/data/layouts/*.ron /usr/share/rog-gui/layouts/
    sudo cp rog-aura/data/aura_support.ron /usr/share/rog-gui/
    
    print_status "ASUSCTL components installed successfully"
    cd ..
}

# Configure services
configure_services() {
    print_header "Configuring System Services"
    
    # Reload systemd daemon
    sudo systemctl daemon-reload
    
    # Enable and start power-profiles-daemon
    sudo systemctl enable power-profiles-daemon
    sudo systemctl start power-profiles-daemon
    
    # Start asusd (it's triggered by udev, but we can start it manually)
    sudo systemctl start asusd
    
    # Reload udev rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    
    print_status "System services configured successfully"
}

# Install GNOME GUI
install_gnome_gui() {
    print_header "Installing GNOME Control Center GUI"
    
    # Install GTK4 and Adwaita dependencies
    sudo apt install -y python3-gi python3-gi-cairo gir1.2-gtk-4.0 gir1.2-adw-1 libadwaita-1-0
    
    # Install the GUI
    cd rog-control-center-gnome
    chmod +x install.sh
    ./install.sh
    cd ..
    
    # Configure passwordless sudo for asusctl
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/asusctl" | sudo tee /etc/sudoers.d/asusctl > /dev/null
    
    print_status "GNOME GUI installed successfully"
}

# Test installation
test_installation() {
    print_header "Testing ASUSCTL Installation"
    
    # Check if asusctl command works
    if command -v asusctl &> /dev/null; then
        print_status "ASUSCTL command-line tool is available"
        
        # Show version
        asusctl --version | head -3
        
        # Check supported features
        echo ""
        print_status "Supported laptop features:"
        asusctl -s 2>/dev/null | grep -E "(Supported|Active)" || true
        
    else
        print_error "ASUSCTL installation failed - command not found"
    fi
    
    # Check if services are running
    if systemctl is-active --quiet asusd; then
        print_status "ASUSD daemon is running"
    else
        print_warning "ASUSD daemon is not running - this is normal if hardware is not fully supported"
    fi
    
    
    # Check if GNOME GUI is available
    if command -v rog-control-center-gnome &> /dev/null; then
        print_status "ROG Control Center (GNOME) GUI is available"
    else
        print_warning "ROG Control Center GUI installation may have issues"
    fi
}

# Create quick reference guide
create_quick_reference() {
    print_header "Creating Quick Reference Guide"
    
    cat > ~/ASUSCTL_Quick_Reference.md << 'EOF'
# ASUSCTL Quick Reference - ROG Flow Z13

## Command Line Usage

### Power Profile Management
```bash
# Check current profile
asusctl profile -p

# List available profiles
asusctl profile -l

# Set performance profile (maximum performance)
sudo asusctl profile -P Performance

# Set balanced profile (good performance + battery life)
sudo asusctl profile -P Balanced

# Set quiet profile (maximum battery life)
sudo asusctl profile -P Quiet

# Toggle to next profile
sudo asusctl profile -n
```

### Keyboard Backlight Control
```bash
# Check current brightness
asusctl -k

# Set brightness levels
sudo asusctl -k off
sudo asusctl -k low
sudo asusctl -k med
sudo asusctl -k high

# Toggle brightness
sudo asusctl -n  # Next level
sudo asusctl -p  # Previous level
```

### Battery Management
```bash
# Set charge limit (20-100%)
sudo asusctl -c 80    # Limit to 80% (recommended for longevity)
sudo asusctl -c 100   # Allow full charge

# One-shot charge to 100% (bypasses limit once)
sudo asusctl -o
```

### System Information
```bash
# Show all supported features
asusctl -s

# Show version and help
asusctl --version
asusctl --help
```

## GUI Applications

### ROG Control Center
- **Launch**: Search for "ROG Control Center" in applications menu
- **Command**: `rog-control-center`
- **Features**: Graphical interface for all asusctl functions

### GNOME Integration
- Use Extension Manager to install ASUS-related GNOME extensions
- System tray integration available through extensions

## ROG Flow Z13 Specific Features

### Performance Profiles
- **Performance**: ~120W TDP - Gaming/rendering/ML training
- **Balanced**: ~70W TDP - General computing tasks
- **Quiet**: ~45W TDP - Battery life priority, minimal fan noise

### Best Practices
1. **For ML Development**: Use Performance mode during training, Balanced for coding
2. **Battery Longevity**: Set charge limit to 80-85%
3. **Thermal Management**: Monitor temperatures during intensive tasks
4. **Power Management**: Use Quiet mode when on battery power

## Troubleshooting

### Service Issues
```bash
# Check service status
sudo systemctl status asusd
systemctl --user status asusd-user

# Restart services
sudo systemctl restart asusd
systemctl --user restart asusd-user

# View service logs
journalctl -u asusd -f
```

### Permission Issues
```bash
# If commands require sudo unexpectedly, check D-Bus permissions
sudo systemctl restart dbus
```

## Advanced Configuration

### Auto Profile Switching
Create scripts or use GNOME extensions to automatically switch profiles based on:
- AC power connection status
- Running applications (games, ML frameworks)
- Battery level
- System temperature

### Integration with Existing Scripts
Your ML development scripts can now include:
```bash
# At start of intensive training
sudo asusctl profile -P Performance

# At end of training
sudo asusctl profile -P Balanced
```

Enjoy your optimized ROG Flow Z13 experience!
EOF

    print_status "Quick reference guide created at ~/ASUSCTL_Quick_Reference.md"
}

# Cleanup function
cleanup() {
    print_header "Cleaning up temporary files"
    
    # Remove Rust installation files if they exist
    rm -f ~/.rustup/tmp/* 2>/dev/null || true
    
    print_status "Cleanup completed"
}

# Main installation function
main() {
    print_header "ASUS ROG Flow Z13 - ASUSCTL Installation"
    echo "This script will install asusctl with full GUI support for your ROG Flow Z13"
    echo "Installation will take approximately 5-10 minutes depending on your system."
    echo ""
    
    read -p "Continue with installation? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    check_root
    check_requirements
    install_dependencies
    install_rust
    build_asusctl
    install_asusctl
    configure_services
    install_gnome_gui
    test_installation
    create_quick_reference
    cleanup
    
    print_header "Installation Complete!"
    print_status "ASUSCTL has been successfully installed with GUI support"
    print_status ""
    print_status "What's available now:"
    print_status "• Command line tool: asusctl"
    print_status "• Modern GNOME GUI: ROG Control Center"
    print_status "• Power profile management (Performance/Balanced/Quiet)"
    print_status "• Keyboard backlight control"
    print_status "• Battery charge limit control"
    print_status "• Fan curve management"
    print_status ""
    print_status "Quick start:"
    print_status "1. Open 'ROG Control Center' from applications menu"
    print_status "2. Try: asusctl profile -P Performance (no sudo needed!)"
    print_status "3. Launch GUI: rog-control-center-gnome"
    print_status "4. Check: ~/ASUSCTL_Quick_Reference.md for complete guide"
    print_status ""
    print_warning "Note: A reboot is recommended for optimal functionality"
    
    read -p "Would you like to reboot now? (y/N): " reboot_choice
    if [[ $reboot_choice =~ ^[Yy]$ ]]; then
        sudo reboot
    fi
}

# Run main function
main "$@"
