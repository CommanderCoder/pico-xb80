#!/usr/bin/env python3
import sys
import os

REPLACEMENTS = [
    (bytes([0xCD, 0x21, 0x00]), bytes([0xCD, 0x04, 0xF0])),
    (bytes([0xCD, 0x24, 0x00]), bytes([0xCD, 0x07, 0xF0])),
    (bytes([0xCD, 0x27, 0x00]), bytes([0xCD, 0x0A, 0xF0])),
    (bytes([0xCD, 0x2A, 0x00]), bytes([0xCD, 0x0D, 0xF0])),
    (bytes([0xCD, 0x2D, 0x00]), bytes([0xCD, 0x10, 0xF0])),
]

def patch_binary(input_path: str, output_path: str) -> None:
    with open(input_path, "rb") as f:
        data = bytearray(f.read())

    total_replacements = 0

    for original, replacement in REPLACEMENTS:
        count = 0
        i = 0
        while i <= len(data) - len(original):
            if data[i:i + len(original)] == original:
                data[i:i + len(original)] = replacement
                addr = bytes([i>>8, i&0xff])
                print(f" {addr.hex(' ')}  |",end='')
                count += 1
                i += len(replacement)
            else:
                i += 1
        if count:
            addr = bytes([i>>8, i&0xff])
            print(f"{original.hex(' ')} -> {replacement.hex(' ')}: {count} replacement(s)")

        total_replacements += count

    with open(output_path, "wb") as f:
        f.write(data)

    print(f"\nDone. {total_replacements} total replacement(s).")
    print(f"Output written to: {output_path}")

def already_patched(input_path: str) -> bool:
    with open(input_path, "rb") as f:
        data = f.read()

    return any(replacement in data for _, replacement in REPLACEMENTS)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python filehandle_patch.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    if not os.path.isfile(input_file):
        print(f"Error: input file '{input_file}' not found.")
        sys.exit(1)

    if os.path.abspath(input_file) == os.path.abspath(output_file):
        print("Error: input and output paths must be different.")
        sys.exit(1)

    print(f"Patching '{input_file}' -> '{output_file}'...")

    if already_patched(input_file):
        print("Error: input file appears to have the patch already applied. Aborting.")
        sys.exit(1)
        
    patch_binary(input_file, output_file)