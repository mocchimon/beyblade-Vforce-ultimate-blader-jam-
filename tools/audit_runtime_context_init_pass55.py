#!/usr/bin/env python3
"""Verify the ROM-backed context allocation/initialization prefix at 0x08051090.

This is a bounded signature audit, not a full disassembler. It checks selected
Thumb halfwords and literal-pool words in the supplied original GBA ROM, then
emits a structured interpretation with explicit confidence boundaries.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ENTRY = 0x08051090
EXPECTED_SHA256 = "a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce"
# The instruction sequence covers the allocation, base-pointer install, and
# initial field writes before the follow-on initializer at 0x08051120.
EXPECTED_HALFWORDS = {
    0x08051090: 0xB530, 0x08051092: 0x4D1A, 0x08051094: 0x1C28,
    0x08051096: 0xF009, 0x08051098: 0xF9D5, 0x0805109A: 0x1C04,
    0x0805109C: 0x2C00, 0x0805109E: 0xD103, 0x080510A0: 0x4817,
    0x080510A2: 0x1C29, 0x080510A4: 0xF006, 0x080510A6: 0xFDDA,
    0x080510A8: 0x4B16, 0x080510AA: 0x6821, 0x080510AC: 0x6019,
    0x080510AE: 0x22D6, 0x080510B0: 0x00D2, 0x080510B2: 0x1888,
    0x080510B4: 0x6004, 0x080510B6: 0x2400, 0x080510B8: 0x700C,
    0x080510BA: 0x681A, 0x080510BC: 0x4812, 0x080510BE: 0x1811,
    0x080510C0: 0x2001, 0x080510C2: 0x6008, 0x080510C4: 0x7094,
    0x080510C6: 0x6819, 0x080510C8: 0x4810, 0x080510CA: 0x180A,
    0x080510CC: 0x2080, 0x080510CE: 0x8010, 0x080510D0: 0x480F,
    0x080510D2: 0x180A, 0x080510D4: 0x20FF, 0x080510D6: 0x8010,
    0x080510D8: 0x4A0E, 0x080510DA: 0x1888, 0x080510DC: 0x8004,
    0x080510DE: 0x3202, 0x080510E0: 0x1888, 0x080510E2: 0x8004,
    0x080510E4: 0x4A0C, 0x080510E6: 0x1888, 0x080510E8: 0x6004,
    0x080510EA: 0x480C, 0x080510EC: 0x1809, 0x080510EE: 0x600C,
    0x080510F0: 0xF000, 0x080510F2: 0xF816,
}
EXPECTED_WORDS = {
    0x080510FC: 0x00000C6C,  # requested allocation size
    0x08051100: 0x087293E4,  # failure diagnostic argument
    0x08051104: 0x03000F48,  # runtime-base slot address
    0x08051108: 0x000006B4,
    0x0805110C: 0x000006E6,
    0x08051110: 0x000006E4,
    0x08051114: 0x000006AC,
    0x08051118: 0x00000C64,
    0x0805111C: 0x00000C68,
}


def read_u16(rom: bytes, address: int) -> int:
    off = address - ROM_BASE
    if off < 0 or off + 2 > len(rom):
        raise ValueError(f"ROM address out of bounds: 0x{address:08X}")
    return struct.unpack_from('<H', rom, off)[0]


def read_u32(rom: bytes, address: int) -> int:
    off = address - ROM_BASE
    if off < 0 or off + 4 > len(rom):
        raise ValueError(f"ROM address out of bounds: 0x{address:08X}")
    return struct.unpack_from('<I', rom, off)[0]


def audit(rom: bytes) -> dict:
    if len(rom) < 0x200 or len(rom) % 2:
        raise ValueError('expected an even-length GBA ROM image')
    sha = hashlib.sha256(rom).hexdigest()
    mismatches = []
    for addr, expected in EXPECTED_HALFWORDS.items():
        actual = read_u16(rom, addr)
        if actual != expected:
            mismatches.append({'address': f'0x{addr:08X}', 'expected': f'0x{expected:04X}', 'actual': f'0x{actual:04X}'})
    for addr, expected in EXPECTED_WORDS.items():
        actual = read_u32(rom, addr)
        if actual != expected:
            mismatches.append({'address': f'0x{addr:08X}', 'expected': f'0x{expected:08X}', 'actual': f'0x{actual:08X}'})
    if mismatches:
        raise ValueError('ROM evidence mismatch: ' + json.dumps(mismatches))
    return {
        'rom_size': len(rom), 'rom_sha256': sha,
        'expected_reference_rom_match': sha == EXPECTED_SHA256,
        'entry': f'0x{ENTRY:08X}',
        'checked_halfwords': len(EXPECTED_HALFWORDS),
        'checked_literal_words': len(EXPECTED_WORDS),
        'findings': [
            {'address':'0x08051096','fact':'calls 0x0805A444 (Heap_AllocAlt) with size 0xC6C','confidence':'ROM instruction/literal verified; function identity supported by existing heap reconstruction'},
            {'address':'0x080510A8','fact':'loads slot address 0x03000F48; 0x080510AA reads descriptor word [r4] and 0x080510AC stores it into the slot','confidence':'directly supported by Thumb encodings'},
            {'address':'0x080510B4','fact':'stores descriptor pointer r4 at payload_base + 0x6B0','confidence':'directly supported by Thumb encodings'},
            {'address':'0x080510C2','fact':'writes 1 to payload_base + 0x6B4','confidence':'directly supported by Thumb encodings'},
            {'address':'0x080510B8','fact':'clears byte at payload_base + 0x0; 0x080510C4 clears byte at +0x2','confidence':'directly supported by Thumb encodings'},
            {'address':'0x080510CE','fact':'writes halfword 0x0080 at payload_base + 0x6E6','confidence':'directly supported by Thumb encodings'},
            {'address':'0x080510D6','fact':'writes halfword 0x00FF at payload_base + 0x6E4','confidence':'directly supported by Thumb encodings'},
            {'address':'0x080510DC','fact':'clears halfwords at payload_base + 0x6AC and +0x6AE','confidence':'directly supported by Thumb encodings'},
            {'address':'0x080510E8','fact':'clears words at payload_base + 0xC64 and +0xC68','confidence':'directly supported by Thumb encodings'},
            {'address':'0x080510F0','fact':'calls follow-on initializer at 0x08051120','confidence':'directly decoded Thumb BL'},
            {'address':'0x0805109E','fact':'zero return from allocation falls through a call to 0x08057C5C and then still reaches a descriptor dereference','confidence':'control flow verified; exact intended failure semantics unknown'},
        ],
        'interpretation': 'The routine allocates a 0xC6C-byte block from the alternate heap, stores the payload base in 0x03000F48, stores the allocator descriptor at payload offset 0x6B0, seeds several fields, then calls 0x08051120. This proves the runtime-base slot is initialized here on the normal successful-allocation path. It does not identify the semantic names of the fields or fully reconstruct the follow-on initializer.',
        'limitations': [
            'The diagnostic stub at 0x08057C5C returns without terminating; do not assume allocation failure is safely handled.',
            'Offsets are preserved as offsets; field meanings remain unknown unless independently supported.',
            'This is a bounded signature audit, not a whole-ROM disassembly or matching-build proof.'
        ]
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--json', type=Path)
    args = parser.parse_args()
    result = audit(args.rom.read_bytes())
    print(f"Verified runtime-context initializer at {result['entry']}")
    print(f"  ROM bytes: {result['rom_size']}; checked {result['checked_halfwords']} halfwords and {result['checked_literal_words']} literal words")
    print(f"  ROM SHA-256 matches expected reference: {result['expected_reference_rom_match']}")
    print('  Allocation: Heap_AllocAlt(0xC6C); base stored at 0x03000F48')
    print('  Descriptor at +0x6B0; seeded fields include +0x6B4, +0x6E4, +0x6E6, +0xC64, +0xC68')
    print('  Follow-on initializer: 0x08051120')
    print('  Note: failure-path semantics and field names remain unresolved.')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
