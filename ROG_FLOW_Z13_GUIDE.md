# ROG Flow Z13 Ubuntu Configuration Guide

## Current Status: Ubuntu Native Mode ✅

Your ROG Flow Z13 is currently running with **Ubuntu's native hardware support**, which provides excellent stability and functionality for most daily use cases.

## What's Working Right Now

### ✅ **Fully Functional (Ubuntu Native)**
- **Brightness Control**: F7/F8 keys work perfectly
- **Volume Control**: F1/F2/F3 keys work
- **System Sleep/Wake**: Stable power management
- **Battery Optimization**: Ubuntu's power management
- **WiFi/Bluetooth**: Full functionality
- **USB-C/Thunderbolt**: Works out of the box
- **Audio**: Speakers and headphones working
- **Touchpad**: Full gesture support
- **Keyboard**: All keys functional

### ⚠️ **Limited/Not Available (Without asusctl)**
- **Per-Key RGB Lighting**: Only basic backlight control
- **AniMatrix Display**: Not functional
- **Advanced Fan Curves**: Basic thermal management only
- **GPU MUX Switching**: Limited control
- **Custom Power Profiles**: Ubuntu defaults only
- **ASUS-specific RGB Effects**: Not available

## Your Options

### Option 1: Keep Ubuntu Native (Recommended for Daily Use) ⭐

**Pros:**
- ✅ **Brightness keys work perfectly**
- ✅ **Excellent stability and battery life**
- ✅ **No service conflicts or crashes**
- ✅ **Automatic Ubuntu updates**
- ✅ **Minimal resource usage**
- ✅ **No maintenance required**

**Cons:**
- ❌ No advanced RGB lighting
- ❌ No AniMatrix control
- ❌ Limited fan curve control

**Best for:** Students, professionals, daily productivity work

### Option 2: Reinstall asusctl (For Advanced Features) 🎮

**Pros:**
- ✅ **Full RGB lighting control**
- ✅ **AniMatrix display functionality**
- ✅ **Advanced fan curves**
- ✅ **GPU MUX switching**
- ✅ **Custom power profiles**

**Cons:**
- ❌ **F7/F8 brightness keys will stop working**
- ❌ Potential system conflicts
- ❌ Higher resource usage
- ❌ More complex troubleshooting

**Best for:** Gamers, enthusiasts, RGB lighting enthusiasts

## How to Reinstall asusctl (If You Really Need It)

⚠️ **WARNING**: This will likely break your brightness keys again!

```bash
# 1. Install dependencies
sudo apt install libclang-dev libudev-dev libfontconfig-dev build-essential cmake libxkbcommon-dev

# 2. Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# 3. Build and install asusctl
cd asusctl
make
sudo make install

# 4. Enable the service
sudo systemctl enable asusd
sudo systemctl start asusd

# 5. Reboot
sudo reboot
```

### After Reinstalling asusctl:

**You will need to use alternative brightness control:**
```bash
# Using brightnessctl (install if needed: sudo apt install brightnessctl)
brightnessctl set 50%    # Set to 50%
brightnessctl set +10%   # Increase by 10%
brightnessctl set -10%   # Decrease by 10%

# Or create keyboard shortcuts in Ubuntu Settings
# Settings > Keyboard > Keyboard Shortcuts > Custom Shortcuts
```

## Testing Current Hardware Support

Let's check what's currently working with Ubuntu native:

```bash
# Test brightness control
echo "Press F7/F8 to test brightness control"

# Check backlight devices
ls /sys/class/backlight/

# Check ASUS hardware modules
lsmod | grep -E "(asus|wmi)"

# Check battery status
cat /sys/class/power_supply/BAT*/capacity

# Test audio
speaker-test -t sine -f 1000 -l 1

# Check thermal status
cat /sys/class/thermal/thermal_zone*/temp
```

## Hybrid Approach: Selective asusctl Features

If you want some asusctl features without breaking brightness control, you could try:

### 1. **asusctl for RGB only** (experimental):
```bash
# Build with minimal features
cd asusctl
cargo build --no-default-features --features "rog-aura"
```

### 2. **External RGB control tools**:
```bash
# Install OpenRGB (alternative RGB control)
sudo apt install openrgb
```

## Current System Health Check

Run this command to check your current system status:

```bash
./check_z13_status.sh
```

## Recommendations

### For Most Users: **Stick with Ubuntu Native** ⭐
Your current setup is optimal for:
- **Students and professionals** - Stable, reliable, long battery life
- **General productivity** - All essential functions work perfectly
- **Content consumption** - Great for browsing, media, documents

### Consider asusctl Only If:
- You **absolutely need** RGB lighting customization
- AniMatrix display control is **essential** for your use case
- You're willing to **sacrifice brightness key functionality**
- You don't mind **troubleshooting potential conflicts**

## Emergency Recovery

If you install asusctl and want to go back to Ubuntu native:
```bash
./ubuntu_cleanup_asusctl.sh
```

---

**Bottom Line**: Your ROG Flow Z13 is working excellently with Ubuntu native support. Unless you specifically need RGB control or AniMatrix, there's no compelling reason to install asusctl and risk breaking the stable brightness control.
