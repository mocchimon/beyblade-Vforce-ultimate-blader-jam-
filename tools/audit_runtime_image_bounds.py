#!/usr/bin/env python3
"""Audit whether the known ARM runtime image can contain selected IWRAM targets.

The candidate base is explicitly hypothetical. This tool performs range arithmetic
only; it does not claim that the image is installed at that base.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
IMAGE_START = 0x080641B8
IMAGE_END = 0x08064EDC  # exclusive; relocation table starts here
HYPOTHETICAL_IWRAM_BASE = 0x030061B8
TARGETS = {
    "render_backend_a": 0x0300646C,
    "render_backend_b": 0x0300682C,
    "background_operation": 0x03006FAC,
    "runtime_copy_callback": 0x03007034,
}


def audit(rom):
    start = IMAGE_START - ROM_BASE
    end = IMAGE_END - ROM_BASE
    if start < 0 or end > len(rom) or end <= start:
        raise ValueError("ROM is too short to contain the known ARM runtime image")
    image = rom[start:end]
    size = len(image)
    rows = []
    for name, target in TARGETS.items():
        offset = target - HYPOTHETICAL_IWRAM_BASE
        rows.append({
            "name": name,
            "target": f"0x{target:08X}",
            "offset_from_hypothetical_base": offset,
            "inside_image_if_base_assumed": 0 <= offset < size,
            "distance_outside_image": 0 if 0 <= offset < size else (offset - size if offset >= size else -offset),
        })
    return {
        "image_start": f"0x{IMAGE_START:08X}",
        "image_end_exclusive": f"0x{IMAGE_END:08X}",
        "image_size": size,
        "image_sha256": hashlib.sha256(image).hexdigest(),
        "relocation_table_starts_at": f"0x{IMAGE_END:08X}",
        "hypothetical_iwram_base": f"0x{HYPOTHETICAL_IWRAM_BASE:08X}",
        "base_is_proven": False,
        "targets": rows,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("rom", type=Path)
    ap.add_argument("--json", type=Path)
    args = ap.parse_args()
    result = audit(args.rom.read_bytes())
    print(f"Image {result['image_start']}..{result['image_end_exclusive']} "
          f"({result['image_size']:#x} bytes), SHA256 {result['image_sha256']}")
    print(f"Hypothetical runtime base {result['hypothetical_iwram_base']} (UNPROVEN)")
    for row in result["targets"]:
        state = "inside" if row["inside_image_if_base_assumed"] else "outside"
        print(f"{row['name']}: {row['target']} offset="
              f"{row['offset_from_hypothetical_base']:#x}: {state}; "
              f"distance outside={row['distance_outside_image']:#x}")
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
