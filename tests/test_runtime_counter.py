#!/usr/bin/env python3
"""Verify the exact Thumb instructions and IWRAM literal for two counter helpers."""
import pathlib
import struct
import sys

rom = pathlib.Path(sys.argv[1]).read_bytes()
assert len(rom) == 0x800000

def check(addr, words):
    offset = addr - 0x08000000
    actual = struct.unpack_from('<' + 'H' * len(words), rom, offset)
    assert actual == tuple(words), f'{addr:#010x}: {actual!r} != {words!r}'

check(0x08057B78, [0x4902, 0x2000, 0x6048, 0x6008, 0x4770])
check(0x08057B88, [0x4902, 0x6808, 0x3001, 0x6008, 0x4770])
for addr in (0x08057B84, 0x08057B94):
    assert struct.unpack_from('<I', rom, addr - 0x08000000)[0] == 0x03000EE0
print('runtime counter ROM bytes: PASS')
