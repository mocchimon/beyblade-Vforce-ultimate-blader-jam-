#!/usr/bin/env python3
"""ROM-backed read-only exploration of resource directory index alternatives.

Does not assert that alternate indices are ever selected during gameplay.
"""
import argparse
import json
from pathlib import Path
from trace_directory_runtime import BASE, DIRECTORY, SLOTS, u32, s16


def inspect_slot(rom, slot, index=None):
    if not 0 <= slot < SLOTS:
        raise ValueError('slot must be 0..31')
    table = u32(rom, DIRECTORY + slot * 8)
    descriptor = u32(rom, DIRECTORY + slot * 8 + 4)
    stored_index = s16(rom, descriptor)
    selected = stored_index if index is None else index
    if not -32768 <= selected <= 32767:
        raise ValueError('index outside signed halfword range')
    pointer_address = table + selected * 4
    if pointer_address % 4:
        raise ValueError('unaligned pointer entry')
    resource = u32(rom, pointer_address)
    if resource % 4:
        raise ValueError('unaligned resource header')
    if any(u32(rom, resource + offset) != 0 for offset in (0, 8, 12)):
        raise ValueError('invalid resource header')
    size = u32(rom, resource + 4)
    if resource - BASE + 16 + size > len(rom):
        raise ValueError('resource payload exceeds ROM')
    return dict(slot=slot, table=f'{table:#010x}', descriptor=f'{descriptor:#010x}',
                stored_index=stored_index, probed_index=selected,
                pointer_address=f'{pointer_address:#010x}',
                resource=f'{resource:#010x}', payload_size=size)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--slot', type=int, required=True)
    parser.add_argument('--index', type=int, help='hypothetical signed index; does not alter ROM')
    args = parser.parse_args()
    print(json.dumps(inspect_slot(args.rom.read_bytes(), args.slot, args.index), indent=2))


if __name__ == '__main__':
    main()
