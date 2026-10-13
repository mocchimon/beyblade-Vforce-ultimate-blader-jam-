"""ROM-backed tests for the resource-directory -> runtime-entry call chain."""
import importlib.util
import struct
import sys
from pathlib import Path

spec = importlib.util.spec_from_file_location('trace_directory_runtime', Path(__file__).resolve().parents[1] / 'tools/trace_directory_runtime.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def run(rom_path):
    original = bytearray(Path(rom_path).read_bytes())
    records = module.trace(original)
    assert len(records) == 32
    assert len(set(x['resource'] for x in records)) == 9
    assert all(x['index'] == 0 for x in records)
    assert all(records[i]['resource'] == '0x0807dca4' for i in range(7, 32, 2))
    assert all(records[i]['resource'] == '0x080be234' for i in range(8, 32, 2))
    assert records[7]['descriptor'] == '0x08074dd0'
    assert records[8]['descriptor'] == '0x08074dd8'
    assert all(records[i]['size'] == 0x40580 for i in range(7, 32, 2))
    assert all(records[i]['size'] == 0x4d780 for i in range(8, 32, 2))

    # Descriptor low halfword is an index, not an end marker.
    broken = bytearray(original)
    struct.pack_into('<h', broken, 0x74dd0, 0x7fff)
    try:
        module.trace(broken)
    except ValueError:
        pass
    else:
        raise AssertionError('out-of-range indexed table access not detected')

    broken = bytearray(original)
    struct.pack_into('<I', broken, 0x75640 + 7 * 8, 0x0)
    try:
        module.trace(broken)
    except ValueError:
        pass
    else:
        raise AssertionError('invalid table pointer not detected')

    broken = bytearray(original)
    struct.pack_into('<I', broken, 0x7dca4, 0x12345678)
    try:
        module.trace(broken)
    except ValueError:
        pass
    else:
        raise AssertionError('invalid resource header not detected')

    print('PASS: 32-slot runtime dereference, alias selection, and 3 corruption cases')


if __name__ == '__main__':
    run(sys.argv[1])
