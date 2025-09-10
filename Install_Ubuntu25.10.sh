#!/bin/bash

#Install_Ubuntu25.10.sh - Configurable Ubuntu 25.10 Installation Script for ASUS ROG Flow Z13
#Author: Gemini (adapted from sqazi's Arch script)
#Version: 2.0.0
#Date: September 10, 2025

set -e  # Exit on any error

# --- Colors and Global Vars ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

UBUNTU_CODENAME="noble" # NOTE: Using 24.04 LTS as a stable base. Update if needed.

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
print_header() { echo -e "${BLUE}================================\\n$1\\n================================${NC}"; }

# --- Core Installation Functions ---

configure_installation() {
    print_header "ASUS ROG Flow Z13 Ubuntu 25.10 Installation Configuration"
    read -p "Choose filesystem [zfs|ext4] (zfs): " fs_choice; FS_TYPE=${fs_choice:-zfs}
    print_status "Available disks:"; lsblk -d -o NAME,SIZE,MODEL; echo ""
    while true; do
        read -p "Enter the disk device (e.g., nvme0n1): " DISK_DEVICE
        [[ -z "$DISK_DEVICE" ]] && { print_error "Disk device cannot be empty."; continue; }
        DISK_DEVICE="${DISK_DEVICE#/dev/}"; [[ ! -b "/dev/$DISK_DEVICE" ]] && { print_error "Disk does not exist."; continue; }
        read -p "Confirm disk /dev/$DISK_DEVICE? (y/n): " confirm_disk; [[ $confirm_disk == "y" ]] && { DISK_DEVICE="/dev/$DISK_DEVICE"; break; }
    done
    read -p "Dual-boot with Windows? (y/n): " DUAL_BOOT
    while true; do read -p "Enter username: " USERNAME; [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]] && break || print_error "Invalid username."; done
    while true; do read -p "Enter hostname: " HOSTNAME; [[ "$HOSTNAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$ ]] && break || print_error "Invalid hostname."; done
    while true; do read -p "Enter timezone (e.g., America/New_York): " TIMEZONE; [[ -f "/usr/share/zoneinfo/$TIMEZONE" ]] && break || print_warning "Timezone not found."; done
    echo "Desktop: 1) GNOME 2) XFCE 3) KDE 4) i3 5) Minimal"; read -p "Choose (1): " desktop_choice
    case $desktop_choice in 2) INSTALL_DESKTOP="xfce";; 3) INSTALL_DESKTOP="kde";; 4) INSTALL_DESKTOP="i3";; 5) INSTALL_DESKTOP="minimal";; *) INSTALL_DESKTOP="gnome";; esac
    read -p "Install gaming setup? (y/n): " INSTALL_GAMING
    read -p "Install power management? (y/n): " INSTALL_POWER_MGMT
    [[ "$FS_TYPE" == "zfs" ]] && read -p "Enable ZFS snapshots? (y/n): " ENABLE_SNAPSHOTS
    read -p "Proceed with installation? (y/n): " confirm; [[ $confirm != "y" ]] && { print_error "Cancelled."; exit 1; }
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    [[ ! -d /sys/firmware/efi ]] && { print_error "Not in UEFI mode."; exit 1; }
    ! ping -c 1 ubuntu.com &> /dev/null && { print_error "No internet."; exit 1; }
    export DEBIAN_FRONTEND=noninteractive; apt-get update; apt-get install -y debootstrap gdisk zfs-utils
    timedatectl set-ntp true; print_status "Prerequisites OK."
}

partition_disk() { # This function is identical to the Arch script and remains robust
    print_header "Partitioning Disk"
    if [[ $DUAL_BOOT == "y" ]]; then
        ram_size=$(free -m | awk '/^Mem:/{print $2}' ); swap_size=$((ram_size + 1000))
        sgdisk -n 0:0:+${swap_size}M -t 0:8200 -c 0:"Linux Swap" $DISK_DEVICE
        sgdisk -n 0:0:0 -t 0:8300 -c 0:"Linux Root" $DISK_DEVICE
    else
        sgdisk -Z $DISK_DEVICE; sgdisk -o $DISK_DEVICE
        ram_size=$(free -m | awk '/^Mem:/{print $2}' ); swap_size=$((ram_size + 1000))
        sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI System" $DISK_DEVICE
        sgdisk -n 2:0:+${swap_size}M -t 2:8200 -c 2:"Linux Swap" $DISK_DEVICE
        sgdisk -n 3:0:0 -t 3:8300 -c 3:"Linux Root" $DISK_DEVICE
    fi
    partprobe $DISK_DEVICE; sleep 2
    if [[ $DUAL_BOOT == "y" ]]; then
        mapfile -t new_partitions < <(lsblk -prno NAME "$DISK_DEVICE" | tail -n 2); swap_part="${new_partitions[0]}"; root_part="${new_partitions[1]}"
        efi_part=$(lsblk -prno NAME,PARTTYPE "$DISK_DEVICE" | grep -i "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" | awk '{print $1}' )
    else
        mapfile -t all_partitions < <(lsblk -prno NAME "$DISK_DEVICE" | tail -n 3); efi_part="${all_partitions[0]}"; swap_part="${all_partitions[1]}"; root_part="${all_partitions[2]}"
    fi
    print_status "Partitions assigned: EFI=$efi_part, SWAP=$swap_part, ROOT=$root_part"
}

