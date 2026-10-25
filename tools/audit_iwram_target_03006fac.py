#!/usr/bin/env python3
"""Audit the ROM-resident pointer to the opaque 0x03006FAC ARM target."""
import argparse
import struct
from pathlib import Path

ROM_BASE = 0x08000000
TABLE_SLOT = 0x0807D994
TARGET = 0x03006FAC


def _find_all(data, needle):
    hits = []
    start = 0
    while True:
        offset = data.find(needle, start)
        if offset < 0:
            return hits
        hits.append(offset)
        start = offset + 1


def audit(rom):
    slot_offset = TABLE_SLOT - ROM_BASE
    if slot_offset < 0 or slot_offset + 4 > len(rom):
        raise ValueError("ROM is too short to contain the IWRAM dispatch slot")
    slot_value = struct.unpack_from("<I", rom, slot_offset)[0]
    if slot_value != TARGET:
        raise ValueError(
            f"dispatch slot at {TABLE_SLOT:#010x} contains {slot_value:#010x}, "
            f"expected {TARGET:#010x}")

    target_locations = _find_all(rom, struct.pack("<I", TARGET))
    if target_locations != [slot_offset]:
        rendered = [hex(ROM_BASE + offset) for offset in target_locations]
        raise ValueError(
            f"target pointer word occurs at unexpected ROM locations: {rendered}")

    slot_address_occurrences = len(_find_all(rom, struct.pack("<I", TABLE_SLOT)))
    return {"target": TARGET, "slot": TABLE_SLOT,
            "target_word_locations": (ROM_BASE + slot_offset,),
            "slot_address_occurrences": slot_address_occurrences}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", type=Path, help="path to the original GBA ROM")
    result = audit(parser.parse_args().rom.read_bytes())
    print(f"PASS: {result['target']:#010x} occurs once at "
          f"{result['slot']:#010x}; slot-address word occurs "
          f"{result['slot_address_occurrences']} times (references not decoded)")


if __name__ == "__main__":
    main()
