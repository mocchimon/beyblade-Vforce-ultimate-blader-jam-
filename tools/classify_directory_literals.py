#!/usr/bin/env python3
"""Heuristically associate non-directory xrefs with ARM/Thumb PC-relative LDRs.

This is NOT disassembly or evidence of an executed instruction. Literal-pool
words may be ordinary data, and candidate instructions may also be data.
"""
import argparse
import json
import struct
from pathlib import Path
from scan_directory_xrefs import scan
from trace_directory_runtime import BASE


def candidates(rom, literal_address):
    off = literal_address - BASE
    if off < 0 or off + 4 > len(rom) or off % 4:
        return []
    result = []
    # ARM LDR Rd, [PC, +/- immediate12] with pre-index, word transfer,
    # no writeback. PC = instruction address + 8.
    for pos in range(max(0, off - 4104) & ~3, min(len(rom) - 3, off + 4096), 4):
        insn = struct.unpack_from('<I', rom, pos)[0]
        if (insn & 0x0f7f0000) != 0x051f0000:
            continue
        imm = insn & 0xfff
        target = pos + 8 + (imm if insn & (1 << 23) else -imm)
        if target == off:
            result.append({'isa': 'ARM', 'instruction': f'{BASE + pos:#010x}',
                           'register': (insn >> 12) & 15})
    # Thumb 16-bit LDR Rt, [PC, #imm8*4], PC = align(instr + 4, 4).
    for pos in range(max(0, off - 1026) & ~1, min(len(rom) - 1, off), 2):
        insn = struct.unpack_from('<H', rom, pos)[0]
        if insn & 0xf800 != 0x4800:
            continue
        target = ((pos + 4) & ~3) + ((insn & 0xff) << 2)
        if target == off:
            result.append({'isa': 'Thumb', 'instruction': f'{BASE + pos:#010x}',
                           'register': (insn >> 8) & 7})
    return result


def classify(rom):
    refs = scan(rom)
    hits = []
    for target in refs['targets']:
        for literal in target['other_occurrences']:
            possible = candidates(rom, int(literal, 16))
            hits.append({'target': target['address'], 'slots': target['slots'],
                         'literal': literal, 'candidate_loads': possible})
    return {'hits': hits, 'candidate_count': sum(len(h['candidate_loads']) for h in hits),
            'warning': 'Instruction encodings are heuristic matches only; validate code/data boundaries and control flow manually.'}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    args = ap.parse_args()
    print(json.dumps(classify(args.rom.read_bytes()), indent=2))


if __name__ == '__main__':
    main()
