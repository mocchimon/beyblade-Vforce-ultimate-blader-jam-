#!/usr/bin/env python3
"""Scan BEYP ROM for Thumb-1 BL encodings and 32-bit IWRAM literals.

This is a *candidate* scan, not a control-flow proof: data can resemble code.
"""
import argparse
import json
import struct
from pathlib import Path

BASE = 0x08000000
TARGETS = (0x08057B54, 0x08057B78, 0x08057B88, 0x08057C64, 0x08057C70)
COUNTER = 0x03000EE0


def decode_bl(first, second, addr):
    if first & 0xF800 != 0xF000 or second & 0xF800 != 0xF800:
        return None
    offset = ((first & 0x7FF) << 12) | ((second & 0x7FF) << 1)
    if offset & 0x400000:
        offset -= 0x800000
    return (addr + 4 + offset) & 0xFFFFFFFF


def audit(rom):
    if len(rom) != 0x800000 or rom[0xAC:0xB0] != b'BEYP':
        raise ValueError('expected original 8 MiB BEYP ROM')
    calls = {f'0x{x:08X}': [] for x in TARGETS}
    for i in range(0, len(rom) - 3, 2):
        first, second = struct.unpack_from('<HH', rom, i)
        target = decode_bl(first, second, BASE + i)
        key = f'0x{target:08X}' if target is not None else ''
        if key in calls:
            calls[key].append(f'0x{BASE+i:08X}')
    literal = struct.pack('<I', COUNTER)
    refs = [f'0x{BASE+i:08X}' for i in range(0, len(rom)-3, 4)
            if rom[i:i+4] == literal]
    return {'direct_bl_candidates': calls, 'aligned_counter_literals': refs}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--json', action='store_true')
    args = parser.parse_args()
    result = audit(args.rom.read_bytes())
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        for target, callers in result['direct_bl_candidates'].items():
            print(f'{target}: {len(callers)} candidate BL callers')
            if callers:
                print('  ' + ', '.join(callers))
        print('0x03000EE0 aligned literals: ' + ', '.join(result['aligned_counter_literals']))


if __name__ == '__main__':
    main()
