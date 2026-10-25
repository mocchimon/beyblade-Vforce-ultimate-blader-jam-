#!/usr/bin/env python3
"""Verify the +0x6B4 runtime-state setter and its two direct call paths."""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ROM_SHA256 = "a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce"
SETTER = 0x080517BC
SETTER_CODE = (0x4902, 0x6809, 0x4A02, 0x1889, 0x6008, 0x4770)
LITERALS = {0x080517C8: 0x03000F48, 0x080517CC: 0x000006B4}
CALLS = {
    0x08045A4A: {"argument": 1, "expected": (0x2001, 0xF00B, 0xFEB7)},
    0x08045A5C: {"argument_paths": [1, 4], "expected": (0xF00B, 0xFEAE)},
}


def u16(data, address):
    return struct.unpack_from('<H', data, address - ROM_BASE)[0]


def u32(data, address):
    return struct.unpack_from('<I', data, address - ROM_BASE)[0]


def decode_bl_target(address, first, second):
    if first & 0xF800 != 0xF000 or second & 0xF800 != 0xF800:
        return None
    s = (first >> 10) & 1
    imm10 = first & 0x03FF
    j1, j2 = (second >> 13) & 1, (second >> 11) & 1
    i1, i2 = (~(j1 ^ s)) & 1, (~(j2 ^ s)) & 1
    imm = (s << 24) | (i1 << 23) | (i2 << 22) | (imm10 << 12) | ((second & 0x07FF) << 1)
    if s:
        imm -= 1 << 25
    return (address + 4 + imm) & 0xFFFFFFFF


def audit(rom):
    if len(rom) < 0x200 or len(rom) % 2:
        raise ValueError('expected an even-length GBA ROM image')
    actual = tuple(u16(rom, SETTER + i * 2) for i in range(len(SETTER_CODE)))
    if actual != SETTER_CODE:
        raise ValueError(f'setter instruction fingerprint mismatch at {SETTER:#010x}')
    for address, expected in LITERALS.items():
        if u32(rom, address) != expected:
            raise ValueError(f'literal mismatch at {address:#010x}')
    expected_argument_loads = {0x08045A48: 0x2001, 0x08045A56: 0x2001, 0x08045A5A: 0x2004}
    for address, expected in expected_argument_loads.items():
        if u16(rom, address) != expected:
            raise ValueError(f'argument-path instruction mismatch at {address:#010x}')
    if decode_bl_target(0x08045A4A, u16(rom, 0x08045A4A), u16(rom, 0x08045A4A + 2)) != SETTER:
        raise ValueError('first callsite does not decode to the setter')
    if decode_bl_target(0x08045A5C, u16(rom, 0x08045A5C), u16(rom, 0x08045A5C + 2)) != SETTER:
        raise ValueError('second callsite does not decode to the setter')
    return {
        'rom_size': len(rom), 'rom_sha256': hashlib.sha256(rom).hexdigest(),
        'expected_original_rom_sha256': ROM_SHA256,
        'setter': f'0x{SETTER:08X}',
        'setter_halfwords': [f'0x{x:04X}' for x in actual],
        'pseudocode': '*(u32 *)(*(u32 *)0x03000F48 + 0x6B4) = value;',
        'verified_literals': {f'0x{k:08X}': f'0x{u32(rom,k):08X}' for k in LITERALS},
        'callsite_1': {'address': '0x08045A4A', 'argument': 1, 'target': f'0x{SETTER:08X}'},
        'callsite_2': {'address': '0x08045A5C', 'argument_paths': [1, 4], 'target': f'0x{SETTER:08X}'},
        'interpretation': 'A small switch-like control-flow region invokes the setter with 1 or 4 on different paths. This proves writes to the runtime +0x6B4 field, but does not establish the high-level meaning of those values or any Easter egg.',
        'sha256_matches_expected_rom': hashlib.sha256(rom).hexdigest() == ROM_SHA256,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--json', type=Path)
    args = parser.parse_args()
    result = audit(args.rom.read_bytes())
    print('PASS: runtime +0x6B4 setter and two direct callsites verified')
    print('  values observed at call paths: 1 and 4')
    print('  these are field values, not yet semantic names or secret conditions')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
