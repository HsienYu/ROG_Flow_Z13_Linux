#!/bin/bash

# Install.sh - Configurable Arch Linux Installation Script for ASUS ROG Flow Z13
# Author: sqazi / Gemini
# Version: 2.0.0
# Date: September 10, 2025

set -e  # Exit on any error

# --- Colors and Global Vars ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
FS_TYPE=""
INSTALL_DESKTOP=""
INSTALL_GAMING=""
INSTALL_POWER_MGMT=""
DUAL_BOOT=""
ENABLE_SNAPSHOTS=""
DISK_DEVICE=""
USERNAME=""
HOTNAME=""
TIMEZONE=""

# --- Helper Functions ---
print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# --- Core Installation Functions ---

configure_installation() {
    print_header "ASUS ROG Flow Z13 Arch Linux Installation Configuration"
    
    # Filesystem selection
    read -p "Choose filesystem [zfs|ext4] (zfs): " fs_choice
    FS_TYPE=${fs_choice:-zfs}
    print_status "Selected filesystem: $FS_TYPE"

    # Disk selection
    print_status "Available disks:"; lsblk -d -o NAME,SIZE,MODEL; echo ""
    while true; do
        read -p "Enter the disk device (e.g., nvme0n1): " DISK_DEVICE
        [[ -z "$DISK_DEVICE" ]] && { print_error "Disk device cannot be empty."; continue; }
        DISK_DEVICE="${DISK_DEVICE#/dev/}"
        [[ ! -b "/dev/$DISK_DEVICE" ]] && { print_error "Disk /dev/$DISK_DEVICE does not exist."; continue; }
        print_warning "You selected: /dev/$DISK_DEVICE"
        read -p "Is this correct? (y/n): " confirm_disk
        [[ $confirm_disk == "y" ]] && { DISK_DEVICE="/dev/$DISK_DEVICE"; break; }
    done
    
    read -p "Do you want to preserve Windows for dual-boot? (y/n): " DUAL_BOOT
    
    while true; do read -p "Enter username: " USERNAME; [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]] && break || print_error "Invalid username."; done
    while true; do read -p "Enter hostname: " HOSTNAME; [[ "$HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]] && break || print_error "Invalid hostname."; done
    while true; do read -p "Enter timezone (e.g., America/New_York): " TIMEZONE; [[ -f "/usr/share/zoneinfo/$TIMEZONE" ]] && break || print_warning "Timezone not found. Try again."; done
    
    echo "Desktop Options: 1) Omarchy 2) XFCE 3) i3 4) GNOME 5) KDE 6) Minimal"
    read -p "Choose desktop environment (1): " desktop_choice
    case $desktop_choice in 1) INSTALL_DESKTOP=\"omarchy\";; 2) INSTALL_DESKTOP=\"xfce\";; 3) INSTALL_DESKTOP=\"i3\";; 4) INSTALL_DESKTOP=\"gnome\";; 5) INSTALL_DESKTOP=\"kde\";; 6) INSTALL_DESKTOP=\"minimal\";; *) INSTALL_DESKTOP=\"omarchy\";; esac
    
    read -p "Install gaming setup (Steam, Proton, GameMode)? (y/n): " INSTALL_GAMING
    read -p "Install advanced power management (asusctl, TLP)? (y/n): " INSTALL_POWER_MGMT
    if [[ "$FS_TYPE" == "zfs" ]]; then
        read -p "Enable ZFS snapshots for system recovery? (y/n): " ENABLE_SNAPSHOTS
    fi
    
    print_header "Installation Summary"
    echo "Disk: $DISK_DEVICE, Dual-boot: $DUAL_BOOT, Filesystem: $FS_TYPE"
    echo "User: $USERNAME, Host: $HOSTNAME, Desktop: $INSTALL_DESKTOP"
    
    read -p "Proceed with installation? (y/n): " confirm
    [[ $confirm != "y" ]] && { print_error "Installation cancelled."; exit 1; }
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    [[ ! -d /sys/firmware/efi ]] && { print_error "Not in UEFI mode."; exit 1; }
    ! ping -c 1 archlinux.org &> /dev/null && { print_error "No internet connection."; exit 1; }
    timedatectl set-ntp true
    print_status "Prerequisites check completed."
}

