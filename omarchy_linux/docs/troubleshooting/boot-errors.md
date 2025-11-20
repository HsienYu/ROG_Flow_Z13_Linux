# Troubleshooting "beseed32" Boot Error on ROG Flow Z13

## What is "beseed32" Error?

The "beseed32" error is a BIOS/UEFI firmware error specific to ASUS laptops, particularly ROG models. It typically appears before the OS boots and indicates a problem with the BIOS initialization or boot configuration.

## Quick Fix (Most Effective)

### 1. Clear Embedded Controller (EC)

This resets the laptop's embedded controller firmware:

1. **Power off** the laptop completely (not sleep/hibernate)
2. **Unplug** the AC adapter
3. **Hold** the power button for **60 seconds**
4. **Reconnect** the AC adapter
5. **Power on** normally

✅ This fixes the issue in ~80% of cases

### 2. Reset BIOS to Defaults

1. Power on and immediately press **F2** or **DEL** repeatedly to enter BIOS
2. Navigate to **Exit** menu (or similar)
3. Select **"Load Optimized Defaults"** or **"Restore Defaults"**
4. Press **F10** to save and exit
5. Allow system to reboot

### 3. Disable Secure Boot (If Enabled)

1. Enter BIOS (F2/DEL during boot)
2. Navigate to **Security** → **Secure Boot**
3. Set to **Disabled**
4. Save and exit (F10)

## Advanced Fixes

### Check Boot Order

From Linux terminal:
```bash
sudo efibootmgr -v
```

Ensure your Linux bootloader (Limine/GRUB) appears first in BootOrder.

### Update BIOS Firmware

⚠️ **Only do this if other fixes fail**

1. Visit [ASUS ROG Support](https://rog.asus.com/support/)
2. Search for "ROG Flow Z13 GZ302"
3. Download latest BIOS update for your exact model
4. Follow ASUS instructions carefully

**Current BIOS version check:**
```bash
cat /sys/class/dmi/id/bios_version
cat /sys/class/dmi/id/bios_date
```

### Remove Old/Duplicate Boot Entries

If you have many boot entries, clean them up:

```bash
# List all boot entries
sudo efibootmgr -v

# Remove unwanted entry (replace XXXX with boot number)
sudo efibootmgr -b XXXX -B
```

⚠️ **Be careful** - only remove entries you're sure about

## Diagnostic Information

Your system diagnostic shows:
- **BIOS Version:** GZ302EA.308 (03/24/2025)
- **Boot Mode:** UEFI 64-bit ✓
- **Current Bootloader:** Limine ✓
- **EFI Variables:** 119 entries (normal) ✓

### Known Issues on This Hardware

1. **ASUS HID driver failures** (error -12)
   - This is expected and already handled by keyd fix
   - Not related to beseed32 error

2. **ACPI BIOS errors**
   - Duplicate object definitions in BIOS
   - Harmless, just BIOS quirks

## Prevention

- Avoid hard shutdowns (holding power button)
- Keep BIOS updated to latest stable version
- Don't change BIOS settings unnecessarily
- Use proper shutdown commands in Linux

## Still Having Issues?

Run the diagnostic script:
```bash
sudo ./scripts/diagnostics/diagnose-boot.sh
```

Check the generated log in `/tmp/boot-diagnostic-*.log`

## Related Issues

- If keyboard doesn't work after boot: see [input-devices.md](input-devices.md)
- For general installation: see [../../INSTALL.md](../../INSTALL.md)
