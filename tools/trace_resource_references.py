#!/usr/bin/env python3
"""Audit exact 32-bit ROM references to the recovered resource directory and aliases.

This is a static reference inventory, not proof that each occurrence is code.
No resource payloads are extracted or written.
"""
import argparse
import struct
from pathlib import Path

BASE = 0x08000000
TARGETS = {
    'directory': 0x08075640,
    'alias_odd_table': 0x08074DCC,
    'alias_even_table': 0x08074DD0,
    'alias_odd_record': 0x0807DCA4,
    'alias_even_record': 0x080BE234,
    'bank6_second_record': 0x0821AAF4,
}

def scan(blob, targets=TARGETS):
    result = {}
    for name, address in targets.items():
        word = struct.pack('<I', address)
        result[name] = [BASE + pos for pos in range(0, len(blob) - 3, 4)
                        if blob[pos:pos + 4] == word]
    return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    args = parser.parse_args()
    rom = args.rom.read_bytes()
    if len(rom) < 0x2200000 - BASE:
        parser.error('ROM is too short for bank-6 resource references')
    for name, refs in scan(rom).items():
        print(f'{name} ({TARGETS[name]:#010x}): {len(refs)} aligned reference(s)')
        for ref in refs:
            print(f'  {ref:#010x}')
    print('Note: a reference may be data, a literal pool, or a pointer-table entry.')

if __name__ == '__main__':
    main()
