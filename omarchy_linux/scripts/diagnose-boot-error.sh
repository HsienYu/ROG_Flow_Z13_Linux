#!/bin/bash
# ROG Flow Z13 Boot Error Diagnostic Script
# Diagnoses "beseed32" and other BIOS/UEFI boot errors

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}ROG Flow Z13 Boot Error Diagnostic${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run with sudo${NC}"
    exit 1
fi

# 1. Check UEFI boot mode
echo -e "${YELLOW}[1] Checking UEFI Boot Mode...${NC}"
if [ -d /sys/firmware/efi ]; then
    PLATFORM_SIZE=$(cat /sys/firmware/efi/fw_platform_size 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✓ Booted in UEFI mode (${PLATFORM_SIZE}-bit)${NC}"
else
    echo -e "${RED}✗ NOT in UEFI mode - this may cause boot issues${NC}"
fi
echo ""

# 2. Check EFI boot entries
echo -e "${YELLOW}[2] EFI Boot Configuration:${NC}"
efibootmgr -v | head -20
echo ""

# 3. Check for ASUS-specific kernel errors
echo -e "${YELLOW}[3] Checking for ASUS/Firmware Errors in Kernel Log...${NC}"
if dmesg | grep -i "asus\|firmware" | grep -i "error\|fail\|warn" | head -10; then
    echo -e "${YELLOW}⚠ Found potential issues above${NC}"
else
    echo -e "${GREEN}✓ No critical ASUS/firmware errors found${NC}"
fi
echo ""

# 4. Check BIOS/EC firmware versions
echo -e "${YELLOW}[4] System Firmware Information:${NC}"
if [ -f /sys/class/dmi/id/bios_version ]; then
    echo "BIOS Version: $(cat /sys/class/dmi/id/bios_version)"
fi
if [ -f /sys/class/dmi/id/bios_date ]; then
    echo "BIOS Date: $(cat /sys/class/dmi/id/bios_date)"
fi
if [ -f /sys/class/dmi/id/product_name ]; then
    echo "Product: $(cat /sys/class/dmi/id/product_name)"
fi
echo ""

# 5. Check Secure Boot status
echo -e "${YELLOW}[5] Secure Boot Status:${NC}"
if [ -f /sys/firmware/efi/efivars/SecureBoot-* ]; then
    if mokutil --sb-state 2>/dev/null; then
        :
    elif [ -f /sys/firmware/efi/vars/SecureBoot-*/data ]; then
        SB_STATE=$(od -An -t u1 /sys/firmware/efi/vars/SecureBoot-*/data | awk '{print $1}')
        if [ "$SB_STATE" = "1" ]; then
            echo -e "${YELLOW}Secure Boot: Enabled${NC}"
        else
            echo -e "${GREEN}Secure Boot: Disabled${NC}"
        fi
    else
        echo "Secure Boot: Unknown (install mokutil for details)"
    fi
else
    echo "Secure Boot: Not available"
fi
echo ""

# 6. Check EFI variables space
echo -e "${YELLOW}[6] EFI Variables Storage:${NC}"
if [ -d /sys/firmware/efi/efivars ]; then
    VAR_COUNT=$(ls /sys/firmware/efi/efivars/ | wc -l)
    echo "EFI Variables: $VAR_COUNT entries"
    if [ "$VAR_COUNT" -gt 200 ]; then
        echo -e "${YELLOW}⚠ High number of EFI variables - may cause boot issues${NC}"
    else
        echo -e "${GREEN}✓ Normal EFI variable count${NC}"
    fi
else
    echo -e "${RED}✗ EFI variables not accessible${NC}"
fi
echo ""

# 7. Check for common boot issues
echo -e "${YELLOW}[7] Boot Partition Check:${NC}"
if mount | grep -q "/boot"; then
    echo -e "${GREEN}✓ /boot is mounted${NC}"
    BOOT_SPACE=$(df -h /boot | awk 'NR==2 {print $4}')
    echo "Available space: $BOOT_SPACE"
else
    echo -e "${YELLOW}⚠ /boot not separately mounted${NC}"
fi
echo ""

# 8. Check for ACPI errors
echo -e "${YELLOW}[8] ACPI Error Check:${NC}"
if dmesg | grep -i "acpi" | grep -i "error\|fail" | head -5; then
    echo -e "${YELLOW}⚠ ACPI errors detected${NC}"
else
    echo -e "${GREEN}✓ No critical ACPI errors${NC}"
fi
echo ""

# 9. Recommendations
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Recommendations for 'beseed32' Error:${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}If you're seeing 'beseed32' error during boot:${NC}"
echo ""
echo "1. Reset BIOS to defaults:"
echo "   - Reboot and press F2/DEL to enter BIOS"
echo "   - Find 'Load Optimized Defaults' option"
echo "   - Save and exit"
echo ""
echo "2. Disable Secure Boot (if enabled):"
echo "   - Enter BIOS → Security → Secure Boot"
echo "   - Set to Disabled"
echo ""
echo "3. Update BIOS firmware:"
echo "   - Visit: https://rog.asus.com/support/"
echo "   - Search for 'ROG Flow Z13 GZ302'"
echo "   - Download latest BIOS update"
echo ""
echo "4. Clear EC (Embedded Controller):"
echo "   - Power off completely"
echo "   - Unplug AC adapter"
echo "   - Hold power button for 60 seconds"
echo "   - Reconnect and boot"
echo ""
echo "5. Check boot order:"
echo "   - Run: sudo efibootmgr"
echo "   - Ensure Linux bootloader is first"
echo ""

# Save log
LOG_FILE="/tmp/boot-diagnostic-$(date +%Y%m%d-%H%M%S).log"
{
    echo "=== Boot Diagnostic Log ==="
    echo "Date: $(date)"
    echo ""
    echo "=== UEFI Mode ==="
    cat /sys/firmware/efi/fw_platform_size 2>/dev/null || echo "Not available"
    echo ""
    echo "=== EFI Boot Manager ==="
    efibootmgr -v
    echo ""
    echo "=== BIOS Info ==="
    cat /sys/class/dmi/id/bios_version 2>/dev/null
    echo ""
    echo "=== Kernel Messages (ASUS/Firmware) ==="
    dmesg | grep -i "asus\|firmware\|bios\|efi" | tail -100
} > "$LOG_FILE"

echo -e "${GREEN}Full diagnostic log saved to: $LOG_FILE${NC}"
