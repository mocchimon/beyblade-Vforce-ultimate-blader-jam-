#!/usr/bin/env python3
"""Audit the ROM fingerprint and raw Thumb BL-shaped references near input code.

This deliberately does not equate a BL-shaped pair found by a linear scan with
an executed call: the ROM contains code and embedded data, and no full CFG is
available. The report is a triage aid for later input/secret-condition work.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
MIN_ROM_SIZE = 0x200
MASK_HELPER = 0x080517A4
MASK_HALFWORDS = (0x1C01, 0x4803, 0x6800, 0x4A03, 0x1880, 0x6800, 0x4008, 0x4770)
MASK_LITERAL_ADDRESS = 0x080517B4
MASK_LITERAL_VALUE = 0x03000F48
# The next literal-load address points at 0x080517B8, whose bytes are also
# decoded as instructions at a following entry. Preserve this ambiguity.
OVERLAPPED_WORD_ADDRESS = 0x080517B8
OVERLAPPED_WORD_VALUE = 0x000006B4


def decode_thumb_bl_target(pc_address, first, second):
    """Decode a Thumb-1 BL pair at pc_address; return target or None."""
    if first & 0xF800 != 0xF000 or second & 0xF800 != 0xF800:
        return None
    s = (first >> 10) & 1
    imm10 = first & 0x03FF
    j1 = (second >> 13) & 1
    j2 = (second >> 11) & 1
    i1 = (~(j1 ^ s)) & 1
    i2 = (~(j2 ^ s)) & 1
    imm = (s << 24) | (i1 << 23) | (i2 << 22) | (imm10 << 12) | ((second & 0x07FF) << 1)
    if s:
        imm -= 1 << 25
    return (pc_address + 4 + imm) & 0xFFFFFFFF


def audit(rom):
    if len(rom) < MIN_ROM_SIZE:
        raise ValueError('ROM too short for GBA image analysis')
    if MASK_HELPER - ROM_BASE + len(MASK_HALFWORDS) * 2 > len(rom):
        raise ValueError('ROM too short for expected input-helper fingerprint')
    offset = MASK_HELPER - ROM_BASE
    actual = struct.unpack_from('<' + 'H' * len(MASK_HALFWORDS), rom, offset)
    if actual != MASK_HALFWORDS:
        mismatch = next(i for i, (a, e) in enumerate(zip(actual, MASK_HALFWORDS)) if a != e)
        raise ValueError(f'instruction mismatch at {MASK_HELPER + mismatch * 2:#010x}: '
                         f'{actual[mismatch]:#06x} != {MASK_HALFWORDS[mismatch]:#06x}')
    literal = struct.unpack_from('<I', rom, MASK_LITERAL_ADDRESS - ROM_BASE)[0]
    if literal != MASK_LITERAL_VALUE:
        raise ValueError(f'literal mismatch at {MASK_LITERAL_ADDRESS:#010x}: '
                         f'{literal:#010x} != {MASK_LITERAL_VALUE:#010x}')
    overlap = struct.unpack_from('<I', rom, OVERLAPPED_WORD_ADDRESS - ROM_BASE)[0]
    if overlap != OVERLAPPED_WORD_VALUE:
        raise ValueError(f'overlapped word mismatch at {OVERLAPPED_WORD_ADDRESS:#010x}: '
                         f'{overlap:#010x} != {OVERLAPPED_WORD_VALUE:#010x}')

    candidates = []
    for off in range(0, len(rom) - 3, 2):
        first, second = struct.unpack_from('<HH', rom, off)
        site = ROM_BASE + off
        target = decode_thumb_bl_target(site, first, second)
        if target == MASK_HELPER:
            start = max(0, off - 12)
            context = struct.unpack_from('<' + 'H' * ((off + 8 - start) // 2), rom, start)
            candidates.append({
                'site': f'0x{site:08X}',
                'target': f'0x{target:08X}',
                'preceding_halfwords': [f'0x{x:04X}' for x in context[:6]],
                'bl_halfwords': [f'0x{first:04X}', f'0x{second:04X}'],
            })
    return {
        'rom_size': len(rom),
        'rom_sha256': hashlib.sha256(rom).hexdigest(),
        'helper': f'0x{MASK_HELPER:08X}',
        'instruction_halfwords_verified': len(MASK_HALFWORDS),
        'instruction_fingerprint': [f'0x{x:04X}' for x in MASK_HALFWORDS],
        'literal_at_080517B4': f'0x{literal:08X}',
        'overlapped_word_at_080517B8': f'0x{overlap:08X}',
        'raw_bl_shaped_candidates': candidates,
        'candidate_count': len(candidates),
        'interpretation': (
            'The ROM bytes at 0x080517A4 do not match the current C reconstruction '
            'that directly reads 0x03005E98. The observed sequence loads a pointer '
            'from literal 0x03000F48, then uses a second PC-relative load whose target '
            'overlaps bytes also decoded as a following instruction entry. Resolve '
            'the entry/data overlap and global-pointer semantics before changing the C model.'),
        'limitations': [
            'A whole-ROM linear scan can find BL-shaped data pairs; listed sites are candidates, not all proven executed calls.',
            'The literal-load/code overlap is recorded, not explained.',
            'This is not evidence of a secret-input sequence or Easter egg.',
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--json', type=Path)
    args = parser.parse_args()
    result = audit(args.rom.read_bytes())
    print(f"PASS: verified {result['instruction_halfwords_verified']} Thumb halfwords at {result['helper']}")
    print(f"  raw BL-shaped references: {result['candidate_count']}")
    print('  C reconstruction mismatch noted; overlapping literal/code interpretation unresolved')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
