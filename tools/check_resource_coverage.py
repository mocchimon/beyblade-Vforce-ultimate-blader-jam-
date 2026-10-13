#!/usr/bin/env python3
"""Check that metadata describes every unique resource pointer in all 32 ROM banks.

Reads original ROM locally; exports no ROM payload. Unlike the older verifier,
this also rejects omitted records and conflicting descriptions of aliases.
"""
import argparse
from pathlib import Path
import struct
from verify_resource_manifest import DIRECTORY, ROM_BASE, read_manifest, u32


def check(rom, manifest):
    errors = []
    observed = {}
    for bank in range(32):
        try:
            begin = u32(rom, DIRECTORY + bank * 8)
            end = u32(rom, DIRECTORY + bank * 8 + 4)
            if begin < ROM_BASE or end < begin or (end - begin) % 4 or end > ROM_BASE + len(rom):
                raise ValueError('invalid pointer-table range')
            for index, table_addr in enumerate(range(begin, end, 4)):
                ptr = u32(rom, table_addr)
                offset = ptr - ROM_BASE
                if offset < 0 or offset + 16 > len(rom):
                    raise ValueError(f'bank {bank}/{index}: record pointer out of bounds {ptr:#x}')
                words = struct.unpack_from('<4I', rom, offset)
                if words[0] or words[2] or words[3]:
                    raise ValueError(f'bank {bank}/{index}: unexpected header {words}')
                size = words[1]
                span = (size + 0x13) & ~3
                if offset + span > len(rom):
                    raise ValueError(f'bank {bank}/{index}: record exceeds ROM')
                observed[(bank, index)] = (ptr, size, span)
        except ValueError as exc:
            errors.append(str(exc))
    # Alias slots can have different bank/index keys but must describe the
    # same physical record; only one canonical manifest row is required.
    by_pointer = {}
    for key, value in observed.items():
        if value[0] in by_pointer and by_pointer[value[0]] != value:
            errors.append(f'inconsistent alias for {value[0]:#x}')
        by_pointer[value[0]] = value
    listed = {}
    for bank, index, ptr, size, span in manifest:
        if ptr in listed:
            errors.append(f'duplicate manifest pointer {ptr:#x}')
        listed[ptr] = (ptr, size, span)
        if observed.get((bank, index)) != (ptr, size, span):
            errors.append(f'manifest mismatch bank {bank}/{index}: {ptr:#x}')
    missing = sorted(set(by_pointer) - set(listed))
    extra = sorted(set(listed) - set(by_pointer))
    if missing:
        errors.append(f'missing manifest records: {[hex(x) for x in missing]}')
    if extra:
        errors.append(f'manifest records absent from directory: {[hex(x) for x in extra]}')
    return len(observed), len(by_pointer), errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--manifest', type=Path, default=Path(__file__).resolve().parents[1] / 'data/resource_blob_manifest.inc')
    args = parser.parse_args()
    slots, unique, errors = check(args.rom.read_bytes(), read_manifest(args.manifest))
    print(f'Pointer entries: {slots}; unique resource records: {unique}')
    for error in errors:
        print('FAIL:', error)
    if errors:
        raise SystemExit(f'{len(errors)} coverage errors')
    print('PASS: all directory pointers are covered by the manifest')


if __name__ == '__main__':
    main()
