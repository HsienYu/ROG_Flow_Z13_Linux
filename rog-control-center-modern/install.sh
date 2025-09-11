#!/bin/bash
# Modern ROG Control Center Installation Script
# Replaces the old Slint-based GUI with a reliable GTK4 solution

set -e

echo "🚀 Installing Modern ROG Control Center..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "Do not run this script as root!"
    echo "Run as normal user: ./install.sh"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/share/rog-control-center-modern"
DESKTOP_FILE="/usr/share/applications/rog-control-center-modern.desktop"
LAUNCHER_SCRIPT="/usr/bin/rog-control-center"

echo ""
print_info "Installation directories:"
echo "  Source: $SCRIPT_DIR"
echo "  Install: $INSTALL_DIR"
echo "  Desktop: $DESKTOP_FILE"
echo "  Launcher: $LAUNCHER_SCRIPT"
echo ""

# Step 1: Install dependencies
print_info "Step 1: Installing dependencies..."

# Check for required packages
REQUIRED_PACKAGES=(
    "python3-gi"
    "python3-gi-cairo" 
    "gir1.2-gtk-4.0"
    "gir1.2-adw-1"
    "libadwaita-1-0"
    "power-profiles-daemon"
)

MISSING_PACKAGES=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -l "$pkg" >/dev/null 2>&1; then
        MISSING_PACKAGES+=("$pkg")
    fi
done

if [[ ${#MISSING_PACKAGES[@]} -gt 0 ]]; then
    print_info "Installing missing packages: ${MISSING_PACKAGES[*]}"
    sudo apt update
    sudo apt install -y "${MISSING_PACKAGES[@]}"
    print_status "Dependencies installed successfully"
else
    print_status "All dependencies already installed"
fi

# Step 2: Remove old ROG Control Center if present
print_info "Step 2: Cleaning up old ROG Control Center..."

# Remove old Slint-based binaries and files
OLD_FILES=(
    "/usr/bin/rog-control-center"
    "/usr/share/applications/rog-control-center.desktop"
    "/usr/share/rog-control-center"
)

for file in "${OLD_FILES[@]}"; do
    if [[ -e "$file" ]]; then
        print_info "Removing old file: $file"
        sudo rm -rf "$file"
    fi
done

print_status "Old files cleaned up"

# Step 3: Install new modern GUI
print_info "Step 3: Installing modern ROG Control Center..."

# Create installation directory
sudo mkdir -p "$INSTALL_DIR"

# Install Python application
sudo cp "$SCRIPT_DIR/rog_control_center.py" "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/rog_control_center.py"

print_status "Python application installed"

# Step 4: Create launcher script
print_info "Step 4: Creating launcher script..."

sudo tee "$LAUNCHER_SCRIPT" > /dev/null << 'EOF'
#!/bin/bash
# Modern ROG Control Center Launcher
# Ensures proper environment for GTK4 application

# Use system Python to avoid conda environment issues
export PATH="/usr/bin:$PATH"
export PYTHONPATH="/usr/lib/python3/dist-packages:$PYTHONPATH"

# GTK4/Adwaita environment
export GTK_THEME="Adwaita:dark"
export GDK_BACKEND="wayland,x11"

# Execute the application
exec /usr/bin/python3 /usr/share/rog-control-center-modern/rog_control_center.py "$@"
EOF

sudo chmod +x "$LAUNCHER_SCRIPT"
print_status "Launcher script created"

# Step 5: Create desktop entry
print_info "Step 5: Creating desktop entry..."

sudo tee "$DESKTOP_FILE" > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Name=ROG Control Center
Comment=Modern control center for ASUS ROG Flow Z13
Exec=rog-control-center
Icon=preferences-system
Terminal=false
Type=Application
Categories=Settings;HardwareSettings;System;
Keywords=asus;rog;power;performance;keyboard;battery;asusctl;
StartupNotify=true
EOF

print_status "Desktop entry created"

# Step 6: Configure passwordless sudo for asusctl
print_info "Step 6: Configuring passwordless sudo for asusctl..."

SUDOERS_FILE="/etc/sudoers.d/asusctl-rog-control"

# Check if already configured
if [[ -f "$SUDOERS_FILE" ]] && grep -q "$USER" "$SUDOERS_FILE" 2>/dev/null; then
    print_status "Passwordless sudo already configured"
else
    print_info "Setting up passwordless sudo for user: $USER"
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/asusctl" | sudo tee "$SUDOERS_FILE" > /dev/null
    sudo chmod 440 "$SUDOERS_FILE"
    print_status "Passwordless sudo configured"
fi

# Step 7: Update desktop database
print_info "Step 7: Updating desktop database..."
sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
print_status "Desktop database updated"

# Step 8: Test installation
print_info "Step 8: Testing installation..."

echo ""
print_info "Testing dependencies..."

# Test Python GTK4 imports
if /usr/bin/python3 -c "import gi; gi.require_version('Gtk', '4.0'); gi.require_version('Adw', '1')" 2>/dev/null; then
    print_status "GTK4/Adwaita imports working"
else
    print_error "GTK4/Adwaita import test failed"
    exit 1
fi

# Test asusctl access
if sudo -n asusctl --version >/dev/null 2>&1; then
    print_status "asusctl sudo access working"
else
    print_warning "asusctl sudo access not working - you may need to reboot"
fi

# Test powerprofilesctl
if powerprofilesctl --version >/dev/null 2>&1; then
    print_status "powerprofilesctl working"
else
    print_warning "powerprofilesctl not available"
fi

echo ""
print_status "Installation completed successfully!"
echo ""

# Final instructions
echo "🎉 Modern ROG Control Center Installation Complete!"
echo "================================================="
echo ""
echo "🚀 How to launch:"
echo "   • Applications menu: Search for 'ROG Control Center'"
echo "   • Terminal: rog-control-center"
echo "   • Command: /usr/bin/python3 /usr/share/rog-control-center-modern/rog_control_center.py"
echo ""
echo "✨ Features included:"
echo "   • ⚡ ASUSCTL Power Profiles (Performance/Balanced/Quiet)"
echo "   • 🖥️ GNOME Power Profiles (Power Saver/Balanced/Performance)"  
echo "   • ⌨️ Keyboard Backlight Control (Off/Low/Med/High)"
echo "   • 🔋 Battery Charge Limit Management"
echo "   • 🔆 F7/F8 Brightness Keys (Ubuntu native)"
echo "   • 📊 Real-time Status Display"
echo "   • 🎨 Modern GTK4/Adwaita Interface"
echo ""
echo "💡 Tips:"
echo "   • Both ASUSCTL and GNOME profiles work together"
echo "   • ASUSCTL controls hardware TDP, GNOME controls CPU governor"
echo "   • Set charge limit to 80-85% for daily use"
echo "   • Use F7/F8 for screen brightness (works natively)"
echo ""

if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    echo "🚀 Launch now? (y/N)"
    read -r -n 1 response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo ""
        print_info "Launching ROG Control Center..."
        nohup rog-control-center >/dev/null 2>&1 &
        sleep 2
        echo "✅ Application launched!"
    fi
else
    print_warning "No GUI detected. Reboot and launch from desktop environment."
fi

echo ""
echo "🎯 Installation complete! Enjoy your new ROG Control Center! 🎮"
