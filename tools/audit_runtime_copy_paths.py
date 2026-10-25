#!/usr/bin/env python3
"""Inventory Thumb BL call sites for known ROM copy/decompression helpers.

This is an address-level cross-reference aid. It extracts instruction windows
around statically encoded Thumb BL pairs and deliberately does not infer runtime
argument values, destination ranges, or whether a resource is executable code.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
SCAN_START = 0x08040000
SCAN_END = 0x08070000
TARGETS = {
    0x080578E4: "System_CpuSet_wrapper",
    0x080578F4: "System_LZ77UnCompWram_wrapper",
    0x08057968: "System_InstallIwramBlock",
    0x08065994: "DMA3_transfer_backend",
}


def sgn(v, bits):
    return v - (1 << bits) if v & (1 << (bits - 1)) else v


def audit(rom, context_halfwords=8):
    if len(rom) < 0x200:
        raise ValueError("ROM too short for GBA image analysis")
    if context_halfwords < 0 or context_halfwords > 64:
        raise ValueError("context_halfwords must be in [0, 64]")
    start = max(0, SCAN_START - ROM_BASE)
    end = min(len(rom) - 3, SCAN_END - ROM_BASE)
    calls = []
    for off in range(start, end, 2):
        hi = struct.unpack_from('<H', rom, off)[0]
        if (hi & 0xF800) != 0xF000:
            continue
        lo = struct.unpack_from('<H', rom, off + 2)[0]
        if (lo & 0xF800) != 0xF800:
            continue
        disp = (sgn(hi & 0x7FF, 11) << 12) + ((lo & 0x7FF) << 1)
        target = ROM_BASE + off + 4 + disp
        if target not in TARGETS:
            continue
        left = max(0, off - context_halfwords * 2)
        right = min(len(rom) - 1, off + 4 + context_halfwords * 2)
        window = []
        for pos in range(left, right, 2):
            half = struct.unpack_from('<H', rom, pos)[0]
            window.append({"address": f"0x{ROM_BASE + pos:08X}",
                           "halfword": f"0x{half:04X}",
                           "is_call_halfword": pos in (off, off + 2)})
        calls.append({
            "call_site": f"0x{ROM_BASE + off:08X}",
            "call_target": f"0x{target:08X}",
            "target_name": TARGETS[target],
            "bl_prefix": f"0x{hi:04X}",
            "bl_suffix": f"0x{lo:04X}",
            "context_halfwords_each_side": context_halfwords,
            "instruction_window": window,
        })
    calls.sort(key=lambda row: (int(row["call_target"], 16), int(row["call_site"], 16)))
    counts = {name: sum(row["target_name"] == name for row in calls) for name in TARGETS.values()}
    return {
        "rom_size": len(rom),
        "rom_sha256": hashlib.sha256(rom).hexdigest(),
        "scan_range": [f"0x{SCAN_START:08X}", f"0x{SCAN_END:08X}"],
        "call_count": len(calls),
        "counts_by_target": counts,
        "calls": calls,
        "limitations": [
            "Thumb BL encodings can occur in data; address ranges and surrounding instructions are heuristic evidence, not proof of reachability.",
            "The report records call sites and raw instruction windows only; it does not emulate registers or infer argument values.",
            "A decompression or copy call does not establish that its output is executable code or the source of IWRAM target 0x03007034.",
            "Calls outside the configured scan range and indirect calls are not included."
        ]
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--json', type=Path)
    ap.add_argument('--context-halfwords', type=int, default=8)
    args = ap.parse_args()
    result = audit(args.rom.read_bytes(), args.context_halfwords)
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')
    print(f"ROM {result['rom_sha256']}")
    print(f"Static helper calls in scan range: {result['call_count']}")
    for name, count in result['counts_by_target'].items():
        print(f"  {name}: {count}")
    for row in result['calls']:
        print(f"{row['call_site']} -> {row['call_target']} {row['target_name']}")

if __name__ == '__main__':
    main()
