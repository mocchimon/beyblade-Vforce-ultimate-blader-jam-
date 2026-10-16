#!/usr/bin/env python3
"""Verify the ROM-specific mixed runtime vector at 0x0807D950.

Only address metadata is emitted; no game data is redistributed.
"""
import argparse
import json
import struct
from pathlib import Path

BASE = 0x08000000
START = 0x0807D950
END = 0x0807D9A0
EXPECTED = (
    0x08057B65, 0x08057C5D, 0x080607B5, 0x0806082D,
    0x0300616C, 0x08057C5D, 0x0300646C, 0x0300682C,
    0x03006940, 0x03006A20, 0x03006B84, 0x08057B61,
    0x08057B65, 0x08057C5D, 0x03006C60, 0x03006F10,
    0x08057C5D, 0x03006FAC, 0x03007034, 0x030070B8,
)


def audit(rom: bytes):
    if len(rom) != 0x800000:
        raise ValueError('expected 8 MiB BEYP ROM')
    if rom[0xAC:0xB0] != b'BEYP':
        raise ValueError('wrong game code')
    values = struct.unpack_from('<20I', rom, START - BASE)
    if values != EXPECTED:
        errors = [f'0x{START+4*i:08X}: expected 0x{e:08X}, got 0x{v:08X}'
                  for i, (e, v) in enumerate(zip(EXPECTED, values)) if e != v]
        raise ValueError('runtime vector mismatch: ' + '; '.join(errors))
    entries = []
    for i, value in enumerate(values):
        kind = 'IWRAM target' if 0x03000000 <= value < 0x03008000 else 'Thumb ROM target'
        entries.append({'slot': f'0x{START+4*i:08X}',
                        'target': f'0x{value:08X}', 'kind': kind})
    return entries


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('rom', type=Path)
    p.add_argument('--json', action='store_true')
    args = p.parse_args()
    entries = audit(args.rom.read_bytes())
    if args.json:
        print(json.dumps(entries, indent=2))
    else:
        for e in entries:
            print(f"{e['slot']} -> {e['target']} ({e['kind']})")
        print(f"Verified {len(entries)} entries: "
              f"{sum(e['kind'] == 'IWRAM target' for e in entries)} IWRAM, "
              f"{sum(e['kind'] == 'Thumb ROM target' for e in entries)} Thumb ROM")


if __name__ == '__main__':
    main()
