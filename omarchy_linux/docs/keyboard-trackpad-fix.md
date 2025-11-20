# Keyboard/Trackpad Fix for ROG Flow Z13

## Problem Description

The ASUS ROG Flow Z13 detachable keyboard has two main issues under Linux:

1. **Keyboard Input Issue**: Keyboard keys don't produce input in Wayland compositors
2. **Touchpad Scrolling Issue**: Two-finger scrolling doesn't work after boot

These affect Wayland compositors (Hyprland, GNOME Wayland, Sway) more severely than X11.

## Symptoms

### Keyboard Issue
- Trackpad works and responds to clicks/gestures
- Keyboard keys don't produce any input
- `sudo evtest /dev/input/eventX` shows keyboard events are generated at hardware level
- Keyboard backlight works
- External USB keyboards work fine

### Touchpad Scrolling Issue
- Touchpad clicks work
- Single-finger movement works
- Two-finger scrolling doesn't work
- After running `sudo modprobe -r hid_asus && sudo modprobe hid_asus`, scrolling works

## Root Causes

### 1. ASUS HID Driver Probe Failure
```bash
sudo dmesg | grep asus
# Shows: "asus 0003:0B05:1A30.000B: Asus input not registered"
# Shows: "probe with driver asus failed with error -12"
```

Error -12 is `ENOMEM`, indicating the driver couldn't allocate resources for some HID interfaces.

### 2. Device Misclassification
```bash
sudo libinput list-devices | grep -A15 "GZ302EA-Keyboard"
# Shows: "kernel bug: device failed touchpad sanity checks"
```

libinput sees keyboard interfaces but thinks they might be touchpads, causing confusion.

### 3. Compositor Not Grabbing Device
Even when events reach `/dev/input/eventX`, the Wayland compositor may not grab the device for input processing.

## Solution: Automated Fix

### Keyboard Input Fix
```bash
cd ~/GitRepos/ROG_Flow_Z13_Linux
sudo ./scripts/fix-keyboard-input.sh
sudo systemctl restart sddm  # or your display manager
```

### Touchpad Scrolling Fix
```bash
cd ~/GitRepos/ROG_Flow_Z13_Linux
sudo ./scripts/install-touchpad-fix.sh
```

This installs a systemd service that automatically reloads the `hid_asus` module on boot, ensuring two-finger scrolling works every time.

### What the Fix Does

1. **Installs keyd** - A keyboard remapping daemon that creates a virtual keyboard device
   - Acts as a reliable intermediary between hardware and compositor
   - Compositor always grabs the virtual keyboard successfully

2. **Adds udev rules** - Forces correct device classification
   ```
   /etc/udev/rules.d/99-rog-flow-z13-input.rules
   ```
   - Marks ASUS keyboard devices with `ID_INPUT_KEYBOARD=1`
   - Prevents misclassification as mouse/touchpad

3. **Ensures hid_asus is loaded** - Don't blacklist it
   - Some devices need the ASUS-specific driver
   - Virtual keyboard handles issues transparently

## Manual Fix Steps

If you want to understand or customize the fix:

### Step 1: Install keyd
```bash
sudo pacman -S keyd
```

### Step 2: Configure keyd
Create `/etc/keyd/default.conf`:
```ini
[ids]
*

[main]
# No remaps by default - just creates virtual keyboard
```

### Step 3: Enable keyd
```bash
sudo systemctl enable --now keyd
```

### Step 4: Add udev rule
Create `/etc/udev/rules.d/99-rog-flow-z13-input.rules`:
```
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="ASUSTeK Computer Inc. GZ302EA-Keyboard", ENV{ID_INPUT_KEYBOARD}="1", ENV{ID_INPUT_MOUSE}=""
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Asus Keyboard", ENV{ID_INPUT_KEYBOARD}="1", ENV{ID_INPUT_MOUSE}=""
```

### Step 5: Reload udev
```bash
sudo udevadm control --reload
sudo udevadm trigger -s input
```

### Step 6: Restart display manager
```bash
sudo systemctl restart sddm  # or gdm, lightdm, etc.
```

## Verification

### Check keyd is running
```bash
systemctl status keyd
```

### Check virtual keyboard exists
```bash
sudo libinput list-devices | grep "keyd virtual keyboard"
```

Should show:
```
Device:           keyd virtual keyboard
Kernel:           /dev/input/event24
Capabilities:     keyboard
```

