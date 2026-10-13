#!/usr/bin/env python3
"""Verify resource index and record boundaries against a user-supplied GBA ROM.

No ROM data is written. The project manifest contains metadata only.
"""
import argparse
from collections import Counter
from pathlib import Path
import re
import struct

ROM_BASE = 0x08000000
DIRECTORY = 0x08075640
RECORD = re.compile(r'^RESOURCE_BLOB\((\d+),\s*(\d+),\s*(0x[0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+),\s*(0x[0-9A-Fa-f]+)\)')


def u32(rom, address):
    offset = address - ROM_BASE
    if offset < 0 or offset + 4 > len(rom):
        raise ValueError(f'ROM pointer out of bounds: {address:#010x}')
    return struct.unpack_from('<I', rom, offset)[0]


def read_manifest(path):
    rows = []
    for line_no, line in enumerate(Path(path).read_text().splitlines(), 1):
        if line.startswith('RESOURCE_BLOB('):
            match = RECORD.fullmatch(line.strip())
            if not match:
                raise ValueError(f'malformed manifest line {line_no}: {line}')
            rows.append(tuple(int(x, 0) for x in match.groups()))
    return rows


def validate(rom, manifest):
    failures = []
    checked = 0
    by_bank = {}
    for bank, index, address, size, span in manifest:
        by_bank.setdefault(bank, []).append((index, address, size, span))
    for bank, rows in sorted(by_bank.items()):
        begin = u32(rom, DIRECTORY + bank * 8)
        end = u32(rom, DIRECTORY + bank * 8 + 4)
        if (end - begin) % 4 or end < begin:
            failures.append(f'bank {bank}: invalid pointer table {begin:#x}..{end:#x}')
            continue
        pointers = [u32(rom, p) for p in range(begin, end, 4)]
        for index, address, size, span in rows:
            checked += 1
            if index >= len(pointers) or pointers[index] != address:
                failures.append(f'bank {bank}/{index}: pointer mismatch at {address:#x}')
            actual_size = u32(rom, address + 4)
            if actual_size != size:
                failures.append(f'bank {bank}/{index}: size {actual_size:#x} != {size:#x}')
            if span != ((size + 0x10 + 3) & ~3):
                failures.append(f'bank {bank}/{index}: aligned span mismatch')
            if address - ROM_BASE + span > len(rom):
                failures.append(f'bank {bank}/{index}: record exceeds ROM')
            if index + 1 < len(pointers) and pointers[index + 1] != address + span:
                failures.append(f'bank {bank}/{index}: next pointer is not record end')
        if [row[0] for row in rows] != list(range(len(rows))):
            failures.append(f'bank {bank}: non-contiguous manifest indices')
    return checked, failures, Counter(bank for bank, *_ in manifest)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path, help='locally owned GBA ROM (never copied)')
    parser.add_argument('--manifest', type=Path, default=Path(__file__).resolve().parents[1] / 'data/resource_blob_manifest.inc')
    args = parser.parse_args()
    checked, failures, banks = validate(args.rom.read_bytes(), read_manifest(args.manifest))
    print(f'Checked {checked} resource records in {len(banks)} banks: {dict(sorted(banks.items()))}')
    for failure in failures[:30]:
        print('FAIL:', failure)
    if failures:
        raise SystemExit(f'{len(failures)} validation errors')
    print('PASS: pointer indices, header sizes, aligned spans and adjacent boundaries')


if __name__ == '__main__':
    main()
