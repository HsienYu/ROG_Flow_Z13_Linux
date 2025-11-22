# ROG Flow Z13 Suspend/Resume Issues

## Problem
Ubuntu 25.10 sometimes fails to wake up from suspend when the lid is closed.

## Root Cause
The ROG Flow Z13 uses **s2idle** (Modern Standby) instead of traditional S3 deep sleep. This is common on modern AMD Ryzen laptops and can cause wake-up issues.

Additionally, the ACPI reports: `The lid device is not compliant to SW_LID`

## Current System Info
- Sleep mode: `s2idle` (only mode available)
- Lid switch: Not fully compliant with ACPI standards
- Multiple USB controllers enabled for wake

## Potential Fixes

### Option 1: Fix Black Screen on Wake (RECOMMENDED)
If the system suspends but displays a black screen when waking up, this is an AMD GPU resume issue.

**Automated fix:**
```bash
./install-display-wake-fix.sh
```

This will:
1. Install a systemd service that restarts the display after resume
2. Add kernel parameter `amdgpu.dc=0` to disable Display Core
3. Backup your GRUB config

**Manual alternatives if automated fix doesn't work:**

Edit `/etc/default/grub` and try these parameters one at a time:
```bash
# Option A: Disable Display Core
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.dc=0"

# Option B: Enable DC debug (if Option A doesn't work)
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.dcdebugmask=0x10"

# Option C: Disable ASPM
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.aspm=0"
```

After editing, run:
```bash
sudo update-grub
sudo reboot
```

### Option 2: Disable problematic wake devices
Some USB devices can interfere with suspend/resume. Try disabling specific wake sources:

```bash
# Disable USB controller wake (temporary - test first)
echo XHC1 | sudo tee /proc/acpi/wakeup  # Disable if enabled
echo XHC3 | sudo tee /proc/acpi/wakeup
echo XHC4 | sudo tee /proc/acpi/wakeup
```

To make permanent, create: `/etc/systemd/system/disable-usb-wake.service`

### Option 2: Force deeper sleep with kernel parameters
Add to GRUB kernel parameters in `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mem_sleep_default=s2idle"
```

Then run: `sudo update-grub`

### Option 3: NVME power management
Some NVMe drives have issues with s2idle. Add to kernel parameters:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvme.noacpi=1"
```

### Option 4: AMD GPU power management
Try disabling ASPM for the GPU:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash amdgpu.aspm=0"
```

### Option 5: Use hibernation instead
If suspend continues to be problematic, consider using hibernation:

```bash
# Enable hibernation
sudo systemctl enable systemd-hibernate.service

# Configure lid close to hibernate
sudo nano /etc/systemd/logind.conf
# Uncomment and set:
# HandleLidSwitch=hibernate
```

## Debugging

Check recent suspend/resume events:
```bash
journalctl -b -0 | grep -i "suspend\|resume" | tail -30
```

Check which devices can wake the system:
```bash
cat /proc/acpi/wakeup
```

Check current sleep mode:
```bash
cat /sys/power/mem_sleep
```

Monitor suspend process in real-time:
```bash
sudo journalctl -f
# Then close the lid
```

## Workaround
Until a permanent fix is found, you can:
1. Use manual suspend (keyboard shortcut) instead of lid close
2. Configure lid close to do nothing and use a keyboard shortcut for suspend
3. Use hibernation instead of suspend
4. Keep the laptop plugged in (external power sometimes helps)

## Related Issues
- AMD Ryzen laptops often have s2idle issues on Linux
- ASUS laptops sometimes have ACPI lid switch problems
- Kernel 6.x has improved s2idle support but not perfect

## Testing a Fix
After applying any fix:
1. Reboot
2. Close lid and wait 30 seconds
3. Open lid and press power button
4. Check if system wakes properly
5. Check logs: `journalctl -b -0 | grep -i suspend`
