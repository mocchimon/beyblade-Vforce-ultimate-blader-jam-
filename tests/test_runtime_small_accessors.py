#!/usr/bin/env python3
"""Verify exact BEYP ROM opcodes and literal pool for three small Thumb functions."""
import pathlib
import struct
import sys

ROM = pathlib.Path(sys.argv[1]).read_bytes()
assert len(ROM) == 0x800000

def check(address, halfwords):
    off = address - 0x08000000
    got = struct.unpack_from('<' + 'H' * len(halfwords), ROM, off)
    assert got == tuple(halfwords), f'{address:#010x}: {got!r} != {halfwords!r}'

check(0x08057B54, [0x6001, 0x6042, 0x4770])
check(0x08057C64, [0x4801, 0x6800, 0x4770])
check(0x08057C70, [0x4801, 0x8800, 0x4770])
assert struct.unpack_from('<I', ROM, 0x57C6C)[0] == 0x03000E30
assert struct.unpack_from('<I', ROM, 0x57C78)[0] == 0x04000006
print('runtime small accessor ROM bytes: PASS')
