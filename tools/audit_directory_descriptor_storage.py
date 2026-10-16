#!/usr/bin/env python3
"""Audit the storage class and sharing of the 32 ROM directory index descriptors."""
import argparse
import collections
import json
from pathlib import Path
from trace_directory_runtime import BASE, DIRECTORY, SLOTS, s16, u32


def audit(rom):
    rows = []
    for slot in range(SLOTS):
        table = u32(rom, DIRECTORY + slot * 8)
        descriptor = u32(rom, DIRECTORY + slot * 8 + 4)
        if not (BASE <= descriptor <= BASE + len(rom) - 2):
            raise ValueError(f'slot {slot}: descriptor not backed by ROM: {descriptor:#010x}')
        if descriptor & 1:
            raise ValueError(f'slot {slot}: misaligned signed-halfword descriptor')
        index = s16(rom, descriptor)
        target = table + index * 4
        if not (BASE <= target <= BASE + len(rom) - 4):
            raise ValueError(f'slot {slot}: selected table pointer outside ROM')
        rows.append({'slot': slot, 'table': f'{table:#010x}',
                     'descriptor': f'{descriptor:#010x}', 'initial_index': index,
                     'selected_resource': f'{u32(rom, target):#010x}',
                     'descriptor_storage': 'ROM'})
    shared = collections.Counter(x['descriptor'] for x in rows)
    return {'slots': rows, 'unique_descriptors': len(shared),
            'shared_descriptors': {k: n for k, n in shared.items() if n > 1}}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('rom', type=Path)
    p.add_argument('--json', action='store_true')
    args = p.parse_args()
    result = audit(args.rom.read_bytes())
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"{len(result['slots'])} ROM-backed descriptor references; "
              f"{result['unique_descriptors']} distinct descriptor addresses")
        for k, n in result['shared_descriptors'].items():
            print(f'  {k}: referenced by {n} directory slots')
        print('All initial indices:', sorted(set(x['initial_index'] for x in result['slots'])))


if __name__ == '__main__':
    main()
