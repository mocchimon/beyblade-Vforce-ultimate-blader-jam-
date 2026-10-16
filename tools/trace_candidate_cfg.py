#!/usr/bin/env python3
"""Conservative bounded ARM/Thumb candidate control-flow exploration.

This is a heuristic inspection aid, not a disassembler or proof of reachable code.
Unknown instructions advance sequentially; indirect transfers and literal data
cannot be reliably distinguished without further reverse engineering.
"""
import argparse
import json
import struct
from pathlib import Path
from corroborate_directory_loads import corroborate, sign_extend
from trace_directory_runtime import BASE


def trace(rom, address, isa, max_instructions=64):
    if isa not in ('ARM', 'Thumb'):
        raise ValueError('ISA must be ARM or Thumb')
    if max_instructions < 1:
        raise ValueError('max_instructions must be positive')
    width = 4 if isa == 'ARM' else 2
    start = address - BASE
    if start < 0 or start + width > len(rom) or start % width:
        raise ValueError('seed outside aligned ROM instruction range')
    pending = [start]
    seen = set()
    edges = []
    stops = []
    while pending and len(seen) < max_instructions:
        pos = pending.pop()
        if pos in seen:
            continue
        if pos < 0 or pos + width > len(rom) or pos % width:
            stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'outside_rom_or_unaligned'})
            continue
        seen.add(pos)
        next_pos = pos + width
        successors = []
        if isa == 'ARM':
            word = struct.unpack_from('<I', rom, pos)[0]
            cond = word >> 28
            if cond != 15 and (word & 0x0e000000) == 0x0a000000:
                dest = pos + 8 + (sign_extend(word & 0xffffff, 24) << 2)
                is_call = bool(word & (1 << 24))
                successors.append((dest, 'call' if is_call else 'branch'))
                if is_call or cond != 14:
                    successors.append((next_pos, 'fallthrough'))
            elif cond != 15 and (word & 0x0fffffff) == 0x01a0f00e:  # MOV PC, LR
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'mov_pc_lr_return'})
                if cond != 14:
                    successors.append((next_pos, 'conditional_return_fallthrough'))
            elif cond != 15 and (word & 0x0fff8000) == 0x08bd8000:  # LDMIA SP!, {..., PC}
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'ldm_sp_pc_return'})
                if cond != 14:
                    successors.append((next_pos, 'conditional_return_fallthrough'))
            elif cond != 15 and (word & 0x0ffffff0) in (0x012fff10, 0x012fff30):  # BX/BLX register
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'indirect_bx_or_blx'})
                if (word & 0x0ffffff0) == 0x012fff30:
                    successors.append((next_pos, 'indirect_call_return_fallthrough'))
                elif cond != 14:
                    successors.append((next_pos, 'conditional_indirect_fallthrough'))
            elif cond != 15 and (word & 0x0c10f000) == 0x0410f000:  # LDR PC, [base, offset]
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'indirect_ldr_pc'})
                if cond != 14:
                    successors.append((next_pos, 'conditional_indirect_fallthrough'))
            elif cond != 15 and (word & 0x0f000000) == 0x0f000000:  # SWI
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'software_interrupt'})
                if cond != 14:
                    successors.append((next_pos, 'conditional_swi_fallthrough'))
            else:
                successors.append((next_pos, 'sequential_unverified'))
        else:
            half = struct.unpack_from('<H', rom, pos)[0]
            if (half & 0xf800) == 0xe000:
                successors.append((pos + 4 + (sign_extend(half & 0x7ff, 11) << 1), 'branch'))
            elif (half & 0xf000) == 0xd000 and (half & 0x0f00) < 0x0e00:
                successors.append((pos + 4 + (sign_extend(half & 0xff, 8) << 1), 'conditional_branch'))
                successors.append((next_pos, 'fallthrough'))
            elif (half & 0xff87) in (0x4700, 0x4780):  # BX/BLX register
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'indirect_bx_or_blx'})
                if (half & 0xff87) == 0x4780:
                    successors.append((next_pos, 'indirect_call_return_fallthrough'))
            elif (half & 0xff00) == 0xbd00 and (half & 0x100):
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'pop_pc_return'})
            elif (half & 0xff00) == 0x4600 and (half & 0x0087) == 0x0087:  # MOV PC, high register
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'indirect_mov_pc'})
            elif (half & 0xf800) == 0xf000:  # Thumb-1 BL prefix (ARM7TDMI)
                if next_pos + 2 <= len(rom):
                    suffix = struct.unpack_from('<H', rom, next_pos)[0]
                    if (suffix & 0xf800) == 0xf800:
                        displacement = (sign_extend(half & 0x7ff, 11) << 12) + ((suffix & 0x7ff) << 1)
                        dest = pos + 4 + displacement
                        successors.append((dest, 'call'))
                        successors.append((pos + 4, 'fallthrough'))
                        # The suffix is part of the same instruction; don't visit it separately.
                    else:
                        stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'invalid_thumb_bl_pair'})
                else:
                    stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'truncated_thumb_bl_pair'})
            elif (half & 0xf800) == 0xf800:
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'orphan_thumb_bl_suffix'})
            elif (half & 0xff00) == 0xdf00:
                stops.append({'at': f'{BASE+pos:#010x}', 'reason': 'software_interrupt'})
            else:
                successors.append((next_pos, 'sequential_unverified'))
        for dest, kind in successors:
            edges.append({'from': f'{BASE+pos:#010x}', 'to': f'{BASE+dest:#010x}', 'kind': kind})
            if kind == 'call':
                # Do not cross into callee: its ISA and boundary need verification.
                continue
            if dest not in seen:
                pending.append(dest)
    return {'seed': f'{address:#010x}', 'isa': isa, 'visited_count': len(seen),
            'visited': [f'{BASE+x:#010x}' for x in sorted(seen)], 'edges': edges,
            'stops': stops, 'truncated': bool(pending),
            'warning': 'Heuristic only: sequential decoding can traverse data; no function boundaries or runtime reachability established.'}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--address', type=lambda s: int(s, 0))
    ap.add_argument('--isa', choices=['ARM', 'Thumb'])
    ap.add_argument('--max-instructions', type=int, default=64)
    ap.add_argument('--max-candidates', type=int, default=20)
    args = ap.parse_args()
    rom = args.rom.read_bytes()
    if args.address is not None:
        if not args.isa:
            ap.error('--isa required with --address')
        results = [trace(rom, args.address, args.isa, args.max_instructions)]
    else:
        report = corroborate(rom)
        results = [trace(rom, int(c['instruction'], 16), c['isa'], args.max_instructions)
                   for c in report['candidates'][:args.max_candidates]]
    print(json.dumps({'traces': results}, indent=2))


if __name__ == '__main__':
    main()