setup_filesystem_and_debootstrap() {
    print_header "Formatting, Mounting and Installing Base System ($FS_TYPE)"
    [[ $DUAL_BOOT != "y" ]] && mkfs.fat -F32 -n "EFI" $efi_part
    mkswap -L "Ubuntu_Swap" $swap_part; swapon $swap_part

    if [[ "$FS_TYPE" == "zfs" ]]; then
        zpool create -f -o ashift=12 -O compression=zstd -O acltype=posixacl -O xattr=sa -O relatime=on -O normalization=formD -O mountpoint=none -O canmount=off -O dnodesize=auto -R /mnt zroot $root_part
        zfs create -o mountpoint=none zroot/ROOT; zfs create -o mountpoint=/ -o canmount=noauto zroot/ROOT/default
        zfs create -o mountpoint=/home zroot/home; zfs create -o mountpoint=/var -o canmount=off zroot/var; zfs create zroot/var/log
        [[ $ENABLE_SNAPSHOTS == "y" ]] && zfs set com.sun:auto-snapshot=true zroot/ROOT/default
    else
        mkfs.ext4 -L "Ubuntu_Root" $root_part; mount $root_part /mnt
    fi

    print_status "Bootstrapping Ubuntu $UBUNTU_CODENAME..."
    debootstrap --arch=amd64 $UBUNTU_CODENAME /mnt http://archive.ubuntu.com/ubuntu/
    
    if [[ "$FS_TYPE" == "zfs" ]]; then zfs mount zroot/ROOT/default; zfs mount -a; fi
    mkdir -p /mnt/boot; mount $efi_part /mnt/boot
    
    echo "UUID=$( blkid -s UUID -o value $efi_part) /boot vfat defaults 0 1" > /mnt/etc/fstab
    echo "UUID=$( blkid -s UUID -o value $swap_part) none swap sw 0 0" >> /mnt/etc/fstab
    [[ "$FS_TYPE" == "ext4" ]] && echo "UUID=$( blkid -s UUID -o value $root_part) / ext4 defaults 0 1" >> /mnt/etc/fstab
}

