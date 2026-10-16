#!/usr/bin/env python3
"""Check the recovered object-record update ranges against an original ROM."""
import argparse
import re
import struct
from pathlib import Path

ROM_BASE = 0x08000000
LISTING = (Path(__file__).resolve().parents[1] /
           "asm/pass19/runtime_object_records.thumb.txt")
RANGES = (
    (0x080494EE, 0x080494F8),  # caller computes state + 0x590
    (0x08050A74, 0x08050A9E),  # record-array loop
    (0x0805EBA4, 0x0805EBA8),  # second direct caller of record updater
    (0x08058F18, 0x08058F84),  # one-record update
)
CALL_TARGETS = {
    0x080494F4: 0x08050A74,
    0x08050A8A: 0x08058F18,
    0x08058F32: 0x080596D0,
    0x08058F46: 0x08058F84,
    0x0805EBA4: 0x08058F18,
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

    return {"halfwords": checked, "calls": len(CALL_TARGETS), "ranges": len(RANGES)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    result = verify(parser.parse_args().rom.read_bytes())
    print("PASS: {} Thumb halfwords across {} ranges and {} direct-call targets".format(
        result["halfwords"], result["ranges"], result["calls"]))


if __name__ == "__main__":
    main()
