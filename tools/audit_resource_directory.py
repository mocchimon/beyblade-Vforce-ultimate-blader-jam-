#!/usr/bin/env python3
"""Audit all 32 resource-directory slots and known record headers.

Only metadata is reported. Never exports or embeds ROM payload bytes.
"""
import argparse
from collections import defaultdict
from pathlib import Path
import struct
from verify_resource_manifest import ROM_BASE, DIRECTORY, read_manifest, u32

SLOT_COUNT = 32
HEADER_BYTES = 16


def audit(rom, manifest):
    errors = []
    entries = []
    for bank in range(SLOT_COUNT):
        start = u32(rom, DIRECTORY + bank * 8)
        end = u32(rom, DIRECTORY + bank * 8 + 4)
        if end < start or (end - start) % 4 or (end - start) > 0x10000:
            errors.append(f'bank {bank}: malformed pointer table')
            continue
        try:
            ptrs = tuple(u32(rom, p) for p in range(start, end, 4))
        except ValueError as exc:
            errors.append(f'bank {bank}: {exc}')
            continue
        entries.append((bank, start, end, ptrs))
    by_bank = defaultdict(list)
    for bank, index, address, size, span in manifest:
        by_bank[bank].append((index, address, size, span))
        offset_errors = 0
        try:
            header_offset = address - ROM_BASE
            if header_offset < 0 or header_offset + HEADER_BYTES > len(rom):
                raise ValueError('header out of ROM bounds')
            fields = struct.unpack_from('<IIII', rom, header_offset)
            if fields != (0, size, 0, 0):
                errors.append(f'bank {bank}/{index}: header differs from (0, size, 0, 0): {fields!r}')
                offset_errors += 1
        except (ValueError, struct.error) as exc:
            errors.append(f'bank {bank}/{index}: {exc}')
        if offset_errors:
            continue
    aliases = defaultdict(list)
    for bank, start, end, ptrs in entries:
        aliases[(start, end, ptrs)].append(bank)
    for bank, rows in by_bank.items():
        if bank >= SLOT_COUNT:
            errors.append(f'bank {bank}: outside directory')
            continue
        entry = next((entry for entry in entries if entry[0] == bank), None)
        if entry is None:
            errors.append(f'bank {bank}: no valid directory entry')
            continue
        ptrs = entry[3]
        for index, address, _, _ in rows:
            if index >= len(ptrs) or ptrs[index] != address:
                errors.append(f'bank {bank}/{index}: manifest does not match pointer table')
    return entries, [banks for banks in aliases.values() if len(banks) > 1], errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--manifest', type=Path, default=Path(__file__).resolve().parents[1] / 'data/resource_blob_manifest.inc')
    args = parser.parse_args()
    entries, aliases, errors = audit(args.rom.read_bytes(), read_manifest(args.manifest))
    print(f'Audited {len(entries)}/{SLOT_COUNT} directory slots')
    print('Alias groups:', aliases)
    print('Manifest header records:', len(read_manifest(args.manifest)))
    print('Pointer counts by bank:', {bank: len(ptrs) for bank, _, _, ptrs in entries})
    for error in errors[:20]:
        print('FAIL:', error)
    if errors:
        raise SystemExit(f'{len(errors)} audit errors')
    print('PASS: directory bounds, alias grouping, manifest pointers and reserved header words')


if __name__ == '__main__':
    main()
