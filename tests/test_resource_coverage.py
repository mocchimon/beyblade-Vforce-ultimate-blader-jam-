#!/usr/bin/env python3
"""Regression tests for complete 32-bank resource-pointer coverage."""
import sys
from pathlib import Path
import struct
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from check_resource_coverage import check
from verify_resource_manifest import read_manifest, ROM_BASE, DIRECTORY


def main():
    rom = bytearray(Path(sys.argv[1]).read_bytes())
    manifest = read_manifest(Path(__file__).resolve().parents[1] / 'data/resource_blob_manifest.inc')
    slots, unique, errors = check(rom, manifest)
    assert (slots, unique) == (134, 111) and not errors, errors
    # Omitting bank 6's second resource must fail.
    assert check(rom, [row for row in manifest if row[:2] != (6, 1)])[2]
    # Omitting one of the two large aliases must fail.
    assert check(rom, [row for row in manifest if row[:2] != (7, 0)])[2]
    # Corrupting a resource header must fail even if a different bank aliases it.
    modified = bytearray(rom)
    struct.pack_into('<I', modified, 0x0807DCA4 - ROM_BASE + 8, 1)
    assert check(modified, manifest)[2]
    # Directory corruption must fail without crashing.
    modified = bytearray(rom)
    struct.pack_into('<I', modified, DIRECTORY - ROM_BASE, 0x07FFFFFF)
    assert check(modified, manifest)[2]
    print('PASS: full coverage, missing entries, alias corruption, directory corruption')


if __name__ == '__main__':
    main()
