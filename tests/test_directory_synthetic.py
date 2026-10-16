"""ROM-free regression tests for directory indirection and aliasing."""
import sys
import struct
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from trace_directory_runtime import BASE, DIRECTORY, trace
from audit_directory_descriptor_storage import audit


def write32(rom, address, value):
    struct.pack_into('<I', rom, address - BASE, value)


def build():
    rom = bytearray(0x80000)
    # Two distinct, shared descriptors and two independent resource tables.
    descriptors = (BASE + 0x74000, BASE + 0x74008)
    tables = (BASE + 0x74100, BASE + 0x74110)
    resources = (BASE + 0x74200, BASE + 0x74300)
    for n in range(2):
        struct.pack_into('<h', rom, descriptors[n] - BASE, 0)
        write32(rom, tables[n], resources[n])
        write32(rom, resources[n] + 4, 16 + n)
    for slot in range(32):
        n = slot % 2
        write32(rom, DIRECTORY + slot * 8, tables[n])
        write32(rom, DIRECTORY + slot * 8 + 4, descriptors[n])
    return rom, descriptors, tables, resources


def invalid(call):
    try:
        call()
    except ValueError:
        return
    raise AssertionError('expected ValueError')


def main():
    rom, descriptors, tables, resources = build()
    rows = trace(rom)
    assert len(rows) == 32
    assert len({r['resource'] for r in rows}) == 2
    assert rows[0]['resource'] == f'{resources[0]:#010x}'
    assert rows[1]['resource'] == f'{resources[1]:#010x}'
    report = audit(rom)
    assert report['unique_descriptors'] == 2
    assert sorted(report['shared_descriptors'].values()) == [16, 16]

    damaged = bytearray(rom)
    struct.pack_into('<h', damaged, descriptors[0] - BASE, 0x7fff)
    invalid(lambda: trace(damaged))
    invalid(lambda: audit(damaged))

    damaged = bytearray(rom)
    write32(damaged, DIRECTORY + 4, 0x03000000)
    invalid(lambda: audit(damaged))

    damaged = bytearray(rom)
    write32(damaged, resources[1], 0x12345678)
    invalid(lambda: trace(damaged))

    damaged = bytearray(rom)
    write32(damaged, resources[0] + 4, len(damaged))
    invalid(lambda: trace(damaged))
    print('PASS: synthetic directory aliases, descriptor storage, and 4 corruption cases')


if __name__ == '__main__':
    main()
