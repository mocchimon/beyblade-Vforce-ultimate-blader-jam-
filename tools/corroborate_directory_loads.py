#!/usr/bin/env python3
"""Find direct branch references to heuristic directory literal-load candidates.

Branch targets are additional static evidence, NOT proof of executable code,
reachability, function boundaries, or actual resource use.
"""
import argparse
import json
import struct
from pathlib import Path
from classify_directory_literals import classify
from trace_directory_runtime import BASE


def sign_extend(value, bits):
    return (value ^ (1 << (bits - 1))) - (1 << (bits - 1))


def branch_sources(rom, target, isa):
    off = target - BASE
    found = []
    if isa == 'ARM':
        for pos in range(0, len(rom) - 3, 4):
            word = struct.unpack_from('<I', rom, pos)[0]
            cond = word >> 28
            if cond == 15 or (word & 0x0e000000) != 0x0a000000:
                continue
            dest = pos + 8 + (sign_extend(word & 0xffffff, 24) << 2)
            if dest == off:
                found.append({'address': f'{BASE+pos:#010x}', 'kind': 'ARM BL' if word & (1 << 24) else 'ARM B'})
    elif isa == 'Thumb':
        for pos in range(0, len(rom) - 1, 2):
            half = struct.unpack_from('<H', rom, pos)[0]
            kind = None
            if (half & 0xf800) == 0xe000:
                dest = pos + 4 + (sign_extend(half & 0x7ff, 11) << 1)
                kind = 'Thumb B'
            elif (half & 0xf000) == 0xd000 and (half & 0x0f00) < 0x0e00:
                dest = pos + 4 + (sign_extend(half & 0xff, 8) << 1)
                kind = 'Thumb Bcond'
            else:
                continue
            if dest == off:
                found.append({'address': f'{BASE+pos:#010x}', 'kind': kind})
    return found


def corroborate(rom, report=None):
    report = classify(rom) if report is None else report
    results = []
    for hit in report['hits']:
        for load in hit['candidate_loads']:
            refs = branch_sources(rom, int(load['instruction'], 16), load['isa'])
            results.append({**load, 'literal': hit['literal'], 'target': hit['target'],
                            'branch_references': refs, 'branch_reference_count': len(refs)})
    return {'candidates': results, 'with_direct_branches': sum(bool(x['branch_references']) for x in results),
            'warning': 'Raw instruction-pattern matches can be data. Direct branches do not prove code reachability or game behavior.'}


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    args = ap.parse_args()
    print(json.dumps(corroborate(args.rom.read_bytes()), indent=2))


if __name__ == '__main__':
    main()
