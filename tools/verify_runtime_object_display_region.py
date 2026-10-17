#!/usr/bin/env python3
"""Check display-region clipping and BG-register selectors against the ROM."""
import argparse
import re
import struct
from pathlib import Path

ROM_BASE = 0x08000000
LISTING = (Path(__file__).resolve().parents[1] /
           "asm/pass27/runtime_object_display_region.thumb.txt")
RANGES = (
    (0x08058F32, 0x08058F36),  # record-updater call site
    (0x080596D0, 0x08059928),  # display-region update
    (0x08059928, 0x08059956),  # frame-to-display delta wrapper
    (0x080599CC, 0x08059A0C),  # BGxHOFS address selector
    (0x08059A0C, 0x08059A4C),  # BGxVOFS address selector
    (0x08059A4C, 0x08059A8C),  # BGxCNT address selector
)
CALL_TARGETS = {
    0x08058F32: 0x080596D0,
    0x080597D2: 0x08059334,
    0x08059880: 0x08059334,
    0x080598F2: 0x080599CC,
    0x080598FE: 0x08059A0C,
    0x08059914: 0x08059A8C,
    0x0805994C: 0x080596D0,
}
LITERALS = {
    0x080599F0: 0x04000010,
    0x080599F8: 0x04000014,
    0x08059A00: 0x04000018,
    0x08059A08: 0x0400001C,
    0x08059A30: 0x04000012,
    0x08059A38: 0x04000016,
    0x08059A40: 0x0400001A,
    0x08059A48: 0x0400001E,
    0x08059A70: 0x04000008,
    0x08059A78: 0x0400000A,
    0x08059A80: 0x0400000C,
    0x08059A88: 0x0400000E,
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
    print("PASS: {} Thumb halfwords across {} ranges, {} direct calls, and {} I/O literals".format(
        result["halfwords"], result["ranges"], result["calls"],
        result["literals"]))


if __name__ == "__main__":
    main()
