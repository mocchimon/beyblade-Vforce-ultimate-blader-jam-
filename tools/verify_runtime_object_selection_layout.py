#!/usr/bin/env python3
"""Verify the recovered selection-layout Thumb routine against the ROM."""
import argparse
import re
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ROOT = Path(__file__).resolve().parents[1]
LISTING = ROOT / "asm/pass25/runtime_object_selection_layout.thumb.txt"
RANGE = (0x08061260, 0x080614E0)
CALL_TARGETS = {
    0x080614D8: 0x08061260,  # flags wrapper calls the layout routine
}


def _listing_halfwords():
    words = {}
    for line in LISTING.read_text(encoding="utf-8").splitlines():
        match = re.match(r"^\s*([0-9a-fA-F]+):\s*((?:[0-9a-fA-F]{4}\s*)+)$", line)
        if not match:
            continue
        address = int(match.group(1), 16)
        for token in re.findall(r"[0-9a-fA-F]{4}", match.group(2)):
            if address in words:
                raise ValueError(f"duplicate listing address {address:#010x}")
            words[address] = int(token, 16)
            address += 2
    return words


def _sign_extend(value, bits):
    sign = 1 << (bits - 1)
    return (value ^ sign) - sign


def decode_thumb_bl(rom, address):
    upper, lower = struct.unpack_from("<HH", rom, address - ROM_BASE)
    if (upper & 0xF800) != 0xF000 or (lower & 0xF800) != 0xF800:
        raise ValueError(f"invalid Thumb BL at {address:#010x}")
    displacement = (_sign_extend(upper & 0x7FF, 11) << 12) + (
        (lower & 0x7FF) << 1)
    return address + 4 + displacement


def verify(rom):
    words = _listing_halfwords()
    start, end = RANGE
    if start < ROM_BASE or end - ROM_BASE > len(rom):
        raise ValueError("selection-layout range is outside the supplied ROM")

    for address in range(start, end, 2):
        if address not in words:
            raise ValueError(f"listing is missing halfword at {address:#010x}")
        actual = struct.unpack_from("<H", rom, address - ROM_BASE)[0]
        if actual != words[address]:
            raise ValueError(f"Thumb bytes differ at {address:#010x}")

    for address, expected in CALL_TARGETS.items():
        actual = decode_thumb_bl(rom, address)
        if actual != expected:
            raise ValueError(
                f"call at {address:#010x} targets {actual:#010x}, "
                f"expected {expected:#010x}")

    return {"halfwords": (end - start) // 2,
            "calls": len(CALL_TARGETS)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    result = verify(parser.parse_args().rom.read_bytes())
    print("PASS: {} Thumb halfwords and {} direct-call targets".format(
        result["halfwords"], result["calls"]))


if __name__ == "__main__":
    main()
