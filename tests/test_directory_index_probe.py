"""ROM-free signed-index probe tests."""
import sys
import struct
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from probe_directory_indices import inspect_slot
from test_directory_synthetic import build, write32
from trace_directory_runtime import BASE


def fails(fn):
    try:
        fn()
    except ValueError:
        return
    raise AssertionError('expected ValueError')


def main():
    rom, descriptors, tables, resources = build()
    # Positive index, with a valid second resource.
    write32(rom, tables[0] + 4, resources[1])
    assert inspect_slot(rom, 0, 1)['resource'] == f'{resources[1]:#010x}'
    assert inspect_slot(rom, 2, 1)['resource'] == f'{resources[1]:#010x}'
    # Signed negative index: pointer table base may have entries before it.
    write32(rom, tables[0] - 4, resources[1])
    assert inspect_slot(rom, 0, -1)['probed_index'] == -1
    struct.pack_into('<h', rom, descriptors[0] - BASE, -1)
    assert inspect_slot(rom, 0)['resource'] == f'{resources[1]:#010x}'
    assert inspect_slot(rom, 2)['stored_index'] == -1
    fails(lambda: inspect_slot(rom, 32))
    fails(lambda: inspect_slot(rom, 0, 32768))
    fails(lambda: inspect_slot(rom, 0, -32769))
    fails(lambda: inspect_slot(rom, 0, -10000))
    damaged = bytearray(rom)
    write32(damaged, tables[0] - 4, resources[1] + 2)
    fails(lambda: inspect_slot(damaged, 0))
    damaged = bytearray(rom)
    write32(damaged, resources[1] + 8, 1)
    fails(lambda: inspect_slot(damaged, 0))
    print('PASS: signed negative/positive index, alias reuse, and six invalid cases')


if __name__ == '__main__':
    main()
