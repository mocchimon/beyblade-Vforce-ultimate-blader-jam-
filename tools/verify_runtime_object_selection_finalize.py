#!/usr/bin/env python3
"""Verify ROM bytes and calls for the recovered selection finalizer."""
import argparse
import re
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ROOT = Path(__file__).resolve().parents[1]
LISTING = ROOT / "asm/pass24/runtime_object_selection_finalizer.thumb.txt"
RANGE = (0x080614E0, 0x08061684)
CALL_TARGETS = {
    0x080614F8: 0x08064F5C,  # count ordinary selection codes
    0x08061540: 0x08060DBC,  # resize the embedded resource chain
    0x0806154C: 0x08057C5C,  # failure diagnostic
    0x080615EE: 0x08060B8C,  # initialize a resource node
    0x080615F6: 0x0806118C,  # set its control nibble
    0x080615FE: 0x08061154,  # add packed state bits
    0x0806165E: 0x08061260,  # assign selection-node layout coordinates
}
LITERALS = {
    0x08061554: 0x08755B7C,
    0x0806167C: 0x0807D9A4,
    0x08061680: 0xC1FFFCFF,
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
    displacement = (_sign_extend(upper & 0x7FF, 11) << 12) + ((lower & 0x7FF) << 1)
    return address + 4 + displacement


def verify(rom):
    words = _listing_halfwords()
    start, end = RANGE
    if start < ROM_BASE or end - ROM_BASE > len(rom):
        raise ValueError("selection-finalizer range is outside the supplied ROM")

    checked = 0
    for address in range(start, end, 2):
        if address not in words:
            raise ValueError(f"listing is missing halfword at {address:#010x}")
        actual = struct.unpack_from("<H", rom, address - ROM_BASE)[0]
        if actual != words[address]:
            raise ValueError(f"Thumb bytes differ at {address:#010x}")
        checked += 1

    for address, expected in CALL_TARGETS.items():
        actual = decode_thumb_bl(rom, address)
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

    return {"halfwords": checked, "calls": len(CALL_TARGETS),
            "literals": len(LITERALS)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    result = verify(parser.parse_args().rom.read_bytes())
    print("PASS: {} Thumb halfwords, {} direct-call targets, and {} literals"
          .format(result["halfwords"], result["calls"], result["literals"]))


if __name__ == "__main__":
    main()
