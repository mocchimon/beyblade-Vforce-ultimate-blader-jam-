#!/usr/bin/env python3
"""ROM-backed directory descriptor storage checks and negative tests."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from audit_directory_descriptor_storage import audit
from trace_directory_runtime import BASE, DIRECTORY


def expect_invalid(rom):
    try:
        audit(rom)
    except ValueError:
        return
    raise AssertionError('corrupted descriptor unexpectedly accepted')


def main(path):
    original = Path(path).read_bytes()
    result = audit(original)
    assert len(result['slots']) == 32
    assert result['unique_descriptors'] == 9
    assert set(x['initial_index'] for x in result['slots']) == {0}
    assert sorted(result['shared_descriptors'].values()) == [12, 13]
    for slot, value in [(0, 0x03000000), (7, 0x08000001), (8, 0x09000000)]:
        damaged = bytearray(original)
        offset = DIRECTORY - BASE + slot * 8 + 4
        damaged[offset:offset + 4] = value.to_bytes(4, 'little')
        expect_invalid(damaged)
    print('PASS: 32 ROM-backed descriptors, 9 distinct addresses, 3 invalid-pointer tests')


if __name__ == '__main__':
    main(sys.argv[1])
