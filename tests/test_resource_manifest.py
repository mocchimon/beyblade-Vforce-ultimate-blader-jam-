"""Regression tests for resource manifest checks using the original ROM in memory."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from verify_resource_manifest import read_manifest, validate, ROM_BASE, DIRECTORY


def main():
    if len(sys.argv) != 2:
        raise SystemExit('usage: test_resource_manifest.py /path/to/owned.gba')
    rom = bytearray(Path(sys.argv[1]).read_bytes())
    manifest = read_manifest(Path(__file__).resolve().parents[1] / 'data/resource_blob_manifest.inc')
    checked, errors, _ = validate(rom, manifest)
    assert checked == len(manifest) == 111 and not errors, errors
    bank, index, address, size, span = manifest[0]
    pos = address + 4 - ROM_BASE
    original = rom[pos]
    rom[pos] ^= 1
    _, errors, _ = validate(rom, manifest)
    assert any('size' in e for e in errors), errors
    rom[pos] = original
    pointer_table = int.from_bytes(rom[DIRECTORY - ROM_BASE:DIRECTORY - ROM_BASE + 4], 'little')
    pos = pointer_table - ROM_BASE
    rom[pos] ^= 1
    _, errors, _ = validate(rom, manifest)
    assert any('pointer mismatch' in e for e in errors), errors
    print('PASS: 111 original-ROM records, corrupt-size detection, corrupt-pointer detection')


if __name__ == '__main__':
    main()
