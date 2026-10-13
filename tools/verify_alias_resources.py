#!/usr/bin/env python3
"""Verify the two alternating directory alias resources without exporting data."""
import argparse
import struct
from pathlib import Path
from audit_resource_directory import audit
from verify_resource_manifest import read_manifest, ROM_BASE

ALIAS_TARGETS = {7: (0x0807DCA4, 0x40580), 8: (0x080BE234, 0x4D780)}

def verify(rom, manifest):
    entries, _, errors = audit(rom, manifest)
    if errors:
        raise ValueError('; '.join(errors[:3]))
    if len(entries) != 32:
        raise ValueError('directory is incomplete')
    for bank, _, _, ptrs in entries:
        if bank < 7:
            continue
        target, expected_size = ALIAS_TARGETS[7 if bank % 2 else 8]
        if ptrs != (target,):
            raise ValueError(f'alias bank {bank} has unexpected target')
        if target < ROM_BASE or target - ROM_BASE + 16 + expected_size > len(rom):
            raise ValueError(f'alias bank {bank} exceeds ROM')
        header = struct.unpack_from('<IIII', rom, target - ROM_BASE)
        if header != (0, expected_size, 0, 0):
            raise ValueError(f'alias bank {bank} header mismatch')
    return True

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    args = ap.parse_args()
    manifest = read_manifest(Path(__file__).resolve().parents[1] / 'data/resource_blob_manifest.inc')
    verify(args.rom.read_bytes(), manifest)
    print('PASS: 25 alias slots, two unique resource records, and all manifest records')
