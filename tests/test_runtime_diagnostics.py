#!/usr/bin/env python3
"""Verify exact original Thumb stubs, ROM vector references and source."""
import hashlib
import pathlib
import struct
import sys

root = pathlib.Path(__file__).resolve().parents[1]
rom = pathlib.Path(sys.argv[1]).read_bytes()
assert len(rom) == 8388608
assert hashlib.sha1(rom).hexdigest() == '8d2cdd3ece0ab7d2f982b0a83e3ecb878f514a72'
for addr, expected in ((0x08057B64, bytes.fromhex('7047')),
                       (0x08057C5C, bytes.fromhex('0fb404b07047'))):
    assert rom[addr - 0x08000000:addr - 0x08000000 + len(expected)] == expected, hex(addr)
for slot, ptr in ((0x0807D950, 0x08057B65), (0x0807D954, 0x08057C5D)):
    assert struct.unpack_from('<I', rom, slot - 0x08000000)[0] == ptr
src = (root / 'src/runtime_diagnostics.c').read_text()
assert 'void sub_08057B64(void)' in src
assert 'void sub_08057C5C(const void *message, uint32_t argument)' in src
print('PASS: two ROM Thumb stubs and vector slots verified')