configure_system_and_install() {
    print_header "Configuring System and Installing Software"
    for dir in dev proc sys; do mount --rbind /$dir /mnt/$dir; done
    echo "nameserver 8.8.8.8" > /mnt/etc/resolv.conf

    chroot /mnt /bin/bash <<CHROOT_EOF
set -e
export DEBIAN_FRONTEND=noninteractive

# Basic system config
echo "$HOSTNAME" > /etc/hostname; echo "127.0.1.1   $HOSTNAME" >> /etc/hosts
apt-get update; apt-get install -y tzdata locales
echo "$TIMEZONE" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=en_US.UTF-8

# Install kernel, bootloader, and essential packages
apt-get install -y linux-generic grub-efi-amd64 network-manager git zsh
[[ "$FS_TYPE" == "zfs" ]] && apt-get install -y zfs-initramfs
[[ "$DUAL_BOOT" == "y" ]] && apt-get install -y os-prober ntfs-3g

# Configure GRUB and verify
[[ "$DUAL_BOOT" == "y" ]] && sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^ vitalibtnom"/& ibt=off/' /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Ubuntu --recheck; update-grub
apt-get install -y efibootmgr; if efibootmgr | grep -qi "Ubuntu"; then echo "Ubuntu boot entry OK"; else echo "Ubuntu boot entry NOT FOUND"; fi
if [[ "$DUAL_BOOT" == "y" ]]; then if grep -qi "Windows" /boot/grub/grub.cfg; then echo "Windows detected"; else echo "Windows NOT detected"; fi; fi

# Create user
apt-get install -y sudo; useradd -m -G sudo -s /bin/zsh "$USERNAME"

# Hardware Fixes
mkdir -p /etc/modprobe.d; echo "options mt7925e disable_aspm=1" > /etc/modprobe.d/mt7925e.conf
cat > /etc/systemd/system/reload-hid_asus.service << EOH
[Unit]
Description=Reload hid_asus module
[Service]
Type=oneshot
ExecStart=/usr/bin/modprobe -r hid_asus; /usr/bin/modprobe hid_asus
[Install]
WantedBy=multi-user.target
EOH
systemctl enable reload-hid_asus.service

# Power Management
if [[ "$INSTALL_POWER_MGMT" == "y" ]]; then
    apt-get install -y software-properties-common
    add-apt-repository ppa:asus-linux/asus-nb-ctrl -y; apt-get update
    apt-get install -y asusctl tlp; systemctl enable tlp; systemctl enable asusd.service
    echo -e "TLP_DEFAULT_MODE=AC\nCPU_SCALING_GOVERNOR_ON_AC=performance\nCPU_SCALING_GOVERNOR_ON_BAT=powersave" >> /etc/tlp.conf
fi

# Desktop & Gaming
apt-get install -y ubuntu-drivers-common
case "$INSTALL_DESKTOP" in
    "gnome") apt-get install -y ubuntu-desktop;; 
    "xfce") apt-get install -y xubuntu-desktop;; 
    "kde") apt-get install -y kubuntu-desktop;; 
    "i3") apt-get install -y i3 i3status xorg lightdm;; 
esac
if [[ "$INSTALL_GAMING" == "y" ]]; then
    dpkg --add-architecture i386; apt-get update
    apt-get install -y steam-installer gamemode mangohud libvulkan1:i386
    add-apt-repository ppa:lutris-team/lutris -y; apt-get update; apt-get install -y lutris
fi

# Snapshots
if [[ "$ENABLE_SNAPSHOTS" == "y" ]]; then apt-get install -y zfs-auto-snapshot; fi

apt-get upgrade -y
CHROOT_EOF
    print_status "System configuration completed."
}

create_post_install_script() {
    local script_path="/mnt/home/$USERNAME/Z13_Quick_Tips.txt"
    cat > "$script_path" << EOF
Welcome to Ubuntu on your ROG Flow Z13!

--- Power Management ---
sudo asusctl profile -P Performance

--- Filesystem ---
# Check filesystem usage
df -h
EOF
    if [[ "$FS_TYPE" == "zfs" ]]; then echo -e "
--- ZFS Snapshots ---
zfs list -t snapshot" >> "$script_path"; fi
    chroot /mnt chown $USERNAME:$USERNAME /home/$USERNAME/Z13_Quick_Tips.txt
}

repair_bootloader_standalone() {
    print_header "EFI Bootloader Repair"
    print_warning "This expects your Linux root at /mnt and EFI partition at /mnt/boot."
    read -p "Are partitions mounted? (y/n): " confirm_mount; [[ $confirm_mount != "y" ]] && exit 1
    for dir in dev proc sys; do mount --rbind /$dir /mnt/$dir;
    chroot /mnt /bin/bash <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update; apt-get install -y grub-efi-amd64 efibootmgr os-prober
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Ubuntu-Repaired --recheck
update-grub; echo "Repair finished."
EOF
}

full_installation() {
    trap "print_error \"Installation failed. Cleaning up...\"; umount -R /mnt 2>/dev/null; if [[ \"$FS_TYPE\" == \"zfs\" ]]; then zpool destroy -f zroot 2>/dev/null; fi; exit 1" ERR
    configure_installation; check_prerequisites; partition_disk; setup_filesystem_and_debootstrap
    configure_system_and_install; create_post_install_script
    print_header "Setting Passwords"; chroot /mnt passwd; chroot /mnt passwd $USERNAME
    print_header "Installation Complete"; umount -R /mnt; print_status "Reboot to enjoy!"
    read -p "Reboot now? (y/n): " r; [[ $r == "y" ]] && reboot
}

main() {
    [[ $EUID -ne 0 ]] && { print_error "Run as root."; exit 1; }
    print_header "ASUS ROG Flow Z13 Ubuntu Setup"
    echo "1) Perform a full installation"; echo "2) Repair EFI bootloader"
    read -p "Choose an option [1-2]: " main_choice
    case $main_choice in 1) full_installation;; 2) repair_bootloader_standalone;; *) exit 1;; esac
}

main "$@"
