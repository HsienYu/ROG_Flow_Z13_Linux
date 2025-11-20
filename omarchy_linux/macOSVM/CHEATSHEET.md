# macOS VM Quick Reference

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `SUPER + SPACE` | Omarchy menu |
| `SUPER + SHIFT + D` | Launch lazydocker |
| `CTRL + G` | Release mouse from VM |

## Common Commands

```bash
# Launch VM
docker-osx-launch

# Control VM
docker-osx-ctl start
docker-osx-ctl stop
docker-osx-ctl restart
docker-osx-ctl status

# Access VM
docker-osx-ctl ssh
ssh user@localhost -p 50922

# View logs
docker-osx-ctl logs

# Cleanup
docker-osx-ctl remove    # Keep disk
docker-osx-ctl reset     # Remove all
```

## Default Credentials

- **Username**: `user`
- **Password**: `alpine`

## Network Ports

- **SSH**: `50922`
- **VNC**: `5900`

## File Locations

```bash
# VM disk image
~/.local/share/docker-osx/mac_hdd_ng.img

# Launch script
~/.local/bin/docker-osx-launch

# Control script
~/.local/bin/docker-osx-ctl

# Hyprland config
~/.config/hypr/docker-osx.conf
~/.config/hypr/bindings.conf
```

## Quick Setup

1. **Install image**:
   ```bash
   docker pull sickcodes/docker-osx:latest
   ```

2. **Launch**:
   ```bash
   docker-osx-launch
   ```

3. **Wait 10-20 minutes** for first boot

4. **SSH access**:
   ```bash
   ssh user@localhost -p 50922
   ```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Mouse stuck | Press `CTRL + G` |
| Display not showing | `xhost +local:docker` |
| KVM permission | `sudo usermod -aG kvm $USER` |
| Docker not running | `sudo systemctl start docker` |
| Poor performance | Increase RAM/CPU in script |

## Resource Tuning

Edit `~/.local/bin/docker-osx-launch`:

```bash
# Current settings
-e RAM=16           # 16GB RAM
-e SMP=16           # 16 CPU cores
-e CORES=16
-e WIDTH=1920       # 16:10 resolution
-e HEIGHT=1200

# Larger disk
-e SIZE=200G
```

## Omarchy Menu

- **Install**: `Omarchy Menu → Install → macOS`
- **Remove**: `Omarchy Menu → Remove → macOS`
