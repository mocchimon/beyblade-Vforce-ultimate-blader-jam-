#!/usr/bin/env python3
"""Unit tests for signed Thumb-1 BL decoding and ROM-wide caller audit."""
import sys
import struct
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from audit_helper_callers import BASE, COUNTER, TARGETS, audit, decode_bl


def encode_bl(addr, dest):
    diff = (dest - addr - 4) & 0x7FFFFF
    assert diff % 2 == 0
    return 0xF000 | ((diff >> 12) & 0x7FF), 0xF800 | ((diff >> 1) & 0x7FF)

for source, dest in ((0x08001000, 0x08002000), (0x08002000, 0x08001000),
                     (0x08001000, 0x08001004), (0x08001000, 0x07C01004)):
    h, l = encode_bl(source, dest)
    assert decode_bl(h, l, source) == dest
    assert decode_bl(h, 0x4770, source) is None

rom = bytearray(b'\0' * 0x800000)
rom[0xAC:0xB0] = b'BEYP'
for offset, target in ((0x1000, TARGETS[0]), (0x1010, TARGETS[1])):
    struct.pack_into('<HH', rom, offset, *encode_bl(BASE + offset, target))
struct.pack_into('<I', rom, 0x1100, COUNTER)
result = audit(rom)
assert result['direct_bl_candidates'][f'0x{TARGETS[0]:08X}'] == ['0x08001000']
assert result['direct_bl_candidates'][f'0x{TARGETS[1]:08X}'] == ['0x08001010']
assert result['aligned_counter_literals'] == ['0x08001100']
rom[0x1012] = 0
assert not audit(rom)['direct_bl_candidates'][f'0x{TARGETS[1]:08X}']
rom[0xAC:0xB0] = b'XXXX'
try:
    audit(rom)
except ValueError:
    pass
else:
    raise AssertionError('wrong ROM accepted')
print('helper caller scanner tests: PASS')
