#!/usr/bin/env python3
"""Verify the small startup DMA installer at 0x08057968 against a GBA ROM.

The routine is Thumb code. This audit checks its exact instruction halfwords
and literal values, then records the transfer parameters implied by those
instructions. It does not assume this installer is responsible for the later
IWRAM function-pointer targets near 0x0300616C-0x03007478.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ENTRY = 0x08057968
HALFWORDS = (
    0x4A0A, 0x490B, 0x6011, 0x4B0B, 0x6053, 0x480B, 0x1A41,
    0x1C08, 0x3020, 0x2800, 0xDA00, 0x3003, 0x1080, 0x2184,
    0x0609, 0x4308, 0x6090, 0x6890, 0x4805, 0x6003, 0x4770,
)
LITERALS = {
    0x08057994: 0x040000D4,  # DMA3 source register address
    0x08057998: 0x08000168,  # source ROM address
    0x0805799C: 0x03000FE0,  # destination IWRAM address
    0x080579A0: 0x0800026C,  # endpoint used by count calculation
    0x080579A4: 0x03007FFC,  # startup IWRAM-base slot
}


def audit(rom):
    if len(rom) < 0x200:
        raise ValueError('ROM too short for GBA image analysis')
    offset = ENTRY - ROM_BASE
    if offset < 0 or offset + 2 * len(HALFWORDS) > len(rom):
        raise ValueError('startup installer lies outside ROM')
    actual_halfwords = struct.unpack_from('<' + 'H' * len(HALFWORDS), rom, offset)
    if actual_halfwords != HALFWORDS:
        mismatch = next(i for i, pair in enumerate(zip(actual_halfwords, HALFWORDS)) if pair[0] != pair[1])
        raise ValueError(f'instruction mismatch at {ENTRY + mismatch * 2:#010x}: '
                         f'{actual_halfwords[mismatch]:#06x} != {HALFWORDS[mismatch]:#06x}')
    literal_values = {}
    for address, expected in LITERALS.items():
        pos = address - ROM_BASE
        if pos < 0 or pos + 4 > len(rom):
            raise ValueError(f'literal outside ROM at {address:#010x}')
        actual = struct.unpack_from('<I', rom, pos)[0]
        if actual != expected:
            raise ValueError(f'literal mismatch at {address:#010x}: {actual:#010x} != {expected:#010x}')
        literal_values[f'0x{address:08X}'] = f'0x{actual:08X}'

    source = LITERALS[0x08057998]
    destination = LITERALS[0x0805799C]
    endpoint = LITERALS[0x080579A0]
    computed_words = ((endpoint - source) + 0x20) >> 2
    return {
        'rom_size': len(rom),
        'rom_sha256': hashlib.sha256(rom).hexdigest(),
        'entry': f'0x{ENTRY:08X}',
        'isa': 'Thumb',
        'instruction_halfwords_verified': len(HALFWORDS),
        'literal_values': literal_values,
        'transfer': {
            'dma_register': 'DMA3SAD/DMA3 transfer register block at 0x040000D4',
            'source_rom': f'0x{source:08X}',
            'destination_iwram': f'0x{destination:08X}',
            'endpoint_constant': f'0x{endpoint:08X}',
            'count_formula': '((endpoint - source) + 0x20) >> 2',
            'word_count': computed_words,
            'control_word': f'0x{(0x84000000 | computed_words):08X}',
            'published_iwram_base_slot': f'0x{LITERALS[0x080579A4]:08X}',
        },
        'conclusion': 'Verified startup DMA setup; it targets 0x03000FE0, not the later callback at 0x03007034.',
        'limitations': [
            'This is an instruction/literal audit, not emulation of the DMA hardware.',
            'The installer target does not establish how the later IWRAM function table is populated.',
            'No source-built ROM or byte-for-byte match is produced by this audit.'
        ],
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--json', type=Path)
    args = ap.parse_args()
    result = audit(args.rom.read_bytes())
    print(f"PASS: startup installer {result['entry']} verified ({result['instruction_halfwords_verified']} Thumb halfwords)")
    print(f"  source: {result['transfer']['source_rom']}")
    print(f"  destination: {result['transfer']['destination_iwram']}")
    print(f"  computed DMA word count: {result['transfer']['word_count']:#x}")
    print(f"  function-table callback 0x03007034: not explained by this installer")
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
