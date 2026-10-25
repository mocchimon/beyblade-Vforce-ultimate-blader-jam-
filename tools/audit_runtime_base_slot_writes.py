#!/usr/bin/env python3
"""Find Thumb literal-load candidates that are followed by a store to 0x03000F48.

This is a conservative byte-pattern triage pass, not a full disassembly or CFG.
A hit means a register loaded with the slot address is subsequently used as the
base of a Thumb STR encoding before a simple invalidation pattern is observed.
The caller must verify code reachability and the data flow around each hit.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
RUNTIME_BASE_SLOT = 0x03000F48


def u16(data, off):
    return struct.unpack_from('<H', data, off)[0]


def u32(data, off):
    return struct.unpack_from('<I', data, off)[0]


def scan(rom, lookahead=8):
    if len(rom) < 0x200 or len(rom) % 2:
        raise ValueError('expected an even-length GBA ROM image')
    hits = []
    for off in range(0, len(rom) - 1, 2):
        insn = u16(rom, off)
        if insn & 0xF800 != 0x4800:  # Thumb LDR Rd, [PC, #imm8*4]
            continue
        pc = (ROM_BASE + off + 4) & ~3
        literal_address = pc + ((insn & 0xFF) * 4)
        literal_off = literal_address - ROM_BASE
        if literal_off < 0 or literal_off + 4 > len(rom):
            continue
        if u32(rom, literal_off) != RUNTIME_BASE_SLOT:
            continue
        base_reg = (insn >> 8) & 7
        seq = []
        for step in range(1, lookahead + 1):
            pos = off + step * 2
            if pos + 2 > len(rom):
                break
            x = u16(rom, pos)
            seq.append(x)
            kind = None
            source_reg = None
            displacement = None
            # STR Rd, [Rn, #imm5*4], Thumb encoding 01100.
            if x & 0xF800 == 0x6000 and ((x >> 3) & 7) == base_reg:
                kind = 'str_word_immediate'
                source_reg = (x >> 0) & 7
                displacement = ((x >> 6) & 0x1F) * 4
            # STR Rd, [Rn, Rm], Thumb register-offset encoding 0101 000.
            elif x & 0xFE00 == 0x5000 and ((x >> 3) & 7) == base_reg and ((x >> 9) & 7) == 0:
                kind = 'str_word_register'
                source_reg = (x >> 0) & 7
            if kind:
                start = max(0, off - 8)
                end = min(len(rom) - 2, pos + 8)
                if start & 1:
                    start += 1
                context = [f'0x{u16(rom, p):04X}' for p in range(start, end + 2, 2)]
                hits.append({
                    'slot_address_load': f'0x{ROM_BASE + off:08X}',
                    'slot_address_load_halfword': f'0x{insn:04X}',
                    'slot_register': f'r{base_reg}',
                    'literal_address': f'0x{literal_address:08X}',
                    'store_address': f'0x{ROM_BASE + pos:08X}',
                    'store_halfword': f'0x{x:04X}',
                    'store_kind': kind,
                    'stored_source_register': f'r{source_reg}',
                    'byte_displacement': displacement,
                    'halfwords_between_load_and_store': step - 1,
                    'intervening_halfwords': [f'0x{v:04X}' for v in seq[:-1]],
                    'raw_context_start': f'0x{ROM_BASE + start:08X}',
                    'raw_context_halfwords': context,
                })
                break
            # Stop when the base register is overwritten or dereferenced. These
            # simple checks avoid claiming a later store uses the original slot.
            if (x & 0xF800) == 0x4800 and ((x >> 8) & 7) == base_reg:
                break
            if (x & 0xF800) in (0x6800, 0x7800, 0x8800) and ((x >> 3) & 7) == base_reg:
                break
            # Branches and unconditional control transfers end the local window.
            if x & 0xF000 == 0xD000 or x & 0xF800 == 0xE000 or x & 0xFF87 == 0x4700:
                break
    return {
        'rom_size': len(rom),
        'rom_sha256': hashlib.sha256(rom).hexdigest(),
        'target_slot': f'0x{RUNTIME_BASE_SLOT:08X}',
        'lookahead_halfwords': lookahead,
        'candidate_store_count': len(hits),
        'candidates': hits,
        'interpretation': (
            'Candidates are Thumb encoding patterns where an LDR-literal value equals '
            'the slot address and a nearby STR uses that loaded register as its base. '
            'This is not proof of reachability or a complete control-flow/data-flow analysis.'
        ),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--json', type=Path)
    ap.add_argument('--lookahead', type=int, default=8)
    args = ap.parse_args()
    result = scan(args.rom.read_bytes(), args.lookahead)
    print(f"ROM-backed scan: {result['candidate_store_count']} candidate stores to {result['target_slot']}")
    for hit in result['candidates']:
        print(f"  LDR {hit['slot_address_load']} -> STR {hit['store_address']} ({hit['store_kind']})")
    print('NOTE: encoding-level candidates require reachability and data-flow review.')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
