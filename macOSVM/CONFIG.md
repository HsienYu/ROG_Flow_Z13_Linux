# macOS VM Configuration

## Current Configuration

### System Resources
- **Image**: `sickcodes/docker-osx:latest` (with SHORTNAME=sequoia)
- **Container Name**: `macos-container`
- **RAM**: 16GB
- **CPU Cores**: 16 (SMP=16, CORES=16)
- **Audio Driver**: ALSA
- **Display**: X11 forwarding (1920x1200, 16:10)

### Network Configuration
- **SSH Port**: 50922 (host) → 10022 (guest)
- **VNC Port**: 5900 (host) → 5900 (guest)

### Storage
- **Disk Image**: `~/.local/share/docker-osx/mac_hdd_ng.img`
- **Size**: Auto (expandable)

### Hyprland Window Rules
```conf
# Full opacity
windowrule = opacity 1 1, class:qemu

# Auto-maximize
windowrulev2 = maximize, class:qemu, title:.*Docker-OSX.*

# Keep focus
windowrulev2 = stayfocused, class:qemu, title:.*OSX.*
```

## Customization Options

### Current Performance Settings

**Current Configuration:**
```bash
# Edit ~/.local/bin/docker-osx-launch
-e RAM=16           # 16GB RAM
-e SMP=16           # 16 CPU cores
-e CORES=16
-e WIDTH=1920       # 16:10 aspect ratio
-e HEIGHT=1200
```

**To adjust:**
```bash
# Reduce if needed
-e RAM=8            # 8GB RAM
-e SMP=8            # 8 CPU cores
-e CORES=8
```

### Pin to Workspace

**Uncomment in ~/.config/hypr/docker-osx.conf:**
```conf
windowrule = workspace 5, class:qemu
```

### Change Ports

**Set environment variables:**
```bash
export DOCKER_OSX_SSH_PORT=50922
export DOCKER_OSX_VNC_PORT=5900
```

### Custom Disk Size

**Before first boot, edit launch script:**
```bash
-e SIZE=200G
```

### Headless Mode

**Remove from launch script:**
```bash
# Remove these lines:
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e "DISPLAY=${DISPLAY:-:0.0}" \
```

### USB Passthrough

**Add to launch script:**
```bash
-e EXTRA='-usb -device usb-host,vendorid=0xVENDOR,productid=0xPRODUCT'
```

**Find USB devices:**
```bash
lsusb
```

### Shared Folders

**Add volume mount:**
```bash
-v /home/chenghsienyu/Shared:/Users/user/Shared
```

### Different macOS Version

**Change image:**
```bash
export DOCKER_OSX_IMAGE="sickcodes/docker-osx:big-sur"
# or
export DOCKER_OSX_IMAGE="sickcodes/docker-osx:monterey"
# or
export DOCKER_OSX_IMAGE="sickcodes/docker-osx:ventura"
# or
export DOCKER_OSX_IMAGE="sickcodes/docker-osx:sonoma"
```

## Docker Run Arguments Reference

### Essential
```bash
--device /dev/kvm           # KVM acceleration
--device /dev/snd           # Audio device
-e "DISPLAY=${DISPLAY}"     # X11 display
-v /tmp/.X11-unix:/...      # X11 socket
```

### Resources
```bash
-e RAM=8                    # RAM in GB
-e SMP=4                    # CPU threads
-e CORES=4                  # CPU cores
-e SIZE=200G                # Disk size
```

### Network
```bash
-p 50922:10022              # SSH port
-p 5900:5900                # VNC port
```

### Boot Options
```bash
-e NOPICKER=true            # Skip boot menu
-e GENERATE_UNIQUE=true     # Unique serial
-e GENERATE_SPECIFIC=false  # Specific serial
```

### Audio
```bash
-e AUDIO_DRIVER=alsa        # ALSA audio
# or
-e AUDIO_DRIVER=pa          # PulseAudio
```

### Display
```bash
-e WIDTH=1920               # Resolution width (16:10)
-e HEIGHT=1200              # Resolution height (16:10)
```

### Custom QEMU Args
```bash
-e EXTRA='-usb ...'         # Extra QEMU args
```

## Files to Edit

### Main Launcher
```
~/.local/bin/docker-osx-launch
```

### Hyprland Window Rules
```
~/.config/hypr/docker-osx.conf
```

### Hyprland Keybindings
```
~/.config/hypr/bindings.conf
```

### Omarchy Menu
```
~/.local/share/omarchy/bin/omarchy-menu
```

## Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc

# Docker image to use
export DOCKER_OSX_IMAGE="sickcodes/docker-osx:sequoia"

# SSH port
export DOCKER_OSX_SSH_PORT=50922

# VNC port
export DOCKER_OSX_VNC_PORT=5900
```

## Tips

1. **First boot is slow** - Takes 10-20 minutes
2. **Subsequent boots are fast** - 1-2 minutes
3. **Enable SSH in macOS** - Settings → Sharing
4. **Take snapshots** - Use `docker commit` for backups
5. **Use VNC for headless** - Access via `localhost:5900`
