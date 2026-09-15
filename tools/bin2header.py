#!/usr/bin/env python3
"""Convert binary file to C header file"""
import sys
from pathlib import Path

def bin_to_header(bin_file, header_file):
    with open(bin_file, 'rb') as f:
        data = f.read()
    
    # Generate header content
    var_name = Path(bin_file).stem.upper()
    header = f"""// Auto-generated from {Path(bin_file).name}
#pragma once

#include <stdint.h>

const uint8_t {var_name.lower()}_data[] = {{
"""
    
    # Format bytes
    for i in range(0, len(data), 16):
        chunk = data[i:i+16]
        hex_bytes = ", ".join(f"0x{b:02x}" for b in chunk)
        header += f"    {hex_bytes},\n"
    
    header += f"""    0x00  // terminator
}};

const uint32_t {var_name.lower()}_size = {len(data)};


"""
    
    with open(header_file, 'w') as f:
        f.write(header)
    print(f"Generated {header_file}")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <binary_file> <header_file>")
        sys.exit(1)
    bin_to_header(sys.argv[1], sys.argv[2])
