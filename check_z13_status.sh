#!/bin/bash

# ROG Flow Z13 System Status Check Script
# This script checks the current hardware functionality status

echo "🖥️  ROG Flow Z13 System Status Check"
echo "===================================="
echo ""

# Test brightness control availability
echo "🔆 Brightness Control Status:"
if [ -d /sys/class/backlight ] && [ "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
    echo "  ✅ Backlight devices available:"
    for device in /sys/class/backlight/*; do
        if [ -e "$device" ]; then
            devicename=$(basename "$device")
            current=$(cat "$device/brightness" 2>/dev/null || echo "N/A")
            max=$(cat "$device/max_brightness" 2>/dev/null || echo "N/A")
            echo "    - $devicename: $current/$max ($(( current * 100 / max ))%)"
        fi
    done
    echo "  💡 Brightness keys should work with F7/F8"
else
    echo "  ❌ No backlight devices found"
    echo "  💡 Brightness keys may not work"
fi
echo ""

# Check ASUS WMI modules
echo "🔧 ASUS Hardware Modules:"
asus_modules=$(lsmod | grep -E "(asus|wmi)" || echo "")
if [ -n "$asus_modules" ]; then
    echo "  ✅ ASUS WMI modules loaded:"
    echo "$asus_modules" | sed 's/^/    /'
else
    echo "  ❌ No ASUS WMI modules found"
fi
echo ""

# Check asusctl status
echo "🎮 asusctl Status:"
if command -v asusctl >/dev/null 2>&1; then
    echo "  ⚠️  asusctl is installed"
    if systemctl is-active --quiet asusd 2>/dev/null; then
        echo "  ⚠️  asusd service is running"
        echo "  💡 This may conflict with Ubuntu's native brightness control"
    else
        echo "  ℹ️  asusd service is not running"
    fi
else
    echo "  ✅ asusctl is not installed (Ubuntu native mode)"
fi
echo ""

# Check battery status
echo "🔋 Battery Status:"
for battery in /sys/class/power_supply/BAT*; do
    if [ -e "$battery" ]; then
        capacity=$(cat "$battery/capacity" 2>/dev/null || echo "N/A")
        status=$(cat "$battery/status" 2>/dev/null || echo "Unknown")
        echo "  🔋 Battery: $capacity% ($status)"
    fi
done
if [ ! -e /sys/class/power_supply/BAT* ]; then
    echo "  ❓ Battery information not available"
fi
echo ""

# Check thermal zones
echo "🌡️  Thermal Status:"
thermal_count=0
for thermal in /sys/class/thermal/thermal_zone*; do
    if [ -e "$thermal" ]; then
        temp_raw=$(cat "$thermal/temp" 2>/dev/null)
        if [ -n "$temp_raw" ] && [ "$temp_raw" -gt 0 ]; then
            temp_celsius=$((temp_raw / 1000))
            zone_type=$(cat "$thermal/type" 2>/dev/null || echo "unknown")
            echo "  🌡️  $zone_type: ${temp_celsius}°C"
            thermal_count=$((thermal_count + 1))
        fi
    fi
done
if [ $thermal_count -eq 0 ]; then
    echo "  ❓ Thermal information not available"
fi
echo ""

# Check audio devices
echo "🔊 Audio Status:"
if command -v aplay >/dev/null 2>&1; then
    audio_cards=$(aplay -l 2>/dev/null | grep "card" | wc -l)
    if [ "$audio_cards" -gt 0 ]; then
        echo "  ✅ $audio_cards audio device(s) available"
    else
        echo "  ❌ No audio devices found"
    fi
else
    echo "  ❓ Audio tools not available"
fi
echo ""

# Check keyboard backlight
echo "⌨️  Keyboard Backlight:"
kbd_backlight_found=false
for led in /sys/class/leds/*kbd_backlight*; do
    if [ -e "$led" ]; then
        current=$(cat "$led/brightness" 2>/dev/null || echo "N/A")
        max=$(cat "$led/max_brightness" 2>/dev/null || echo "N/A")
        led_name=$(basename "$led")
        echo "  ✅ $led_name: $current/$max"
        kbd_backlight_found=true
    fi
done
if [ "$kbd_backlight_found" = false ]; then
    echo "  ❌ No keyboard backlight devices found"
fi
echo ""

# Test function keys reminder
echo "🎯 Quick Function Key Test:"
echo "  Try these keys to verify functionality:"
echo "  - F7/F8: Brightness control"
echo "  - F1/F2/F3: Volume control"
echo "  - F5: WiFi toggle"
echo "  - F6: Touchpad toggle"
echo ""

# Overall assessment
echo "📊 Overall Assessment:"
echo "======================"

if [ -d /sys/class/backlight ] && [ "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
    if ! command -v asusctl >/dev/null 2>&1; then
        echo "✅ EXCELLENT: Ubuntu native mode with working brightness control"
        echo "   Recommendation: Keep this configuration for optimal stability"
    else
        echo "⚠️  MIXED: asusctl installed but may conflict with brightness control"
        echo "   Recommendation: Test brightness keys, consider cleanup if broken"
    fi
else
    echo "❌ POOR: No brightness control available"
    echo "   Recommendation: Check hardware or consider installing drivers"
fi

echo ""
echo "For troubleshooting: see UBUNTU_TROUBLESHOOTING.md"
echo "For configuration options: see ROG_FLOW_Z13_GUIDE.md"
