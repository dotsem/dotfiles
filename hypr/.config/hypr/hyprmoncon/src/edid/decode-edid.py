#!/usr/bin/env python3

import sys
import struct
import binascii

def parse_edid(edid_hex):
    edid = binascii.unhexlify(edid_hex.strip().replace('\n', '').replace(' ', ''))
    if len(edid) != 128:
        print("Invalid EDID length")
        return

    manufacturer_id = ''.join([
        chr(((edid[8] >> 2) & 0x1F) + ord('A') - 1),
        chr((((edid[8] & 0x3) << 3) | (edid[9] >> 5)) + ord('A') - 1),
        chr((edid[9] & 0x1F) + ord('A') - 1)
    ])

    product_code = struct.unpack('<H', edid[10:12])[0]
    serial_number = struct.unpack('<I', edid[12:16])[0]

    # Check descriptor blocks for ASCII serial/model info
    descriptors = [edid[i:i+18] for i in range(54, 126, 18)]
    model_name = None
    ascii_serial = None

    for d in descriptors:
        if d[3] == 0xFC:  # Model name
            model_name = d[5:18].decode('ascii', errors='ignore').strip()
        elif d[3] == 0xFF:  # Serial number
            ascii_serial = d[5:18].decode('ascii', errors='ignore').strip()

    print(f"Manufacturer ID : {manufacturer_id}")
    print(f"Product Code    : {product_code}")
    print(f"Serial (binary) : {serial_number}")
    if ascii_serial:
        print(f"Serial (ASCII)  : {ascii_serial}")
    if model_name:
        print(f"Model Name      : {model_name}")

if __name__ == "__main__":
    if sys.stdin.isatty():
        print("Paste EDID hex to stdin or pipe from a file.")
        sys.exit(1)
    hex_data = sys.stdin.read()
    parse_edid(hex_data)
