#!/usr/bin/env python3
"""Check the record-manager listing, diagnostics, and call targets in a ROM."""
import argparse
import re
import struct
from pathlib import Path

ROM_BASE = 0x08000000
LISTING = Path(__file__).resolve().parents[1] / "asm/pass8/object_record_init.thumb.txt"
RANGES = (
    (0x08050388, 0x08050420),  # clear and initialize
    (0x08050420, 0x080504E8),  # update
)
DIAGNOSTICS = {
    0x080503B8: 0x087270A4,
    0x080503D4: 0x087270DC,
}
CALL_TARGETS = {
    0x080503B2: 0x08057C5C,
    0x080503BE: 0x0805A444,
    0x080503CE: 0x08057C5C,
}
RETURN_ONLY_BYTES = bytes.fromhex("0f b4 04 b0 70 47")


def _listing_halfwords(start, end):
    words = {}
    for line in LISTING.read_text(encoding="utf-8").splitlines():
        match = re.match(r"^\s*([0-9a-fA-F]+):\s+((?:[0-9a-fA-F]{4}\s+)+)", line)
        if not match:
            continue
        address = int(match.group(1), 16)
        if not start <= address < end:
            continue
        for token in re.findall(r"[0-9a-fA-F]{4}", match.group(2)):
            if address in words:
                raise ValueError(f"duplicate listing address {address:#010x}")
            words[address] = int(token, 16)
            address += 2

    result = []
    for address in range(start, end, 2):
        if address not in words:
            raise ValueError(f"saved listing is missing halfword at {address:#010x}")
        result.append(words[address])
    return tuple(result)


def _decode_thumb_bl(rom, address):
    offset = address - ROM_BASE
    upper, lower = struct.unpack_from("<HH", rom, offset)
    if (upper & 0xF800) != 0xF000 or (lower & 0xF800) != 0xF800:
        raise ValueError(f"invalid Thumb BL at {address:#010x}")
    displacement = (((upper & 0x7FF) << 12) | ((lower & 0x7FF) << 1))
    if upper & 0x0400:
        displacement -= 0x00800000
    return address + 4 + displacement


def verify(rom):
    checked = 0
    for start, end in RANGES:
        expected = _listing_halfwords(start, end)
        actual = struct.unpack_from("<" + "H" * len(expected), rom,
                                    start - ROM_BASE)
        if actual != expected:
            raise ValueError(f"Thumb bytes differ from saved listing at {start:#010x}")
        checked += len(expected)

    for address, expected in DIAGNOSTICS.items():
        actual = struct.unpack_from("<I", rom, address - ROM_BASE)[0]
        if actual != expected:
            raise ValueError(f"diagnostic at {address:#010x} is {actual:#010x}, expected {expected:#010x}")

    for address, expected in CALL_TARGETS.items():
        actual = _decode_thumb_bl(rom, address)
        if actual != expected:
            raise ValueError(f"call at {address:#010x} targets {actual:#010x}, expected {expected:#010x}")

    service_offset = 0x08057C5C - ROM_BASE
    if rom[service_offset:service_offset + len(RETURN_ONLY_BYTES)] != RETURN_ONLY_BYTES:
        raise ValueError("0x08057C5C no longer matches its save/restore/return sequence")

    return {"halfwords": checked, "diagnostics": len(DIAGNOSTICS),
            "calls": len(CALL_TARGETS)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    result = verify(parser.parse_args().rom.read_bytes())
    print("PASS: {} Thumb halfwords, {} diagnostic pointers, {} call targets, "
          "and the 0x08057C5C return-only sequence".format(
              result["halfwords"], result["diagnostics"], result["calls"]))


if __name__ == "__main__":
    main()
