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

## ⚠️ IMPORTANT: Choose Your Configuration

**Check your current system status first:**

```bash
./check_z13_status.sh
```

**Ubuntu 24.04+ provides excellent native support for ROG Flow Z13:**
- ✅ F7/F8 brightness control works perfectly
- ✅ Volume controls (F1/F2/F3) work
- ✅ Stable power management
- ✅ Better battery life
- ✅ No service conflicts

**📚 Configuration Options:**
- **[UBUNTU_TROUBLESHOOTING.md](UBUNTU_TROUBLESHOOTING.md)** - Troubleshooting guide
- **[MINIMAL_ASUSCTL_GUIDE.md](MINIMAL_ASUSCTL_GUIDE.md)** - **⭐ RECOMMENDED: Best of both worlds**
- **[ROG_FLOW_Z13_GUIDE.md](ROG_FLOW_Z13_GUIDE.md)** - Complete configuration options

## 🎮 ASUSCTL Installation Options

### Option 1: Minimal asusctl (Recommended) ⭐

**Best of both worlds - Advanced features + Working brightness keys!**

```bash
# Install minimal asusctl (keeps F7/F8 working)
./build_minimal_asusctl.sh
```

**What you get:**
- ✅ **Power profiles** (Performance/Balanced/Quiet)
- ✅ **Keyboard backlight control**
- ✅ **Fan curve management** 
- ✅ **Battery charge limiting**
- ✅ **F7/F8 brightness keys still work**

**See [MINIMAL_ASUSCTL_GUIDE.md](MINIMAL_ASUSCTL_GUIDE.md) for complete details.**

### Option 2: Full asusctl (Advanced Users)

**⚠️ WARNING**: This WILL break Ubuntu's native brightness control (F7/F8 keys).

**Only install if you need:**
- RGB lighting customization
- AniMatrix display control
- Don't mind broken brightness keys

```bash
./Install_ASUSCTL.sh
```

**Recovery if needed:**
```bash
./ubuntu_cleanup_asusctl.sh
```

**Features:**
- **Power Profile Management**: Performance/Balanced/Quiet modes with TDP control
- **Modern GNOME GUI**: Native GTK4/Adwaita control center
- **Keyboard Backlight Control**: Adjustable brightness levels
- **Battery Charge Control**: Set charging limits for battery longevity
- **Fan Curve Management**: Custom cooling profiles
- **Desktop Integration**: Appears in applications menu, toast notifications

**Quick Commands:**
```bash
# Launch modern GUI
rog-control-center-gnome

# Switch performance modes (no sudo needed!)
asusctl profile -P Performance  # Gaming/ML training
asusctl profile -P Balanced     # General use
asusctl profile -P Quiet        # Battery saving

# Control keyboard backlight
asusctl -k low/med/high/off

# Set battery charge limit
asusctl -c 80  # Recommended for longevity
```

📖 **Complete Documentation**: See [ASUSCTL_README.md](ASUSCTL_README.md) for detailed usage guide.

### Arch Linux Installation

The `Install.sh` script provides Arch Linux installation with Z13 optimizations:

```bash
./Install.sh
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