partition_disk() {
    print_header "Partitioning Disk"
    if [[ $DUAL_BOOT == "y" ]]; then
        print_status "Dual-boot mode: Creating Linux partitions in free space."
        ram_size=$(free -m | awk \'/^Mem:/{print $2}\' ); swap_size=$((ram_size + 1000))
        sgdisk -n 0:0:+${swap_size}M -t 0:8200 -c 0:"Linux Swap" $DISK_DEVICE
        sgdisk -n 0:0:0 -t 0:8300 -c 0:"Linux Root" $DISK_DEVICE
    else
        print_status "Single-boot mode: Wiping disk and creating new partition table."
        sgdisk -Z $DISK_DEVICE; sgdisk -o $DISK_DEVICE
        ram_size=$(free -m | awk \'/^Mem:/{print $2}\' ); swap_size=$((ram_size + 1000))
        sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System" $DISK_DEVICE
        sgdisk -n 2:0:+${swap_size}M -t 2:8200 -c 2:"Linux Swap" $DISK_DEVICE
        sgdisk -n 3:0:0 -t 3:8300 -c 3:"Linux Root" $DISK_DEVICE
    fi
    
    print_status "Informing kernel of partition changes..."
    partprobe $DISK_DEVICE; sleep 2
    
    print_status "Discovering partition device names..."
    if [[ $DUAL_BOOT == "y" ]]; then
        mapfile -t new_partitions < <(lsblk -prno NAME "$DISK_DEVICE" | tail -n 2)
        swap_part="${new_partitions[0]}"; root_part="${new_partitions[1]}"
        efi_part=$(lsblk -prno NAME,PARTTYPE "$DISK_DEVICE" | grep -i "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" | awk \'{print $1}\' )
    else
        mapfile -t all_partitions < <(lsblk -prno NAME "$DISK_DEVICE" | tail -n 3)
        efi_part="${all_partitions[0]}"; swap_part="${all_partitions[1]}"; root_part="${all_partitions[2]}"
    fi
    print_status "Partitions assigned: EFI=$efi_part, SWAP=$swap_part, ROOT=$root_part"
}

setup_filesystem() {
    print_header "Formatting and Mounting Filesystem ($FS_TYPE)"
    
    # Format EFI (if not dual-boot) and Swap
    [[ $DUAL_BOOT != "y" ]] && { print_status "Formatting EFI partition..."; mkfs.fat -F32 -n \"EFI\" $efi_part; }
    print_status "Setting up swap..."; mkswap -L \"Arch_Swap\" $swap_part; swapon $swap_part

    if [[ "$FS_TYPE" == "zfs" ]]; then
        print_status "Creating ZFS pool \'zroot\'...".
        zpool create -f -o ashift=12 -O compression=zstd -O acltype=posixacl -O xattr=sa -O relatime=on -O normalization=formD -O mountpoint=none -O canmount=off -O dnodesize=auto -O sync=disabled -R /mnt zroot $root_part
        
        print_status "Creating ZFS datasets..."
        zfs create -o mountpoint=none zroot/ROOT
        zfs create -o mountpoint=/ -o canmount=noauto zroot/ROOT/default
        zfs create -o mountpoint=/home zroot/home
        zfs create -o mountpoint=/var -o canmount=off zroot/var; zfs create zroot/var/log; zfs create zroot/var/cache
        
        if [[ $ENABLE_SNAPSHOTS == "y" ]]; then
            zfs set com.sun:auto-snapshot=true zroot/ROOT/default; zfs set com.sun:auto-snapshot=true zroot/home
        fi
        
        print_status "Mounting ZFS datasets..."
        zfs mount zroot/ROOT/default; zfs mount -a
    else # ext4
        print_status "Formatting root partition with ext4..."
        mkfs.ext4 -L \"Arch_Root\" $root_part
        print_status "Mounting ext4 root partition..."
        mount $root_part /mnt
    fi
    
    print_status "Mounting EFI partition..."
    mkdir -p /mnt/boot; mount $efi_part /mnt/boot
}

install_base_system() {
    print_header "Installing Base System"
    pacman -Sy --noconfirm
    
    local base_packages="base linux-zen linux-firmware base-devel vim nano networkmanager git wget curl intel-ucode amd-ucode zsh grub efibootmgr"
    [[ "$FS_TYPE" == "zfs" ]] && base_packages="$base_packages zfs-dkms zfs-utils"
    [[ "$DUAL_BOOT" == "y" ]] && base_packages="$base_packages os-prober ntfs-3g"
    [[ "$ENABLE_SNAPSHOTS" == "y" ]] && base_packages="$base_packages zfs-auto-snapshot"

    print_status "Installing packages (this may take a while)..."
    pacstrap /mnt $base_packages
    print_status "Base system installation completed."
}

configure_system() {
    print_header "Configuring System"
    genfstab -U /mnt >> /mnt/etc/fstab
    
    arch-chroot /mnt /bin/bash <<EOF
set -e
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime; hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen; locale-gen; echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts; echo "::1 localhost" >> /etc/hosts; echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

if [[ "$DUAL_BOOT" == "y" ]]; then echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub; fi
sed -i \'s/GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\"/& ibt=off/\' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo -e "\n\033[0;34m--- Verifying Bootloader ---\\033[0m"
if efibootmgr | grep -q "GRUB"; then echo -e "\033[0;32m[INFO] GRUB boot entry created successfully.\\033[0m"; else echo -e "\033[1;33m[WARNING] GRUB boot entry not found via efibootmgr.\\033[0m"; fi
if [[ "$DUAL_BOOT" == "y" ]]; then if grep -qi "Windows Boot Manager" /boot/grub/grub.cfg; then echo -e "\033[0;32m[INFO] Windows detected.\\033[0m"; else echo -e "\033[1;33m[WARNING] Windows not detected by os-prober.\\033[0m"; fi; fi

useradd -m -G wheel -s /bin/zsh $USERNAME
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10-wheel-sudo

systemctl enable NetworkManager; systemctl enable fstrim.timer; systemctl enable systemd-timesyncd
EOF
    print_status "System configuration completed."
}

create_post_install_script() {
    print_header "Creating Post-Installation Helper Script"
    local script_path="/mnt/home/$USERNAME/Z13_Quick_Tips.txt"
    
    cat > "$script_path" << EOF
Welcome to your new Arch Linux installation on the ROG Flow Z13!

Here are some useful commands:

--- Power Management (asusctl) ---
# List available power profiles
asusctl profile -L

# Set a power profile (e.g., Performance, Balanced, Quiet)
sudo asusctl profile -P Performance

--- ZFS Snapshots ---
# List snapshots (if you enabled them)
zfs list -t snapshot

# zfs-auto-snapshot will create snapshots automatically.
# You can manage the service with:
systemctl list-timers | grep zfs

--- System Updates ---
# Update all packages from repositories and AUR
yay -Syu

Enjoy your new system!
EOF
    # Set correct ownership
    arch-chroot /mnt chown $USERNAME:$USERNAME /home/$USERNAME/Z13_Quick_Tips.txt
    print_status "Helper script created at $script_path"
}

# --- Standalone Repair Function ---
repair_bootloader_standalone() {
    print_header "EFI Bootloader Repair"
    print_warning "This tool expects you to have mounted your Linux root partition at /mnt"
    print_warning "and your EFI partition at /mnt/boot."
    read -p "Have you mounted the partitions correctly? (y/n): " confirm_mount
    [[ $confirm_mount != "y" ]] && { print_error "Aborting."; exit 1; }

    print_status "Entering chroot to repair bootloader..."
    arch-chroot /mnt /bin/bash <<EOF
set -e
pacman -S --noconfirm grub efibootmgr os-prober
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB-Repaired --recheck
grub-mkconfig -o /boot/grub/grub.cfg
echo "Bootloader repair process finished. Check the output above."
EOF
}

# --- Main Execution Flow ---
full_installation() {
    trap cleanup_on_failure ERR
    configure_installation
    check_prerequisites
    partition_disk
    setup_filesystem
    install_base_system
    configure_system
    
    # Chroot for remaining installations
    arch-chroot /mnt /bin/bash <<CHROOT_POST
set -e
# Define USERNAME for this script block
USERNAME=$USERNAME

# Helper to install yay AUR helper
install_yay() {
    if command -v yay &> /dev/null; then return; fi
    pacman -S --noconfirm --needed git base-devel
    cd /tmp
    sudo -u \$USERNAME git clone https://aur.archlinux.org/yay.git
    cd yay
    sudo -u \$USERNAME makepkg -si --noconfirm
    cd / && rm -rf /tmp/yay
}

# Hardware Fixes
mkdir -p /etc/modprobe.d
echo "options mt7925e disable_aspm=1" > /etc/modprobe.d/mt7925e.conf
cat > /etc/systemd/system/reload-hid_asus.service << EOH
[Unit]
Description=Reload hid_asus module for touchpad detection
[Service]
Type=oneshot
ExecStart=/usr/bin/modprobe -r hid_asus; /usr/bin/modprobe hid_asus
[Install]
WantedBy=multi-user.target
EOH
systemctl enable reload-hid_asus.service

# Power Management
if [[ "$INSTALL_POWER_MGMT" == "y" ]]; then
    install_yay
    pacman -S --noconfirm tlp
    sudo -u \$USERNAME yay -S --noconfirm asusctl
    systemctl enable tlp; systemctl enable asusd.service
    echo -e "TLP_DEFAULT_MODE=AC\nCPU_SCALING_GOVERNOR_ON_AC=performance\nCPU_SCALING_GOVERNOR_ON_BAT=powersave" >> /etc/tlp.conf
fi

# Desktop Environment
case "$INSTALL_DESKTOP" in
    "omarchy") install_yay; sudo -u \$USERNAME yay -S --noconfirm omarchy; pacman -S --noconfirm lightdm; systemctl enable lightdm;; 
    "xfce") pacman -S --noconfirm xfce4 xfce4-goodies lightdm; systemctl enable lightdm;; 
    "i3") pacman -S --noconfirm i3-wm i3status dmenu lightdm; systemctl enable lightdm;; 
    "gnome") pacman -S --noconfirm gnome; systemctl enable gdm;; 
    "kde") pacman -S --noconfirm plasma kde-applications; systemctl enable sddm;; 
