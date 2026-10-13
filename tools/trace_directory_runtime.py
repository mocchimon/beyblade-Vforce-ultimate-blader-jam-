#!/usr/bin/env python3
"""Trace ROM directory slots through 0x080629B4 -> 0x08062974.

The second directory word is a pointer to a signed-16 index descriptor,
NOT a resource-end address. The first word is a pointer table base.
"""
import argparse
import json
import struct
from pathlib import Path

BASE = 0x08000000
DIRECTORY = 0x08075640
SLOTS = 32


def u32(rom, addr):
    offset = addr - BASE
    if offset < 0 or offset + 4 > len(rom):
        raise ValueError(f"out-of-ROM u32 at {addr:#010x}")
    return struct.unpack_from('<I', rom, offset)[0]


def s16(rom, addr):
    offset = addr - BASE
    if offset < 0 or offset + 2 > len(rom):
        raise ValueError(f"out-of-ROM s16 at {addr:#010x}")
    return struct.unpack_from('<h', rom, offset)[0]


def trace(rom):
    result = []
    for slot in range(SLOTS):
        table = u32(rom, DIRECTORY + slot * 8)
        descriptor = u32(rom, DIRECTORY + slot * 8 + 4)
        index = s16(rom, descriptor)
        pointer_addr = table + 4 * index
        resource = u32(rom, pointer_addr)
        size = u32(rom, resource + 4)
        if u32(rom, resource) != 0 or u32(rom, resource + 8) != 0 or u32(rom, resource + 12) != 0:
            raise ValueError(f"slot {slot}: invalid resource header at {resource:#010x}")
        if resource - BASE + 16 + size > len(rom):
            raise ValueError(f"slot {slot}: resource data extends beyond ROM")
        result.append(dict(slot=slot, table=f'{table:#010x}', descriptor=f'{descriptor:#010x}',
                           index=index, pointer_address=f'{pointer_addr:#010x}',
                           resource=f'{resource:#010x}', size=size))
    return result


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--json', action='store_true')
    args = ap.parse_args()
    entries = trace(args.rom.read_bytes())
    if args.json:
        print(json.dumps(entries, indent=2))
    else:
        for e in entries:
            print(f"{e['slot']:2d} table={e['table']} descriptor={e['descriptor']} "
                  f"index={e['index']:3d} -> {e['resource']} ({e['size']:#x} bytes)")
        print(f"Verified {len(entries)} slots, {len(set(e['resource'] for e in entries))} selected resource records")


if __name__ == '__main__':
    main()
