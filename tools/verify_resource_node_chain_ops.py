#!/usr/bin/env python3
"""Verify ROM bytes and call edges for resource-chain allocation/resizing."""
import argparse
import re
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ROOT = Path(__file__).resolve().parents[1]
LISTING = ROOT / "asm/pass24/resource_node_chain_ops.thumb.txt"
RANGES = (
    (0x08060C40, 0x08060D00),  # allocate a contiguous active-list batch
    (0x08060DBC, 0x08060EAA),  # reuse, grow, or recreate a chain
    (0x08060EAC, 0x08060EB0),  # resize diagnostic literal
    (0x08064F5C, 0x08064F72),  # count nonzero codes other than 32
)
CALL_TARGETS = {
    0x08060C5C: 0x08057C5C,  # allocation diagnostic
    0x08060C7C: 0x080609E8,  # class insertion-point scan
    0x08060CEC: 0x080604F8,  # active-list validator
    0x08060E68: 0x080604F8,
    0x08060E7C: 0x08060C40,  # first-chain allocation
    0x08060E86: 0x08057B60,  # resize diagnostic
    0x08060E8C: 0x08060D00,  # release old segment
    0x08060E96: 0x08060C40,  # recreate smaller segment
    0x080614F8: 0x08064F5C,  # selection finalizer's code count
    0x08061540: 0x08060DBC,  # selection finalizer's chain resize
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
    checked = 0
    for start, end in RANGES:
        if start < ROM_BASE or end - ROM_BASE > len(rom):
            raise ValueError("resource-chain range is outside the supplied ROM")
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

    return {"halfwords": checked, "calls": len(CALL_TARGETS),
            "ranges": len(RANGES)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    result = verify(parser.parse_args().rom.read_bytes())
    print("PASS: {} Thumb halfwords across {} ranges and {} direct-call targets"
          .format(result["halfwords"], result["ranges"], result["calls"]))


if __name__ == "__main__":
    main()
