# ROG Flow Z13 Linux

This repository contains scripts to assist with installing Linux on the ASUS ROG Flow Z13.

## Prerequisites

Before running the installation scripts, ensure you have the following:

*   **A bootable USB drive** with a live Linux environment (e.g., Arch Linux, Ubuntu).
*   **An internet connection**.
*   **The system booted in UEFI mode**.

### For `Install.sh` (Arch Linux)

This script is intended to be run from an Arch Linux live environment. The following packages are required:

*   `git`
*   `pacman`

### For `Install_Ubuntu25.10.sh` (Ubuntu)

This script is intended to be run from an Ubuntu live environment. The script will attempt to install the following required packages:

*   `debootstrap`
*   `gdisk`
*   `zfs-utils`
*   `software-properties-common`

## Installation

### Ubuntu 25.10

Use the `Install_Ubuntu25.10.sh` script to perform a clean installation of Ubuntu 25.10.

```bash
./Install_Ubuntu25.10.sh
```

### General Installation

The `Install.sh` script provides a more general installation process that may be adapted for other distributions.

```bash
./Install.sh
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
