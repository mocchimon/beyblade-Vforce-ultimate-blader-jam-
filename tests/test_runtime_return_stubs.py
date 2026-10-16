#!/usr/bin/env python3
"""ROM byte verification of nine no-op Thumb entry points."""
import struct
import sys
from pathlib import Path
ADDRESSES = (0x08057B5C, 0x08057B60, 0x08057B68, 0x08057B6C,
             0x08057B70, 0x08057B74, 0x08057B98, 0x08057B9C, 0x08057BA0)
rom = Path(sys.argv[1]).read_bytes()
assert len(rom) == 0x800000 and rom[0xAC:0xB0] == b'BEYP'
for address in ADDRESSES:
    assert struct.unpack_from('<HH', rom, address - 0x08000000) == (0x4770, 0x0000), hex(address)
assert struct.unpack_from('<I', rom, 0x0807D97C - 0x08000000)[0] == 0x08057B61
print('nine Thumb return stubs and vector reference: PASS')
