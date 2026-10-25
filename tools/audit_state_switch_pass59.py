#!/usr/bin/env python3
"""Audit the five-way selector dispatch at ROM address 0x08045A08."""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ROM_SHA256 = "a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce"
# Instructions from the selector load through the indirect branch.
DISPATCH = {
    0x08045A08: 0x4C08, 0x08045A0A: 0x1930, 0x08045A0C: 0x6800,
    0x08045A0E: 0x2804, 0x08045A10: 0xD831, 0x08045A12: 0x0080,
    0x08045A14: 0x4906, 0x08045A16: 0x1840, 0x08045A18: 0x6800,
    0x08045A1A: 0x4687,
}
LITERALS = {
    0x08045A2C: 0x000004B4,
    0x08045A30: 0x08045A34,
}
JUMP_TABLE = {
    0x08045A34: 0x08045A48,
    0x08045A38: 0x08045A5A,
    0x08045A3C: 0x08045A56,
    0x08045A40: 0x08045A70,
    0x08045A44: 0x08045A68,
}
# Entry address -> observed action; keep labels descriptive, not game-semantic.
CASES = {
    0: {"target": 0x08045A48, "field_value": 1, "context_argument": 0x19},
    1: {"target": 0x08045A5A, "field_value": 4, "context_argument": 0x0F},
    2: {"target": 0x08045A56, "field_value": 1, "context_argument": 0x0F},
    3: {"target": 0x08045A70, "field_value": None, "context_argument": 0x0C},
    4: {"target": 0x08045A68, "field_value": None, "context_argument": 0x28},
}

def u16(data, address):
    return struct.unpack_from('<H', data, address - ROM_BASE)[0]

def u32(data, address):
    return struct.unpack_from('<I', data, address - ROM_BASE)[0]

def audit(rom):
    if len(rom) < 0x200 or len(rom) % 2:
        raise ValueError('expected an even-length GBA ROM image')
    for address, expected in DISPATCH.items():
        if u16(rom, address) != expected:
            raise ValueError(f'instruction mismatch at {address:#010x}')
    for address, expected in LITERALS.items():
        if u32(rom, address) != expected:
            raise ValueError(f'literal mismatch at {address:#010x}')
    for address, expected in JUMP_TABLE.items():
        if u32(rom, address) != expected:
            raise ValueError(f'jump-table target mismatch at {address:#010x}')
    # Verify branch-specific setter values and shared context-selection calls.
    expected_halfwords = {
        0x08045A48: 0x2001, 0x08045A4E: 0x2019,
        0x08045A56: 0x2001, 0x08045A5A: 0x2004,
        0x08045A60: 0x200F, 0x08045A68: 0x2028, 0x08045A70: 0x200C,
    }
    for address, expected in expected_halfwords.items():
        if u16(rom, address) != expected:
            raise ValueError(f'case instruction mismatch at {address:#010x}')
    digest = hashlib.sha256(rom).hexdigest()
    return {
        'rom_size': len(rom), 'rom_sha256': digest,
        'expected_original_rom_sha256': ROM_SHA256,
        'selector_load_offset': '0x4B4',
        'dispatch': 'read u32 at [context + 0x4B4]; if value > 4, branch to common return; otherwise indirect-jump through five-entry table',
        'jump_table': {f'0x{k:08X}': f'0x{v:08X}' for k, v in JUMP_TABLE.items()},
        'cases': {str(k): {key: (f'0x{value:08X}' if key == 'target' else value) for key, value in v.items()} for k, v in CASES.items()},
        'observed_behavior': [
            'case 0 stores 1 to runtime_base + 0x6B4, then calls GameState_SelectContext with 0x19',
            'case 1 stores 4 to runtime_base + 0x6B4, then calls GameState_SelectContext with 0x0F',
            'case 2 stores 1 to runtime_base + 0x6B4, then calls GameState_SelectContext with 0x0F',
            'case 3 calls GameState_SelectContext with 0x0C without a preceding +0x6B4 setter in this case block',
            'case 4 calls GameState_SelectContext with 0x28 without a preceding +0x6B4 setter in this case block',
        ],
        'interpretation_limit': 'The selector offset, dispatch targets, setter values, and context arguments are verified. The semantic names of selector values 0..4 and any Easter-egg relationship remain unknown.',
        'sha256_matches_expected_rom': digest == ROM_SHA256,
    }

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--json', type=Path)
    args = parser.parse_args()
    result = audit(args.rom.read_bytes())
    print('PASS: five-way selector dispatch, jump table, and case actions verified')
    print('  selector: [context + 0x4B4], valid values 0..4')
    print('  semantic meanings remain unresolved')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
