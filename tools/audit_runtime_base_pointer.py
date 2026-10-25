#!/usr/bin/env python3
"""Inventory Thumb literal-load references to the shared runtime-base slot.

Pass 52 is deliberately an xref inventory, not a claim that every matching
halfword is executed code. Each candidate records the LDR instruction, literal
address, and a short raw instruction window for manual control-flow review.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
RUNTIME_BASE_SLOT = 0x03000F48


def u16(data, offset):
    return struct.unpack_from('<H', data, offset)[0]


def u32(data, offset):
    return struct.unpack_from('<I', data, offset)[0]


def scan(rom):
    if len(rom) < 0x200 or len(rom) % 2:
        raise ValueError('expected an even-length GBA ROM image')
    hits = []
    for off in range(0, len(rom) - 1, 2):
        insn = u16(rom, off)
        # Thumb-1 LDR Rd, [PC, #imm8*4] encoding: 01001 Rd imm8.
        if insn & 0xF800 != 0x4800:
            continue
        pc = (ROM_BASE + off + 4) & ~3
        literal_address = pc + ((insn & 0xFF) * 4)
        literal_off = literal_address - ROM_BASE
        if literal_off < 0 or literal_off + 4 > len(rom):
            continue
        if u32(rom, literal_off) != RUNTIME_BASE_SLOT:
            continue
        # Save context as raw halfwords only. It is not a disassembly proof.
        start = max(0, off - 8)
        end = min(len(rom) - 1, off + 18)
        if start & 1:
            start += 1
        if end & 1:
            end -= 1
        context = [f'0x{u16(rom, i):04X}' for i in range(start, end + 2, 2)]
        hits.append({
            'instruction_address': f'0x{ROM_BASE + off:08X}',
            'instruction_halfword': f'0x{insn:04X}',
            'destination_register': f'r{(insn >> 8) & 7}',
            'literal_address': f'0x{literal_address:08X}',
            'literal_value': f'0x{RUNTIME_BASE_SLOT:08X}',
            'raw_context_start': f'0x{ROM_BASE + start:08X}',
            'raw_context_halfwords': context,
        })
    return {
        'rom_size': len(rom),
        'rom_sha256': hashlib.sha256(rom).hexdigest(),
        'target_slot': f'0x{RUNTIME_BASE_SLOT:08X}',
        'candidate_thumb_ldr_literal_references': len(hits),
        'references': hits,
        'interpretation': (
            'These are encoding-level candidates whose PC-relative literal equals '
            'the runtime-base slot. The scan does not establish that every halfword '
            'is executable code, that each candidate is reachable, or where the '
            'slot is initialized.'
        ),
        'next_questions': [
            'Trace confirmed code references into caller/control-flow boundaries.',
            'Find a write to the slot 0x03000F48 or establish the startup memory map.',
            'Do not infer a secret input or gameplay semantics from this inventory alone.'
        ],
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--json', type=Path)
    args = ap.parse_args()
    result = scan(args.rom.read_bytes())
    print(f"ROM-backed scan: {result['candidate_thumb_ldr_literal_references']} candidate literal-load references to {result['target_slot']}")
    print('NOTE: candidates require control-flow verification; this is not a confirmed caller list.')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
