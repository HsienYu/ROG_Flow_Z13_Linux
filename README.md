# ROG Flow Z13 Linux

This repository contains scripts to install and optimize Linux on the ASUS ROG Flow Z13 (2025) with AMD Ryzen Strix Halo APU.

## 🚀 Quick Start

**Recommended for Machine Learning Development:**
1. Install Ubuntu 25.10 using `Install_Ubuntu25.10.sh`
2. Set up ML environment using `Setup_ML_Development.sh`

## Prerequisites

Before running the installation scripts, ensure you have the following:

*   **A bootable USB drive** with a live Linux environment (e.g., Arch Linux, Ubuntu).
*   **An internet connection**.
*   **The system booted in UEFI mode**.
*   **At least 32GB available disk space**.

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

## 🤖 Machine Learning Development Setup

After installing Ubuntu, use the ML development script to set up a complete machine learning environment:

```bash
sudo ./Setup_ML_Development.sh
```

**Features:**
- Python ML stack (NumPy, Pandas, Scikit-learn, Matplotlib)
- Deep Learning frameworks (PyTorch with ROCm, TensorFlow, Transformers)
- Jupyter Lab environment with extensions
- Visual Studio Code with ML extensions
- ROCm for AMD GPU acceleration (optimized for Z13's Radeon graphics)
- Docker support for containerized ML workflows
- R and RStudio (optional)
- Z13-specific performance optimizations

### Arch Linux Installation

The `Install.sh` script provides Arch Linux installation with Z13 optimizations:

```bash
./Install.sh
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
