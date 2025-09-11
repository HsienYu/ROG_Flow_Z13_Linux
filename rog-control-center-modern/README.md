# 🎮 Modern ROG Control Center

A complete replacement for the problematic Slint-based ROG Control Center with a reliable, modern GTK4/Adwaita interface.

## ✨ Features

### 🎯 **Comprehensive Power Management**
- **ASUSCTL Power Profiles**: Hardware-level control (Performance/Balanced/Quiet) with TDP management
- **GNOME Power Profiles**: System-level integration (Power Saver/Balanced/Performance)
- **Dual Profile System**: Both work together for optimal power management

### ⌨️ **Hardware Controls**
- **Keyboard Backlight**: Full control (Off/Low/Med/High)
- **Battery Management**: Charge limit control with health optimization
- **Quick Presets**: Common charge limits (80%, 85%, 90%, 100%)

### 🔆 **Native Ubuntu Integration**
- **F7/F8 Brightness**: Works perfectly with Ubuntu native drivers
- **System Theme**: Matches GNOME Adwaita theme automatically
- **Toast Notifications**: Real-time feedback for all operations

### 🎨 **Modern Design**
- **GTK4 + Adwaita**: Native GNOME design language
- **Responsive Layout**: Adapts to different window sizes
- **Background Operations**: UI never freezes during commands
- **Real-time Status**: Live updates of all hardware states

## 🚀 Installation

### Quick Install
```bash
cd rog-control-center-modern
chmod +x install.sh
./install.sh
```

### Manual Dependencies (if needed)
```bash
sudo apt install python3-gi python3-gi-cairo gir1.2-gtk-4.0 gir1.2-adw-1 libadwaita-1-0 power-profiles-daemon
```

## 📱 Usage

### Launch Options
1. **Applications Menu**: Search for "ROG Control Center"
2. **Terminal**: `rog-control-center`
3. **Direct Python**: `python3 /usr/share/rog-control-center-modern/rog_control_center.py`

### Power Profile Management

#### ASUSCTL Profiles (Hardware TDP Control)
- **Performance**: ~120W TDP - Gaming, rendering, ML training
- **Balanced**: ~70W TDP - General computing with good battery life  
- **Quiet**: ~45W TDP - Maximum battery life, minimal fan noise

#### GNOME Profiles (CPU Governor Control)
- **Performance**: Maximum CPU performance
- **Balanced**: Automatic scaling based on load
- **Power Saver**: Battery-optimized CPU behavior

#### How They Work Together
Both profile systems complement each other:
- **ASUSCTL** controls hardware power limits and TDP
- **GNOME** controls CPU frequency scaling and governor
- Use both together for optimal performance tuning

### Battery Health Optimization
- **Recommended**: Set charge limit to 80-85% for daily use
- **Travel**: Use 100% when you need maximum battery life
- **Storage**: Use 80% for long-term storage

## 🔧 Technical Details

### Architecture
- **Language**: Python 3.8+
- **UI Framework**: GTK4 + libadwaita
- **Threading**: Background operations prevent UI freezing
- **Integration**: Native GNOME desktop integration

### Interface Methods
```python
AsusctlInterface.get_current_profile()      # Get active ASUSCTL profile
AsusctlInterface.set_profile(profile)       # Change ASUSCTL profile
AsusctlInterface.get_keyboard_brightness()  # Get keyboard backlight
AsusctlInterface.set_keyboard_brightness()  # Set keyboard backlight
AsusctlInterface.get_charge_limit()         # Get battery charge limit
AsusctlInterface.set_charge_limit()         # Set battery charge limit
AsusctlInterface.get_gnome_power_profile()  # Get GNOME power profile
AsusctlInterface.set_gnome_power_profile()  # Set GNOME power profile
```

### Security
- **Passwordless sudo**: Only for `/usr/bin/asusctl` commands
- **Minimal privileges**: No unnecessary system access
- **Command validation**: All inputs sanitized

## 🆚 Comparison with Original

| Feature | Original (Slint) | Modern (GTK4) |
|---------|------------------|---------------|
| **Stability** | ❌ Frequent crashes | ✅ Rock solid |
| **UI Rendering** | ❌ Missing buttons/widgets | ✅ Perfect rendering |
| **Power Management** | ✅ Basic profiles | ✅ Dual profile system |
| **Integration** | ❌ Poor Ubuntu integration | ✅ Native GNOME |
| **Startup Time** | ❌ Slow (runtime issues) | ✅ Fast |
| **Memory Usage** | ❌ High | ✅ Low |
| **Maintenance** | ❌ Complex Rust build | ✅ Simple Python |
| **User Experience** | ❌ Freezes, crashes | ✅ Smooth, responsive |
| **Theme Support** | ❌ Custom theming | ✅ System theme |

## 🛠️ Troubleshooting

### Application Won't Start
```bash
# Check dependencies
python3 -c "import gi; gi.require_version('Adw', '1')"

# Check DISPLAY environment  
echo $DISPLAY

# Run with debug
python3 /usr/share/rog-control-center-modern/rog_control_center.py
```

### sudo Password Prompts
```bash
# Test sudo configuration
sudo -n asusctl --version

# If fails, reinstall to fix sudo config
./install.sh
```

### Features Not Working
```bash
# Check asusctl installation
asusctl -s

# Check service status  
sudo systemctl status asusd

# Check power profiles daemon
systemctl status power-profiles-daemon
```

## 💡 Usage Tips

### Daily Usage
1. **Set charge limit to 80-85%** for battery longevity
2. **Use Balanced profiles** for general computing
3. **Switch to Performance** only when needed for intensive tasks
4. **Use F7/F8** for screen brightness (Ubuntu native)

### Gaming Setup
1. **ASUSCTL**: Performance profile
2. **GNOME**: Performance profile  
3. **Charge limit**: 100% for maximum battery life
4. **Keyboard backlight**: High for better visibility

### Battery Optimization
1. **ASUSCTL**: Quiet profile
2. **GNOME**: Power Saver profile
3. **Charge limit**: 80% for daily use
4. **Keyboard backlight**: Low or Off

## 🎯 Why This Replacement?

The original Slint-based ROG Control Center had several critical issues:
- **Rendering Problems**: Missing buttons and UI elements on Ubuntu 24.04
- **Runtime Crashes**: Unstable Slint UI framework 
- **Poor Integration**: Didn't follow GNOME design guidelines
- **Complex Maintenance**: Rust build system complications

This modern replacement provides:
- **100% Reliability**: No crashes, no missing UI elements
- **Native GNOME Experience**: Perfect Ubuntu integration
- **Enhanced Features**: Dual power profile management  
- **Easy Maintenance**: Simple Python codebase
- **Better Performance**: Faster startup, lower memory usage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test on ROG Flow Z13 with Ubuntu 24.04
4. Submit pull request

## 📄 License

Same license as the main ROG_Flow_Z13_Linux repository.

---

**🎉 Enjoy your reliable, modern ROG Control Center! 🎮**
