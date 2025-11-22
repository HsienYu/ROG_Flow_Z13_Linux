#!/usr/bin/env python3
"""
Direct HID packet testing for ROG Flow Z13 keyboard RGB
This sends raw HID packets to test keyboard color control
"""

import hid
import time
import sys

# Your keyboard device
VENDOR_ID = 0x0B05
PRODUCT_ID = 0x1A30

def send_packet(device, packet):
    """Send a packet and print result"""
    try:
        # Add report ID 0x00 at the beginning
        full_packet = [0x00] + packet
        bytes_written = device.write(full_packet)
        print(f"  Sent {bytes_written} bytes: {' '.join(f'{b:02x}' for b in packet[:16])}")
        time.sleep(0.1)
        return True
    except Exception as e:
        print(f"  Error: {e}")
        return False

def test_static_color(device, r, g, b):
    """Test static color mode - standard ROG packet format"""
    print(f"\nTesting STATIC mode - RGB({r},{g},{b})...")
    
    # Standard ROG static mode packet format
    # Based on asusctl source: 0x5d, 0xb3, zone, 0x00, R, G, B, speed, ...
    packet = [
        0x5d,  # Command byte
        0xb3,  # Mode: static
        0x00,  # Zone
        0x00,  # Reserved
        r, g, b,  # RGB color
        0xeb,  # Speed (medium)
        0x00,  # Direction
        0x00,  # ??
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00  # Padding
    ]
    # Pad to 64 bytes
    packet += [0x00] * (64 - len(packet))
    
    return send_packet(device, packet)

def test_breathe_mode(device, r, g, b):
    """Test breathe mode"""
    print(f"\nTesting BREATHE mode - RGB({r},{g},{b})...")
    
    packet = [
        0x5d,  # Command byte
        0xb4,  # Mode: breathe
        0x00,  # Zone
        0x00,  # Reserved
        r, g, b,  # RGB color
        0xeb,  # Speed (medium)
        0x00,  # Direction
        0x00,  # ??
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00  # Padding
    ]
    packet += [0x00] * (64 - len(packet))
    
    return send_packet(device, packet)

def test_pulse_mode(device, r, g, b):
    """Test pulse mode"""
    print(f"\nTesting PULSE mode - RGB({r},{g},{b})...")
    
    packet = [
        0x5d,  # Command byte
        0xbc,  # Mode: pulse
        0x00,  # Zone
        0x00,  # Reserved
        r, g, b,  # RGB color
        0xeb,  # Speed (medium)
        0x00,  # Direction
        0x00,  # ??
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00  # Padding
    ]
    packet += [0x00] * (64 - len(packet))
    
    return send_packet(device, packet)

def test_init_packet(device):
    """Try initialization packet"""
    print("\nTesting INIT packet...")
    
    # Some keyboards need initialization
    packet = [0x5d, 0x01] + [0x00] * 62
    return send_packet(device, packet)

def test_apply_packet(device):
    """Try apply/commit packet"""
    print("\nTesting APPLY packet...")
    
    packet = [0x5d, 0xb5] + [0x00] * 62
    return send_packet(device, packet)

def main():
    print("ROG Flow Z13 Keyboard HID Tester")
    print("=" * 50)
    
    try:
        # Open the keyboard device
        device = hid.device()
        device.open(VENDOR_ID, PRODUCT_ID)
        
        print(f"Opened device: {device.get_manufacturer_string()} {device.get_product_string()}")
        print(f"Serial: {device.get_serial_number_string()}")
        
        # Test sequence
        print("\n" + "=" * 50)
        print("Starting test sequence...")
        print("=" * 50)
        
        # Try init
        test_init_packet(device)
        time.sleep(0.5)
        
        # Test static colors
        test_static_color(device, 255, 0, 0)    # Red
        time.sleep(2)
        
        test_static_color(device, 0, 255, 0)    # Green
        time.sleep(2)
        
        test_static_color(device, 0, 0, 255)    # Blue
        time.sleep(2)
        
        test_static_color(device, 255, 255, 255)  # White
        time.sleep(2)
        
        # Try apply
        test_apply_packet(device)
        time.sleep(1)
        
        # Try breathe mode
        test_breathe_mode(device, 255, 0, 0)
        time.sleep(2)
        
        # Try pulse mode
        test_pulse_mode(device, 0, 255, 0)
        time.sleep(2)
        
        print("\n" + "=" * 50)
        print("Test complete!")
        print("Did you see any color changes on the keyboard?")
        print("=" * 50)
        
        device.close()
        
    except IOError as e:
        print(f"Error opening device: {e}")
        print("\nTry running with sudo:")
        print(f"  sudo python3 {sys.argv[0]}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
