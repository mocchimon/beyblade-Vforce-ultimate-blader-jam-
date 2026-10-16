#!/usr/bin/env python3
"""ROM-backed vector validation and negative cases."""
import importlib.util
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('runtime_vector', root / 'tools/audit_runtime_vector.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
rom = bytearray(Path(sys.argv[1]).read_bytes())
entries = module.audit(rom)
assert len(entries) == 20
assert sum(e['kind'] == 'IWRAM target' for e in entries) == 11
assert entries[6]['target'] == '0x0300646C'
assert entries[14]['target'] == '0x03006C60'
for offset, altered in [(module.START - module.BASE, 0), (module.START - module.BASE + 14*4, 0)]:
    modified = bytearray(rom)
    modified[offset] ^= 1
    try:
        module.audit(modified)
    except ValueError:
        pass
    else:
        raise AssertionError('modified vector incorrectly accepted')
try:
    module.audit(rom[:-1])
except ValueError:
    pass
else:
    raise AssertionError('truncated ROM incorrectly accepted')
print('Runtime vector audit: PASS (20 entries, 11 IWRAM, 9 ROM, 3 rejection cases)')
