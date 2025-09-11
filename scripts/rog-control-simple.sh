#!/bin/bash
# Simple ROG Control Utility for Ubuntu (CLI replacement for ROG Control Center)
# Compatible with Ubuntu-minimal asusctl build

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display header
show_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}🎮 ROG Flow Z13 Control Utility${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Function to show current status
show_status() {
    echo -e "${GREEN}📊 Current Status:${NC}"
    echo "=================="
    
    # Power profile (via GNOME)
    if command -v powerprofilesctl >/dev/null 2>&1; then
        local current_profile=$(powerprofilesctl get 2>/dev/null || echo "unknown")
        echo -e "⚡ Power Mode: ${YELLOW}$current_profile${NC}"
    fi
    
    # Keyboard backlight
    if command -v asusctl >/dev/null 2>&1; then
        local kbd_brightness=$(asusctl -k 2>/dev/null | grep "brightness:" | awk '{print $NF}' || echo "unknown")
        echo -e "💡 Keyboard Backlight: ${YELLOW}$kbd_brightness${NC}"
    fi
    
    # Service status
    if systemctl is-active asusd >/dev/null 2>&1; then
        echo -e "🔧 asusd Service: ${GREEN}Running${NC}"
    else
        echo -e "🔧 asusd Service: ${RED}Not Running${NC}"
    fi
    echo ""
}

# Function to set power profile
set_power_profile() {
    echo -e "${GREEN}⚡ Power Profile Management:${NC}"
    echo "============================"
    echo "1) Power Saver (Battery optimized)"
    echo "2) Balanced (Default)"
    echo "3) Performance (High performance)"
    echo "4) Back to main menu"
    echo ""
    read -p "Choose option (1-4): " choice
    
    case $choice in
        1)
            powerprofilesctl set power-saver 2>/dev/null && 
            echo -e "${GREEN}✅ Switched to Power Saver mode${NC}" ||
            echo -e "${RED}❌ Failed to set power mode${NC}"
            ;;
        2)
            powerprofilesctl set balanced 2>/dev/null && 
            echo -e "${GREEN}✅ Switched to Balanced mode${NC}" ||
            echo -e "${RED}❌ Failed to set power mode${NC}"
            ;;
        3)
            powerprofilesctl set performance 2>/dev/null && 
            echo -e "${GREEN}✅ Switched to Performance mode${NC}" ||
            echo -e "${RED}❌ Failed to set power mode${NC}"
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            ;;
    esac
    echo ""
}

# Function to set keyboard backlight
set_keyboard_backlight() {
    echo -e "${GREEN}💡 Keyboard Backlight Control:${NC}"
    echo "=============================="
    echo "1) Off"
    echo "2) Low"
    echo "3) Medium"
    echo "4) High"
    echo "5) Back to main menu"
    echo ""
    read -p "Choose option (1-5): " choice
    
    case $choice in
        1)
            asusctl -k off >/dev/null 2>&1 && 
            echo -e "${GREEN}✅ Keyboard backlight turned off${NC}" ||
            echo -e "${RED}❌ Failed to set keyboard backlight${NC}"
            ;;
        2)
            asusctl -k low >/dev/null 2>&1 && 
            echo -e "${GREEN}✅ Keyboard backlight set to low${NC}" ||
            echo -e "${RED}❌ Failed to set keyboard backlight${NC}"
            ;;
        3)
            asusctl -k med >/dev/null 2>&1 && 
            echo -e "${GREEN}✅ Keyboard backlight set to medium${NC}" ||
            echo -e "${RED}❌ Failed to set keyboard backlight${NC}"
            ;;
        4)
            asusctl -k high >/dev/null 2>&1 && 
            echo -e "${GREEN}✅ Keyboard backlight set to high${NC}" ||
            echo -e "${RED}❌ Failed to set keyboard backlight${NC}"
            ;;
        5)
            return
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            ;;
    esac
    echo ""
}

# Function to show system info
show_system_info() {
    echo -e "${GREEN}ℹ️ System Information:${NC}"
    echo "====================="
    
    if command -v asusctl >/dev/null 2>&1; then
        asusctl --version 2>/dev/null | head -n 10
    else
        echo "asusctl not available"
    fi
    echo ""
    
    echo -e "${YELLOW}💡 Tips:${NC}"
    echo "• Use F7/F8 for screen brightness (Ubuntu native)"
    echo "• Access power modes via Settings → Power → Power Mode"
    echo "• This utility manages only keyboard backlight via asusctl"
    echo ""
}

# Main menu
main_menu() {
    while true; do
        show_header
        show_status
        
        echo -e "${GREEN}🎛️ Available Options:${NC}"
        echo "===================="
        echo "1) Power Profile Management"
        echo "2) Keyboard Backlight Control"
        echo "3) System Information"
        echo "4) Exit"
        echo ""
        read -p "Choose option (1-4): " choice
        
        case $choice in
            1)
                set_power_profile
                read -p "Press Enter to continue..."
                ;;
            2)
                set_keyboard_backlight
                read -p "Press Enter to continue..."
                ;;
            3)
                show_system_info
                read -p "Press Enter to continue..."
                ;;
            4)
                echo -e "${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}⚠️ Running as root. Some features may not work properly in GUI mode.${NC}"
    echo ""
fi

# Check dependencies
if ! command -v asusctl >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: asusctl not found. Please install Ubuntu-minimal asusctl first.${NC}"
    exit 1
fi

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Warning: powerprofilesctl not found. Power profile management may not work.${NC}"
    echo ""
fi

# Start main menu
main_menu
