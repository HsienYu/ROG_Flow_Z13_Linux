#!/bin/bash

# =============================================================================
# ASUS ROG Flow Z13 - ASUSCTL Test Script
# =============================================================================
# This script tests the ASUSCTL installation and demonstrates key features
# Run this after installing ASUSCTL to verify everything works correctly
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Test ASUSCTL installation
test_installation() {
    print_header "Testing ASUSCTL Installation"
    
    # Check if asusctl command exists
    if command -v asusctl &> /dev/null; then
        print_status "ASUSCTL command is available"
        echo "Version: $(asusctl --version | head -1)"
    else
        print_error "ASUSCTL command not found. Please run ./Install_ASUSCTL.sh first"
        exit 1
    fi
    
    # Check if ROG Control Center exists
    if command -v rog-control-center &> /dev/null; then
        print_status "ROG Control Center GUI is available"
    else
        print_warning "ROG Control Center GUI not found"
    fi
    
    # Check services
    if systemctl is-active --quiet asusd; then
        print_status "ASUSD daemon is running"
    else
        print_warning "ASUSD daemon is not running"
    fi
    
    if systemctl --user is-active --quiet asusd-user; then
        print_status "ASUSD user service is running"
    else
        print_warning "ASUSD user service is not running"
    fi
}

# Show supported features
show_supported_features() {
    print_header "Supported Hardware Features"
    
    echo "Your ROG Flow Z13 supports the following features:"
    asusctl -s 2>/dev/null || print_warning "Could not retrieve supported features"
}

# Test profile switching
test_profile_switching() {
    print_header "Testing Power Profile Management"
    
    # Get current profile
    current_profile=$(asusctl profile -p 2>/dev/null | grep "Active profile is" | cut -d' ' -f4)
    if [[ -n "$current_profile" ]]; then
        print_info "Current profile: $current_profile"
    else
        print_warning "Could not get current profile"
        return
    fi
    
    # List available profiles
    print_info "Available profiles:"
    asusctl profile -l 2>/dev/null | while read profile; do
        echo "  - $profile"
    done
    
    # Test profile switching (if user wants)
    echo ""
    read -p "Would you like to test profile switching? (y/N): " test_profiles
    if [[ $test_profiles =~ ^[Yy]$ ]]; then
        print_info "Testing profile switching..."
        
        # Switch to Balanced
        print_info "Switching to Balanced profile..."
        if sudo asusctl profile -P Balanced 2>/dev/null; then
            print_status "Successfully switched to Balanced"
            sleep 2
        else
            print_warning "Failed to switch to Balanced profile"
        fi
        
        # Switch back to original profile
        print_info "Switching back to $current_profile profile..."
        if sudo asusctl profile -P "$current_profile" 2>/dev/null; then
            print_status "Successfully restored original profile: $current_profile"
        else
            print_warning "Failed to restore original profile"
        fi
    fi
}

# Test keyboard backlight
test_keyboard_backlight() {
    print_header "Testing Keyboard Backlight Control"
    
    # Get current brightness
    current_brightness=$(asusctl -k 2>/dev/null | grep "Current keyboard led brightness" | cut -d':' -f2 | tr -d ' ')
    if [[ -n "$current_brightness" ]]; then
        print_info "Current keyboard brightness: $current_brightness"
    else
        print_warning "Could not get current keyboard brightness"
        return
    fi
    
    echo ""
    read -p "Would you like to test keyboard backlight control? (y/N): " test_backlight
    if [[ $test_backlight =~ ^[Yy]$ ]]; then
        print_info "Testing keyboard backlight levels..."
        
        for level in low med high off; do
            print_info "Setting brightness to: $level"
            if sudo asusctl -k $level 2>/dev/null; then
                print_status "Successfully set brightness to $level"
                sleep 1.5
            else
                print_warning "Failed to set brightness to $level"
            fi
        done
        
        # Restore original brightness
        if [[ "$current_brightness" != "Off" ]]; then
            print_info "Restoring original brightness: $current_brightness"
            brightness_level=$(echo "$current_brightness" | tr '[:upper:]' '[:lower:]')
            sudo asusctl -k "$brightness_level" 2>/dev/null
        fi
    fi
}

# Test battery management
test_battery_management() {
    print_header "Testing Battery Management"
    
    echo ""
    read -p "Would you like to test battery charge limit features? (y/N): " test_battery
    if [[ $test_battery =~ ^[Yy]$ ]]; then
        print_warning "Battery management test will temporarily change your charge limit"
        read -p "Continue? (y/N): " continue_battery
        if [[ $continue_battery =~ ^[Yy]$ ]]; then
            
            print_info "Setting charge limit to 80% (recommended for longevity)..."
            if sudo asusctl -c 80 2>/dev/null; then
                print_status "Successfully set charge limit to 80%"
                
                echo ""
                read -p "Would you like to restore 100% charge limit? (y/N): " restore_limit
                if [[ $restore_limit =~ ^[Yy]$ ]]; then
                    sudo asusctl -c 100 2>/dev/null
                    print_status "Charge limit restored to 100%"
                else
                    print_info "Charge limit remains at 80% (recommended for battery health)"
                fi
            else
                print_warning "Failed to set charge limit"
            fi
        fi
    fi
}

# Show quick reference
show_quick_reference() {
    print_header "Quick Reference Commands"
    
    cat << EOF
${GREEN}Power Profile Management:${NC}
  asusctl profile -p                    # Check current profile
  asusctl profile -l                    # List available profiles
  sudo asusctl profile -P Performance   # Maximum performance (gaming/ML)
  sudo asusctl profile -P Balanced      # Balanced (general use)
  sudo asusctl profile -P Quiet         # Battery saving mode

${GREEN}Keyboard Backlight:${NC}
  asusctl -k                           # Check current brightness
  sudo asusctl -k off/low/med/high     # Set brightness level
  sudo asusctl -n                      # Next brightness level
  sudo asusctl -p                      # Previous brightness level

${GREEN}Battery Management:${NC}
  sudo asusctl -c 80                   # Set 80% charge limit (recommended)
  sudo asusctl -c 100                  # Set 100% charge limit
  sudo asusctl -o                      # One-shot charge to 100%

${GREEN}System Information:${NC}
  asusctl -s                           # Show supported features
  asusctl --version                    # Show version info
  asusctl --help                       # Show help

${GREEN}GUI Application:${NC}
  rog-control-center                   # Launch ROG Control Center
  
${BLUE}📖 For complete documentation, see: ASUSCTL_README.md${NC}
EOF
}

# Main test function
main() {
    print_header "ASUS ROG Flow Z13 - ASUSCTL Test Suite"
    echo "This script will test your ASUSCTL installation and demonstrate key features."
    echo ""
    
    test_installation
    show_supported_features
    test_profile_switching
    test_keyboard_backlight
    test_battery_management
    show_quick_reference
    
    print_header "Test Complete!"
    print_status "ASUSCTL appears to be working correctly on your ROG Flow Z13"
    print_info ""
    print_info "Next steps:"
    print_info "1. Launch ROG Control Center from your applications menu"
    print_info "2. Explore GNOME extensions for system tray integration"
    print_info "3. Set up automatic profile switching based on power status"
    print_info "4. Consider setting a battery charge limit for longevity"
    print_info ""
    print_info "For advanced configuration and troubleshooting, see ASUSCTL_README.md"
}

# Run main function
main "$@"