esac
if [[ "$INSTALL_DESKTOP" != "minimal" ]]; then pacman -S --noconfirm xorg-server firefox alacritty; fi

# Gaming
if [[ "$INSTALL_GAMING" == "y" ]]; then
    sed -i "/\\[multilib\\]/",'/Include/' s/^#// /etc/pacman.conf
    pacman -Sy
    pacman -S --noconfirm steam gamemode mangohud lib32-mesa
fi

# Snapshots
if [[ "$ENABLE_SNAPSHOTS" == "y" ]]; then
    systemctl enable zfs-snapshot-boot.timer; systemctl enable zfs-snapshot-hourly.timer; systemctl enable zfs-snapshot-daily.timer
fi
CHROOT_POST

    create_post_install_script
    set_passwords
    final_update
    cleanup_and_finish
}

cleanup_on_failure() { print_error "Installation failed. Cleaning up..."; umount -R /mnt 2>/dev/null || true; if [[ "$FS_TYPE" == "zfs" ]]; then zpool destroy -f zroot 2>/dev/null || true; fi; exit 1; }
set_passwords() { print_header "Setting Passwords"; arch-chroot /mnt passwd; arch-chroot /mnt passwd $USERNAME; }
final_update() { print_header "Final System Update"; arch-chroot /mnt pacman -Syu --noconfirm; }
cleanup_and_finish() { print_header "Installation Complete"; umount -R /mnt; print_status "Reboot to enjoy your new system!"; read -p "Reboot now? (y/n): " r; [[ $r == "y" ]] && reboot; }

main() {
    [[ $EUID -ne 0 ]] && { print_error "This script must be run as root."; exit 1; }
    print_header "ASUS ROG Flow Z13 Arch Linux Setup"
    echo "1) Perform a full installation"
    echo "2) Repair EFI bootloader"
    read -p "Choose an option [1-2]: " main_choice

    case $main_choice in
        1) full_installation ;; 
        2) repair_bootloader_standalone ;; 
        *) print_error "Invalid option." ; exit 1 ;; 
    esac
}

main "$@"
