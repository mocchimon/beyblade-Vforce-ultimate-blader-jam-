#!/usr/bin/env python3
"""Verify saved Thumb bytes and diagnostic literals for 0x080604F8."""
import argparse
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ENTRY = 0x080604F8
CODE_HALFWORDS = (
    0xB530, 0x1C04, 0x2C00, 0xD017, 0x6825, 0x2D00, 0xD002, 0x480C,
    0xF7F7, 0xFBA8, 0x2D00, 0xD005, 0x6868, 0x42A0, 0xD002, 0x4809,
    0xF7F7, 0xFBA0, 0x6820, 0x42A8, 0xD002, 0x4807, 0xF7F7, 0xFB9A,
    0x1C25, 0x6864, 0x2C00, 0xD1ED, 0xBC30, 0xBC01, 0x4700, 0x0000,
)
DIAGNOSTIC_WORDS = {
    0x08060538: 0x0875591C,
    0x0806053C: 0x08755938,
    0x08060540: 0x08755954,
}
BL_SITES = (0x08060508, 0x08060518, 0x08060524)
DIAGNOSTIC_TARGET = 0x08057C5C


def _sign_extend(value, bits):
    sign = 1 << (bits - 1)
    return (value ^ sign) - sign


def decode_thumb_bl(rom, address):
    offset = address - ROM_BASE
    upper, lower = struct.unpack_from("<HH", rom, offset)
    if (upper & 0xF800) != 0xF000 or (lower & 0xF800) != 0xF800:
        raise ValueError(f"invalid Thumb BL pair at {address:#010x}")
    displacement = (_sign_extend(upper & 0x7FF, 11) << 12) + ((lower & 0x7FF) << 1)
    return address + 4 + displacement


def verify(rom):
    start = ENTRY - ROM_BASE
    if start < 0 or start + len(CODE_HALFWORDS) * 2 > len(rom):
        raise ValueError("validator entry is outside the supplied ROM")
    actual = struct.unpack_from("<" + "H" * len(CODE_HALFWORDS), rom, start)
    if actual != CODE_HALFWORDS:
        raise ValueError("Thumb instruction bytes at 0x080604F8 do not match the saved listing")

    for address, expected in DIAGNOSTIC_WORDS.items():
        actual_word = struct.unpack_from("<I", rom, address - ROM_BASE)[0]
        if actual_word != expected:
            raise ValueError(f"diagnostic pointer at {address:#010x} is {actual_word:#010x}, expected {expected:#010x}")

    targets = tuple(decode_thumb_bl(rom, address) for address in BL_SITES)
    if targets != (DIAGNOSTIC_TARGET,) * len(BL_SITES):
        raise ValueError(f"diagnostic call targets do not all resolve to {DIAGNOSTIC_TARGET:#010x}: {targets!r}")
    return {"entry": ENTRY, "instruction_halfwords": len(CODE_HALFWORDS),
            "diagnostic_pointers": tuple(DIAGNOSTIC_WORDS.values()),
            "call_targets": targets}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    args = parser.parse_args()
    result = verify(args.rom.read_bytes())
    print(f"PASS: {result['instruction_halfwords']} Thumb halfwords, 3 diagnostic pointers, and 3 calls to 0x{DIAGNOSTIC_TARGET:08X}")


if __name__ == "__main__":
    main()
