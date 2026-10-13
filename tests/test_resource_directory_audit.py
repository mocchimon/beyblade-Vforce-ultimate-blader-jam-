#!/usr/bin/env python3
"""Corruption tests for the complete resource directory audit."""
import sys
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from audit_resource_directory import audit
from verify_resource_manifest import read_manifest, DIRECTORY, ROM_BASE


def main():
    rom = bytearray(Path(sys.argv[1]).read_bytes())
    manifest = read_manifest(ROOT / 'data/resource_blob_manifest.inc')
    entries, aliases, errors = audit(rom, manifest)
    assert not errors, errors
    assert len(entries) == 32
    assert any(set([7, 9, 11, 13, 15]).issubset(group) for group in aliases)
    assert any(set([8, 10, 12, 14]).issubset(group) for group in aliases)
    assert len(entries[6][3]) == 2  # second pointer now included in manifest
    print('PASS: all 32 slots, aliases and bank-6 coverage complete')

    addr = manifest[0][2] - ROM_BASE
    original = rom[addr]
    rom[addr] = 1
    assert any('header differs' in e for e in audit(rom, manifest)[2])
    rom[addr] = original
    print('PASS: corrupt reserved header word detected')

    directory_offset = DIRECTORY - ROM_BASE
    original_end = struct.unpack_from('<I', rom, directory_offset + 4)[0]
    struct.pack_into('<I', rom, directory_offset + 4, original_end + 1)
    assert any('malformed pointer table' in e for e in audit(rom, manifest)[2])
    struct.pack_into('<I', rom, directory_offset + 4, original_end)
    print('PASS: misaligned directory entry detected')

    first_ptr = entries[0][1] - ROM_BASE
    original_ptr = struct.unpack_from('<I', rom, first_ptr)[0]
    struct.pack_into('<I', rom, first_ptr, original_ptr + 4)
    assert any('manifest does not match' in e for e in audit(rom, manifest)[2])
    struct.pack_into('<I', rom, first_ptr, original_ptr)
    print('PASS: corrupt pointer detected')


if __name__ == '__main__':
    main()
