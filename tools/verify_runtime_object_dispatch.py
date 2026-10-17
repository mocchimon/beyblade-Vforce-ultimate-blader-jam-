#!/usr/bin/env python3
"""Verify the selection dispatch wrapper and packed-field helpers in the ROM."""
import re
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ROOT = Path(__file__).resolve().parents[1]
LISTING = ROOT / "asm/pass22/runtime_object_selection_helpers.thumb.txt"
RANGES = (
    (0x08061154, 0x0806116A),  # OR two low input bits into context word +0x10
    (0x08061170, 0x0806117A),  # extract the same two-bit field
    (0x0806117C, 0x08061182),  # write byte +0x19 = 1
    (0x08061184, 0x0806118A),  # write byte +0x19 = 0
    (0x0806118C, 0x080611A2),  # replace the high nibble of halfword +0x14
    (0x0806124C, 0x08061260),  # release subcontext, clear halfword +0x0A
    (0x08061684, 0x080616A6),  # low-byte argument/return dispatcher wrapper
)
CALL_TARGETS = {
    0x08061252: 0x08060D00,
    0x080615F6: 0x0806118C,
    0x080615FE: 0x08061154,
    0x0806168E: 0x0806124C,
    0x08061698: 0x080614E0,
    0x08050C28: 0x08061684,
    # Independent callers of the recovered byte and packed-field helpers.
    0x08061238: 0x08061184,
    0x080617AA: 0x0806117C,
    0x08061890: 0x0806118C,
    0x080470A8: 0x08061154,
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

    return {"halfwords": checked, "calls": len(CALL_TARGETS),
            "ranges": len(RANGES)}


def main():
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    result = verify(parser.parse_args().rom.read_bytes())
    print("PASS: {} Thumb halfwords across {} ranges and {} direct-call targets"
          .format(result["halfwords"], result["ranges"], result["calls"]))


if __name__ == "__main__":
    main()
