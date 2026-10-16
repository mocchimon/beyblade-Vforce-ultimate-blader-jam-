#!/usr/bin/env python3
"""Inventory aligned literal references to directory tables/descriptors in a GBA ROM.

Occurrences are raw data matches, NOT verified instructions or write sites.
"""
import argparse
import json
import struct
from collections import defaultdict
from pathlib import Path
from trace_directory_runtime import BASE, DIRECTORY, SLOTS, u32


def scan(rom):
    if DIRECTORY - BASE + SLOTS * 8 > len(rom):
        raise ValueError('ROM too short for resource directory')
    targets = defaultdict(lambda: {'kinds': set(), 'slots': set()})
    for slot in range(SLOTS):
        for offset, kind in ((0, 'table'), (4, 'descriptor')):
            address = u32(rom, DIRECTORY + slot * 8 + offset)
            targets[address]['kinds'].add(kind)
            targets[address]['slots'].add(slot)
    locations = defaultdict(list)
    for off in range(0, len(rom) - 3, 4):
        value = struct.unpack_from('<I', rom, off)[0]
        if value in targets:
            locations[value].append(BASE + off)
    begin, end = DIRECTORY, DIRECTORY + SLOTS * 8
    return {'targets': [
        {'address': f'{addr:#010x}', 'kinds': sorted(info['kinds']),
         'slots': sorted(info['slots']),
         'directory_occurrences': [f'{p:#010x}' for p in locations[addr] if begin <= p < end],
         'other_occurrences': [f'{p:#010x}' for p in locations[addr] if not begin <= p < end]}
        for addr, info in sorted(targets.items())],
        'warning': 'Raw aligned references only; non-directory hits may be data or literal pools, not code or writes.'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    args = parser.parse_args()
    print(json.dumps(scan(args.rom.read_bytes()), indent=2))


if __name__ == '__main__':
    main()
