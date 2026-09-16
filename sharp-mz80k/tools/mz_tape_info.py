#!/usr/bin/env python3
"""
Scan a folder, report the file types found, and decode the tape header of
any Sharp MZ-80K / MZ-80A / MZ-700 tape image files (.MZT / .MZF).

These emulator "tape" files consist of a 128-byte header followed by the
raw program/data bytes:

    offset  size  field
    ------  ----  -----------------------------------------------------
    0x00    1     attribute / file type byte
    0x01    17    filename (ASCII-ish, terminated by 0x0D, space padded)
    0x12    2     file size, little-endian
    0x14    2     load address, little-endian
    0x16    2     exec (start) address, little-endian
    0x18    104   comment / reserved

A file such as BS.MZT (a small Z80 loader) is typically attribute 0x01
(machine code) with a non-zero exec address: it loads and jumps straight
into the machine-code BASIC interpreter, which is why it can then load
BASIC programs from tape itself.


It also checks for the presence of the patch applied by filehandle_patch.py, and will
report if the object code is already patched, or if it is not patched. This is useful for checking
if a file is ready to be patched, or if it has already been patched.
"""

import argparse
import os
import sys
from collections import Counter
from dataclasses import dataclass

HEADER_SIZE = 128
NAME_SIZE = 17
SIZE_OFFSET = 0x12
LOAD_OFFSET = 0x14
EXEC_OFFSET = 0x16

ATTRIBUTE_NAMES = {
    0x01: "Machine code (OBJ)",
    0x02: "BASIC program (tokenised)",
    0x03: "BASIC data - numeric array",
    0x04: "BASIC data - string array",
    0x05: "BASIC data (DATA statement / random access)",
    0x06: "MZ-700 BASIC (byte code)",
    0x07: "MZ-700 BASIC (ASCII text)",
    0x11: "MZ-700 BASIC (Textwriter file)",
}


# Replacements which will have been applied for filehandling in FD_rom1.s. 
# These are the bytes which will be searched for in the object code, and if found, 
# it indicates that the patch has already been applied.
REPLACEMENTS = [
    bytes([0xCD, 0x04, 0xF0]),
    bytes([0xCD, 0x07, 0xF0]),
    bytes([0xCD, 0x0A, 0xF0]),
    bytes([0xCD, 0x0D, 0xF0]),
    bytes([0xCD, 0x10, 0xF0]),
]

# these are the hex codes which are calling tape file handling routines in the FD_rom1.s code. 
# If these are found, it indicates that the patch has not been applied.
FILECALLS = [
    bytes([0xCD, 0x21, 0x00]), 
    bytes([0xCD, 0x24, 0x00]), 
    bytes([0xCD, 0x27, 0x00]), 
    bytes([0xCD, 0x2A, 0x00]), 
    bytes([0xCD, 0x2D, 0x00]), 
]


@dataclass
class MZHeader:
    attribute: int
    name: str
    file_size: int
    load_address: int
    exec_address: int


def decode_name(raw: bytes) -> str:
    end = raw.find(0x0D)
    if end == -1:
        end = len(raw)
    return raw[:end].decode("ascii", errors="replace").rstrip()


def parse_mz_header(data: bytes) -> MZHeader:
    if len(data) < HEADER_SIZE:
        raise ValueError(f"too short for an MZ header ({len(data)} of {HEADER_SIZE} bytes)")
    attribute = data[0]
    name = decode_name(data[1:1 + NAME_SIZE])
    file_size = int.from_bytes(data[SIZE_OFFSET:SIZE_OFFSET + 2], "little")
    load_address = int.from_bytes(data[LOAD_OFFSET:LOAD_OFFSET + 2], "little")
    exec_address = int.from_bytes(data[EXEC_OFFSET:EXEC_OFFSET + 2], "little")
    return MZHeader(attribute, name, file_size, load_address, exec_address)


def attribute_description(attr: int) -> str:
    return ATTRIBUTE_NAMES.get(attr, f"Unknown (0x{attr:02X})")


def iter_files(folder: str, recursive: bool):
    if recursive:
        for root, _dirs, files in os.walk(folder):
            for fname in sorted(files):
                yield os.path.join(root, fname)
    else:
        for fname in sorted(os.listdir(folder)):
            path = os.path.join(folder, fname)
            if os.path.isfile(path):
                yield path


def main():
    parser = argparse.ArgumentParser(
        description="List file types in a folder and decode Sharp MZ-80K/MZ-700 "
                     "tape image (.MZT/.MZF) headers: filename, load address, "
                     "exec address and length."
    )
    parser.add_argument("folder", help="Folder to scan")
    parser.add_argument("-r", "--recursive", action="store_true",
                         help="Recurse into subfolders")
    args = parser.parse_args()

    if not os.path.isdir(args.folder):
        print(f"Error: '{args.folder}' is not a folder", file=sys.stderr)
        sys.exit(1)

    ext_counter = Counter()
    mz_files = []

    for path in iter_files(args.folder, args.recursive):
        ext = os.path.splitext(path)[1].lower() or "(no extension)"
        ext_counter[ext] += 1
        if ext in (".mzt", ".mzf"):
            mz_files.append(path)

    print("=" * 72)
    print(f"File types in: {args.folder}")
    print("=" * 72)
    for ext, count in sorted(ext_counter.items(), key=lambda kv: (-kv[1], kv[0])):
        print(f"  {ext:<16} {count:>5}")
    print()

    if not mz_files:
        print("No .MZT / .MZF tape image files found.")
        return

    print("=" * 72)
    print(f"MZ-80K/MZ-700 tape image details ({len(mz_files)} file(s))")
    print("=" * 72)

    row_fmt = "{:<24} {:<18} {:<32} {:>7} {:>7} {:>7}"
    print(row_fmt.format("File", "Header name", "Type", "Length", "Load", "Exec"))
    print("-" * 100)

    for path in mz_files:
        fname = os.path.basename(path)
        try:
            with open(path, "rb") as f:
                header_bytes = f.read(HEADER_SIZE)
            header = parse_mz_header(header_bytes)
            print(row_fmt.format(
                fname,
                header.name,
                attribute_description(header.attribute),
                header.file_size,
                f"0x{header.load_address:04X}",
                f"0x{header.exec_address:04X}",
            ))

            actual_data_size = os.path.getsize(path) - HEADER_SIZE
            if actual_data_size != header.file_size:
                print(f"    -> warning: header declares {header.file_size} bytes "
                      f"but file contains {actual_data_size} bytes of data")

            if header.attribute == 0x01:
                # Check for patch presence in machine code files
                with open(path, "rb") as f:
                    data = f.read()
                if any(replacement in data for replacement in REPLACEMENTS):
                    print(f"    -> note: file has been patched for SD file handling")
                if any(fc in data for fc in FILECALLS):
                    print(f"    -> note: tape file handling exists in file, consider patching for SD rom")
        except ValueError as e:
            print(row_fmt.format(fname, "-", f"ERROR: {e}", "-", "-", "-"))


if __name__ == "__main__":
    main()
