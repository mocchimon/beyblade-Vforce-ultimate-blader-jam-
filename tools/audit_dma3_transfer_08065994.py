#!/usr/bin/env python3
"""Verify the ROM routine at 0x08065994 that performs a guarded DMA3 transfer.

This is a byte-level audit of the Thumb routine and its literal pool. It
identifies the transfer ABI and register offsets, but does not emulate DMA or
claim that this routine installs the separate IWRAM callback at 0x03007034.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ENTRY = 0x08065994
HALFWORDS = (
    0xB570, 0x0412, 0x0C12, 0x4C16, 0x8823, 0x1C1E, 0x2300, 0x8023,
    0x4D14, 0x882C, 0x4B14, 0x401C, 0x4B14, 0x681B, 0x88DB, 0x431C,
    0x802C, 0x4B13, 0x6018, 0x4813, 0x6001, 0x4913, 0x2080, 0x0600,
    0x4302, 0x600A, 0x3102, 0x2280, 0x0212, 0x1C10, 0x8809, 0x4008,
    0x2800, 0xD007, 0x4A0D, 0x2080, 0x0200, 0x1C01, 0x8810, 0x4008,
    0x2800, 0xD1FB, 0x4802, 0x8006, 0xBC70, 0xBC01, 0x4700,
)
LITERALS = {
    0x080659F4: 0x04000208,  # BG2PA, temporarily zeroed/restored
    0x080659F8: 0x04000204,  # BG2X register pair base
    0x080659FC: 0x0000F8FF,  # mask used when updating BG2X
    0x08065A00: 0x03005E9C,  # state object; halfword +6 is merged into BG2X
    0x08065A04: 0x040000D4,  # DMA3SAD
    0x08065A08: 0x040000D8,  # DMA3DAD
    0x08065A0C: 0x040000DC,  # DMA3CNT_L (32-bit store includes CNT_H)
    0x08065A10: 0x040000DE,  # DMA3CNT_H polling address
}


def audit(rom):
    if len(rom) < 0x200:
        raise ValueError('ROM too short for GBA image analysis')
    off = ENTRY - ROM_BASE
    actual = struct.unpack_from('<' + 'H' * len(HALFWORDS), rom, off)
    if actual != HALFWORDS:
        mismatch = next(i for i, (a, b) in enumerate(zip(actual, HALFWORDS)) if a != b)
        raise ValueError(f'instruction mismatch at {ENTRY + mismatch * 2:#010x}: '
                         f'{actual[mismatch]:#06x} != {HALFWORDS[mismatch]:#06x}')
    literals = {}
    for address, expected in LITERALS.items():
        actual_value = struct.unpack_from('<I', rom, address - ROM_BASE)[0]
        if actual_value != expected:
            raise ValueError(f'literal mismatch at {address:#010x}: '
                             f'{actual_value:#010x} != {expected:#010x}')
        literals[f'0x{address:08X}'] = f'0x{actual_value:08X}'
    return {
        'rom_size': len(rom),
        'rom_sha256': hashlib.sha256(rom).hexdigest(),
        'entry': f'0x{ENTRY:08X}',
        'isa': 'Thumb',
        'instruction_halfwords_verified': len(HALFWORDS),
        'literal_values': literals,
        'abi': {'r0': 'source address', 'r1': 'destination address',
                'r2': 'halfword count (truncated to 16 bits before control bit is added)'},
        'transfer': {
            'channel': 3,
            'source_register': '0x040000D4 (DMA3SAD)',
            'destination_register': '0x040000D8 (DMA3DAD)',
            'count_register': '0x040000DC (DMA3CNT_L)',
            'control_register': '0x040000DE (DMA3CNT_H)',
            'control_word': '0x80000000 | (r2 & 0xFFFF)',
            'unit': '16-bit halfwords; 32-bit transfer bit is not set',
            'completion_wait': 'poll DMA3CNT_H bit 15 until cleared',
        },
        'display_guard': {
            'temporarily_zeroed_halfword': '0x04000208 (BG2PA)',
            'BG2X_update_base': '0x04000204',
            'restores_saved_BG2PA_halfword_after_DMA': True,
        },
        'conclusion': ('Verified guarded DMA3 halfword-transfer helper. This is a ROM-resident '
                       'three-argument copy-like routine, not evidence that the IWRAM callback '
                       'at 0x03007034 has been installed.'),
        'limitations': [
            'The audit verifies instruction halfwords and literal values, not hardware execution.',
            'The display-register side effects are described from the instruction sequence; '
            'their visual purpose is not established.',
            'No source-built ROM or byte-for-byte match is produced.',
        ],
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--json', type=Path)
    args = ap.parse_args()
    result = audit(args.rom.read_bytes())
    print(f"PASS: {result['entry']} verified ({result['instruction_halfwords_verified']} Thumb halfwords)")
    print('  ABI: r0=source, r1=destination, r2=16-bit halfword count')
    print('  DMA3: SAD 0x040000D4, DAD 0x040000D8, CNT 0x040000DC/DE')
    print('  IWRAM callback at 0x03007034 remains unresolved')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