### Test keyboard events
```bash
sudo evtest /dev/input/by-path/*kbd
# Press keys - should see events
```

### Test in compositor
Open a text editor and type - should work!

## Hyprland-Specific Tuning

If trackpad feels laggy after the fix, add to `~/.config/hypr/input.conf`:

```
input {
  kb_options = compose:caps
  
  touchpad {
    natural_scroll = true
    tap-to-click = true
    disable_while_typing = false
    scroll_factor = 0.4
  }
}
```

Then reload: `hyprctl reload`

## Troubleshooting

### Touchpad scrolling doesn't work

**First, try manual reload:**
```bash
sudo modprobe -r hid_asus && sudo modprobe hid_asus
```

If that works, install the automatic fix:
```bash
sudo ./scripts/install-touchpad-fix.sh
```

**Check if service is running:**
```bash
sudo systemctl status hid-asus-reload
```

**Verify touchpad is properly detected:**
```bash
sudo libinput list-devices | grep -A15 "GZ302EA-Keyboard Touchpad"
```

Should show:
- Capabilities: `pointer gesture`
- Scroll methods: `*two-finger edge`

### Keyboard still doesn't work after fix

**Check tablet mode:**
- Fold/unfold the screen hinge
- Some ASUS laptops disable keyboard in tablet mode
- The mode switch can stick

**Check keyd status:**
```bash
sudo journalctl -u keyd -n 50
```

**Re-apply udev rules:**
```bash
sudo udevadm trigger -s input
```

### Keyboard works but some keys don't

**Check keyd config:**
```bash
cat /etc/keyd/default.conf
```
Make sure you're not accidentally remapping keys.

### Want to customize key mappings

Edit `/etc/keyd/default.conf`:
```ini
[ids]
*

[main]
# Remap capslock to control
capslock = leftcontrol

# Swap esc and capslock
esc = capslock
```

Then: `sudo systemctl restart keyd`

See [keyd documentation](https://github.com/rvaiya/keyd) for full syntax.

## Revert Changes

### Remove keyboard fix
```bash
sudo ./scripts/revert-keyboard-fix.sh
```

Or manually:
```bash
sudo systemctl disable --now keyd
sudo rm /etc/udev/rules.d/99-rog-flow-z13-input.rules
sudo udevadm control --reload
sudo systemctl restart sddm
```

### Remove touchpad scrolling fix
```bash
sudo ./scripts/uninstall-touchpad-fix.sh
```

Or manually:
```bash
sudo systemctl disable --now hid-asus-reload
sudo rm /etc/systemd/system/hid-asus-reload.service
sudo systemctl daemon-reload
```

## Alternative Approaches (Not Recommended)

### Blacklisting hid_asus
Some guides suggest blacklisting `hid_asus`. **Don't do this** - it breaks other features:
- Keyboard backlight control
- Function keys (brightness, volume, etc.)
- N-Key rollover

### Using generic HID driver only
The generic `hid-generic` driver works but loses ASUS-specific features. The keyd solution is better.

## Related Issues

- [Arch Wiki - ASUS Laptops](https://wiki.archlinux.org/title/ASUS_laptops)
- [libinput issue #643](https://gitlab.freedesktop.org/libinput/libinput/-/issues/643)
- [hid_asus driver source](https://github.com/torvalds/linux/blob/master/drivers/hid/hid-asus.c)

## Technical Details

The ROG Flow Z13 detachable keyboard is actually a USB device with multiple HID interfaces:
- Interface 0: Keyboard (main keys)
- Interface 1: Consumer control (media keys)
- Interface 2: Keyboard (N-Key rollover)
- Interface 3: Touchpad
- Interface 4: Wireless radio control

### Keyboard Issue
The hid_asus driver fails to probe interfaces 1 and 4 with error -12 (ENOMEM), but interfaces 0, 2, and 3 work. The keyd solution bypasses this by creating a reliable virtual keyboard that always works with compositors.

### Touchpad Scrolling Issue
On boot, interface 3 (touchpad) gets claimed by the generic `hid-generic` driver before `hid_asus` can bind to it. The generic driver doesn't properly support multi-touch gestures. Reloading the `hid_asus` module forces proper driver binding:

```bash
# Unbind hid-generic, bind hid_asus
sudo modprobe -r hid_asus && sudo modprobe hid_asus
```

The systemd service automates this on every boot.
