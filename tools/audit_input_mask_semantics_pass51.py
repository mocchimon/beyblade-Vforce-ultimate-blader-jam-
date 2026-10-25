#!/usr/bin/env python3
"""Verify the input-mask helper and adjacent base+offset setter in the ROM.

Pass 51 corrects the Pass 50 interpretation: 0x080517B8 is a literal word
(0x6B4), not the start of an overlapping function. The next function entry is
0x080517BC and has its own literal pool at 0x080517C8/0x080517CC.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
MASK_ENTRY = 0x080517A4
MASK_CODE = (0x1C01, 0x4803, 0x6800, 0x4A03, 0x1880, 0x6800, 0x4008, 0x4770)
MASK_GLOBAL_LITERAL = 0x080517B4
MASK_OFFSET_LITERAL = 0x080517B8
SETTER_ENTRY = 0x080517BC
SETTER_CODE = (0x4902, 0x6809, 0x4A02, 0x1889, 0x6008, 0x4770)
SETTER_GLOBAL_LITERAL = 0x080517C8
SETTER_OFFSET_LITERAL = 0x080517CC
GLOBAL_POINTER = 0x03000F48
STATE_OFFSET = 0x6B4


def word_at(rom, address):
    return struct.unpack_from('<I', rom, address - ROM_BASE)[0]


def halfwords_at(rom, address, count):
    return struct.unpack_from('<' + 'H' * count, rom, address - ROM_BASE)


def literal_target(address, imm8):
    """Thumb-1 LDR literal target: Align(address + 4, 4) + imm8 * 4."""
    return ((address + 4) & ~3) + imm8 * 4


def audit(rom):
    if len(rom) < 0x200:
        raise ValueError('ROM too short for GBA image analysis')
    actual_mask = halfwords_at(rom, MASK_ENTRY, len(MASK_CODE))
    if actual_mask != MASK_CODE:
        raise ValueError(f'input-mask fingerprint mismatch at {MASK_ENTRY:#010x}')
    actual_setter = halfwords_at(rom, SETTER_ENTRY, len(SETTER_CODE))
    if actual_setter != SETTER_CODE:
        raise ValueError(f'adjacent setter fingerprint mismatch at {SETTER_ENTRY:#010x}')

    literals = {
        MASK_GLOBAL_LITERAL: GLOBAL_POINTER,
        MASK_OFFSET_LITERAL: STATE_OFFSET,
        SETTER_GLOBAL_LITERAL: GLOBAL_POINTER,
        SETTER_OFFSET_LITERAL: STATE_OFFSET,
    }
    for address, expected in literals.items():
        actual = word_at(rom, address)
        if actual != expected:
            raise ValueError(f'literal mismatch at {address:#010x}: {actual:#010x} != {expected:#010x}')

    # Confirm the literal-load targets implied by the encoded LDR immediate fields.
    # At 0x080517A6 and 0x080517AA the imm8 fields are 3; at 0x080517BC and
    # 0x080517C0 they are 2.
    decoded_targets = {
        'mask_global': literal_target(0x080517A6, 3),
        'mask_offset': literal_target(0x080517AA, 3),
        'setter_global': literal_target(0x080517BC, 2),
        'setter_offset': literal_target(0x080517C0, 2),
    }
    expected_targets = {
        'mask_global': MASK_GLOBAL_LITERAL,
        'mask_offset': MASK_OFFSET_LITERAL,
        'setter_global': SETTER_GLOBAL_LITERAL,
        'setter_offset': SETTER_OFFSET_LITERAL,
    }
    if decoded_targets != expected_targets:
        raise ValueError(f'literal address calculation mismatch: {decoded_targets}')

    return {
        'rom_size': len(rom),
        'rom_sha256': hashlib.sha256(rom).hexdigest(),
        'input_mask': {
            'entry': f'0x{MASK_ENTRY:08X}',
            'verified_thumb_halfwords': [f'0x{x:04X}' for x in actual_mask],
            'base_pointer_literal_address': f'0x{MASK_GLOBAL_LITERAL:08X}',
            'base_pointer_literal_value': f'0x{GLOBAL_POINTER:08X}',
            'offset_literal_address': f'0x{MASK_OFFSET_LITERAL:08X}',
            'offset_literal_value': f'0x{STATE_OFFSET:08X}',
            'pseudocode': 'return *(u32 *)(*(u32 *)0x03000F48 + 0x6B4) & mask;',
        },
        'adjacent_setter': {
            'entry': f'0x{SETTER_ENTRY:08X}',
            'verified_thumb_halfwords': [f'0x{x:04X}' for x in actual_setter],
            'base_pointer_literal_address': f'0x{SETTER_GLOBAL_LITERAL:08X}',
            'offset_literal_address': f'0x{SETTER_OFFSET_LITERAL:08X}',
            'pseudocode': '*(u32 *)(*(u32 *)0x03000F48 + 0x6B4) = value;',
        },
        'correction': (
            '0x080517B8 contains the 0x000006B4 literal consumed by the helper at '
            '0x080517A4. The adjacent routine begins at 0x080517BC and references '
            'its own duplicate literals at 0x080517C8 and 0x080517CC. The prior '
            'code/data-overlap hypothesis is not supported by this local control-flow layout.'
        ),
        'confidence_limits': [
            'The ROM proves the base-pointer-plus-offset access pattern, not the runtime value stored at 0x03000F48 at every call.',
            'Equivalence with fixed address 0x03005E98 depends on initialized runtime state and is not assumed by this audit.',
            'This audit does not identify any secret-input sequence or Easter egg.',
        ],
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--json', type=Path)
    args = parser.parse_args()
    result = audit(args.rom.read_bytes())
    print('PASS: input-mask helper and adjacent setter fingerprints verified')
    print('  helper semantics: *(u32 *)(*(u32 *)0x03000F48 + 0x6B4) & mask')
    print('  corrected local layout: literal at 0x080517B8; next entry at 0x080517BC')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
