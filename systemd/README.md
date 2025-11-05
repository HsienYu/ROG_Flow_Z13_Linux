# Systemd Services for ROG Flow Z13

## hid-asus-reload.service

**Purpose**: Fixes touchpad two-finger scrolling on boot

**Problem**: The touchpad interface gets bound to `hid-generic` driver instead of `hid_asus` during boot, preventing multi-touch gestures from working.

**Solution**: Reload the `hid_asus` module after boot to force proper driver binding.

### Installation

```bash
sudo ./scripts/install-touchpad-fix.sh
```

### Manual Installation

```bash
sudo cp systemd/hid-asus-reload.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now hid-asus-reload.service
```

### Check Status

```bash
sudo systemctl status hid-asus-reload
```

### Uninstall

```bash
sudo ./scripts/uninstall-touchpad-fix.sh
```

### How It Works

1. Runs after `multi-user.target` is reached
2. Unloads `hid_asus` module
3. Waits 1 second
4. Reloads `hid_asus` module
5. Touchpad now properly supports gestures and scrolling

### Verification

After service runs, check touchpad capabilities:

```bash
sudo libinput list-devices | grep -A15 "GZ302EA-Keyboard Touchpad"
```

Should show:
- `Capabilities: pointer gesture`
- `Scroll methods: *two-finger edge`
