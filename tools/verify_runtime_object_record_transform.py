#!/usr/bin/env python3
"""Check the recovered record affine-transform cluster against an original ROM."""
import argparse
import re
import struct
from pathlib import Path

ROM_BASE = 0x08000000
LISTING = (Path(__file__).resolve().parents[1] /
           "asm/pass26/runtime_object_record_transform.thumb.txt")
RANGES = (
    (0x08058F84, 0x0805907C),  # record transform and its table literal
    (0x08059A8C, 0x08059ADC),  # affine reference-point register writer
    (0x08059ADC, 0x08059B24),  # affine coefficient register writer
    (0x08059B24, 0x08059C3C),  # transform-table update and literals
    (0x08059FC4, 0x08059FDC),  # signed 8.8 multiply
)
CALL_TARGETS = {
    0x08058FCA: 0x08059B24,
    0x08059020: 0x08059A8C,
    0x08059B7A: 0x08059FC4,
    0x08059BA2: 0x08059FC4,
    0x08059BD0: 0x08059FC4,
    0x08059BF8: 0x08059FC4,
    0x08059C1C: 0x08059ADC,
}
LITERALS = {
    0x08059078: 0x03000D00,
    0x08059AAC: 0x04000028,
    0x08059AB0: 0x0400002A,
    0x08059AB4: 0x0400002C,
    0x08059AD0: 0x04000038,
    0x08059AD4: 0x0400003A,
    0x08059AD8: 0x0400003C,
    0x08059B04: 0x04000020,
    0x08059B20: 0x04000030,
    0x08059C30: 0x03000D00,
    0x08059C34: 0x0874CC60,
    0x08059C38: 0x0872CC60,
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


def _decode_thumb_bl(rom, address):
    upper, lower = struct.unpack_from("<HH", rom, address - ROM_BASE)
    if (upper & 0xF800) != 0xF000 or (lower & 0xF800) != 0xF800:
        raise ValueError(f"invalid Thumb BL at {address:#010x}")
    displacement = ((upper & 0x7FF) << 12) | ((lower & 0x7FF) << 1)
    if upper & 0x0400:
        displacement -= 0x00800000
    return address + 4 + displacement


def verify(rom):
    words = _listing_halfwords()
    checked = 0
    for start, end in RANGES:
        for address in range(start, end, 2):
            if address not in words:
                raise ValueError(f"listing is missing halfword at {address:#010x}")
            actual = struct.unpack_from("<H", rom, address - ROM_BASE)[0]
            if actual != words[address]:
                raise ValueError(f"Thumb bytes differ at {address:#010x}")
            checked += 1

    for address, expected in CALL_TARGETS.items():
        actual = _decode_thumb_bl(rom, address)
        if actual != expected:
            raise ValueError(
                f"call at {address:#010x} targets {actual:#010x}, "
                f"expected {expected:#010x}")

    for address, expected in LITERALS.items():
        actual = struct.unpack_from("<I", rom, address - ROM_BASE)[0]
        if actual != expected:
            raise ValueError(
                f"literal at {address:#010x} is {actual:#010x}, "
                f"expected {expected:#010x}")

    return {
        "halfwords": checked,
        "calls": len(CALL_TARGETS),
        "literals": len(LITERALS),
        "ranges": len(RANGES),
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    result = verify(parser.parse_args().rom.read_bytes())
    print("PASS: {} Thumb halfwords across {} ranges, {} direct calls, and {} literals".format(
        result["halfwords"], result["ranges"], result["calls"], result["literals"]))


if __name__ == "__main__":
    main()
