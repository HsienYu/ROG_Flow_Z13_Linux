# macOS Sequoia VM Setup

Docker-OSX running macOS Sequoia on ROG Flow Z13 with Hyprland integration.

## Quick Start

### Launch macOS VM
```bash
# Via Omarchy menu
SUPER + SPACE → Launch → macOS

# Via command
docker-osx-launch
```

### First Time Setup
1. Open Omarchy menu: `SUPER + SPACE`
2. Navigate to **Install → macOS**
3. Wait for image download (~10GB)
4. Launch from menu: **Launch → macOS**
5. Wait for macOS installation (10-20 minutes)

Default credentials:
- Username: `user`
- Password: `alpine`

## Management

### Control Commands
```bash
docker-osx-ctl status      # Check VM status
docker-osx-ctl start       # Start the VM
docker-osx-ctl stop        # Stop the VM gracefully
docker-osx-ctl restart     # Restart the VM
docker-osx-ctl ssh         # SSH into macOS
docker-osx-ctl logs        # View container logs
docker-osx-ctl remove      # Remove container (keeps disk)
docker-osx-ctl reset       # Full reset (removes everything)
```

### SSH Access
```bash
ssh user@localhost -p 50922
# Password: alpine
```

## Configuration

### System Resources
Edit `~/.local/bin/docker-osx-launch`:
- **RAM**: 16GB (current) - adjust `-e RAM=16`
- **CPU Cores**: 16 (current) - adjust `-e SMP=16 -e CORES=16`
- **Display**: 1920x1200 (16:10 aspect ratio)
- **Disk Image**: `~/.local/share/docker-osx/mac_hdd_ng.img`

### Network Ports
- **SSH**: 50922
- **VNC**: 5900

### Environment Variables
```bash
export DOCKER_OSX_IMAGE="sickcodes/docker-osx:sequoia"
export DOCKER_OSX_SSH_PORT=50922
export DOCKER_OSX_VNC_PORT=5900
```

## Hyprland Integration

### Window Rules
Configuration in `~/.config/hypr/docker-osx.conf`:
- Full opacity (no transparency)
- Auto-maximize on spawn
- Focus management
- Optional: Pin to workspace 5 (uncomment in config)

### Keyboard Shortcuts
- `SUPER + SHIFT + D` - Launch lazydocker
- `CTRL + G` - Release mouse from QEMU window

### Reload Configuration
```bash
hyprctl reload
```

## Storage Management

### Disk Image Location
```
~/.local/share/docker-osx/mac_hdd_ng.img
```

### Check Disk Usage
```bash
docker-osx-ctl status
# or
du -h ~/.local/share/docker-osx/mac_hdd_ng.img
```

### Expand Disk Size
Before first boot, edit `docker-osx-launch` and change:
```bash
-e SIZE=200G    # Default is auto-sized
```

## Troubleshooting

### Mouse Stuck
Press `CTRL + G` to release mouse from QEMU window

### Display Issues
Ensure X11 forwarding is configured:
```bash
echo $DISPLAY
xhost +local:docker
```

### KVM Permission Denied
```bash
sudo usermod -aG kvm $USER
# Log out and back in
```

### Docker Not Running
```bash
sudo systemctl status docker
sudo systemctl start docker
sudo systemctl enable docker
```

### Container Won't Start
```bash
# Check logs
docker logs macos-container

# Remove and recreate
docker-osx-ctl remove
docker-osx-launch
```

### Performance Issues
Increase resources in `~/.local/bin/docker-osx-launch`:
```bash
-e RAM=16        # Increase to 16GB
-e SMP=8         # Increase to 8 cores
-e CORES=8
```

### Audio Not Working
Ensure `/dev/snd` is accessible:
```bash
ls -la /dev/snd
groups | grep audio
```

## Advanced Features

### Headless Mode (No Display)
Remove from launch script:
```bash
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e "DISPLAY=${DISPLAY:-:0.0}" \
```

### VNC Access
Connect to `localhost:5900` with any VNC client

### Custom QEMU Arguments
Add to launch script:
```bash
-e EXTRA='-usb -device usb-host,hostbus=1,hostaddr=8'
```

### USB Passthrough
```bash
# List USB devices
lsusb

# Add to launch script
-e EXTRA='-usb -device usb-host,vendorid=0x1234,productid=0x5678'
```

### Shared Folders
Add volume mounts to launch script:
```bash
-v /path/on/host:/path/in/macos
```

## Omarchy Menu Integration

### Install macOS
1. `SUPER + SPACE` (Open Omarchy menu)
2. Navigate to **Install → macOS**
3. Image will download automatically

### Remove macOS
1. `SUPER + SPACE`
2. Navigate to **Remove → macOS**
3. Confirm removal (removes container + disk image)

## Specifications

### Host System
- **Device**: ASUS ROG Flow Z13
- **OS**: Arch Linux
- **Display Server**: Wayland (Hyprland)
- **Window Manager**: Hyprland with Omarchy

### Guest System
- **OS**: macOS Sequoia
- **Engine**: Docker + QEMU/KVM
- **Image**: sickcodes/docker-osx:sequoia
- **Virtualization**: KVM acceleration

### Default Resources
- **RAM**: 16GB
- **CPU**: 16 cores
- **Disk**: Auto-sized (expandable)
- **Audio**: ALSA
- **Display**: X11 forwarding (1920x1200, 16:10)

## Useful Links

- [Docker-OSX GitHub](https://github.com/sickcodes/Docker-OSX)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Omarchy Documentation](https://learn.omacom.io/)

## Notes

- First boot takes 10-20 minutes for macOS installation
- Subsequent boots are much faster (~1-2 minutes)
- Mouse can be released with `CTRL + G`
- Enable SSH in macOS Settings → Sharing for remote access
- Container persists across reboots
- Disk image is stored separately and reused

## Scripts Location

All scripts are in `~/.local/bin/`:
- `docker-osx-launch` - Main launcher
- `docker-osx-ctl` - Control utility
