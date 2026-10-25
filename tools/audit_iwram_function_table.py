#!/usr/bin/env python3
"""Audit the mixed runtime-function pointer table near 0x0807D920.

This is a ROM-backed table extraction, not proof of installer behavior or
runtime reachability. Even IWRAM values are reported as ARM-state candidates;
odd ROM pointers are marked Thumb-state candidates by the GBA interworking bit.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
TABLE_START = 0x0807D920
TABLE_END = 0x0807D9A4  # exclusive; immediately before non-pointer data
EXPECTED = {
    0x0807D920: 0x0300717C,
    0x0807D924: 0x030071D0,
    0x0807D928: 0x030072F8,
    0x0807D92C: 0x03007478,
    0x0807D950: 0x08057B65,
    0x0807D954: 0x08057C5D,
    0x0807D958: 0x080607B5,
    0x0807D95C: 0x0806082D,
    0x0807D960: 0x0300616C,
    0x0807D964: 0x08057C5D,
    0x0807D968: 0x0300646C,
    0x0807D96C: 0x0300682C,
    0x0807D970: 0x03006940,
    0x0807D974: 0x03006A20,
    0x0807D978: 0x03006B84,
    0x0807D97C: 0x08057B61,
    0x0807D980: 0x08057B65,
    0x0807D984: 0x08057C5D,
    0x0807D988: 0x03006C60,
    0x0807D98C: 0x03006F10,
    0x0807D990: 0x08057C5D,
    0x0807D994: 0x03006FAC,
    0x0807D998: 0x03007034,
    0x0807D99C: 0x030070B8,
    0x0807D9A0: 0x0300711C,
}


def audit(rom):
    if len(rom) < TABLE_END - ROM_BASE:
        raise ValueError("ROM too short for runtime pointer table")
    rows = []
    for address, expected in EXPECTED.items():
        actual = struct.unpack_from('<I', rom, address - ROM_BASE)[0]
        if actual != expected:
            raise ValueError(f"table mismatch at {address:#010x}: {actual:#010x} != {expected:#010x}")
        in_iwram = 0x03000000 <= actual < 0x03008000
        in_rom = 0x08000000 <= (actual & ~1) < 0x0A000000
        rows.append({
            "slot": f"0x{address:08X}",
            "value": f"0x{actual:08X}",
            "region": "IWRAM" if in_iwram else ("ROM" if in_rom else "other"),
            "isa_candidate": ("ARM" if actual % 2 == 0 else "Thumb") if in_iwram or in_rom else "unknown",
            "semantics": "unresolved",
        })
    iwram_targets = sorted({int(r['value'], 16) for r in rows if r['region'] == 'IWRAM'})
    return {
        "rom_size": len(rom),
        "rom_sha256": hashlib.sha256(rom).hexdigest(),
        "table_start": f"0x{TABLE_START:08X}",
        "table_end_exclusive": f"0x{TABLE_END:08X}",
        "verified_entries": len(rows),
        "iwram_target_count": len(iwram_targets),
        "iwram_targets": [f"0x{x:08X}" for x in iwram_targets],
        "target_gaps": [
            {"from": f"0x{a:08X}", "to": f"0x{b:08X}", "gap": b-a}
            for a, b in zip(iwram_targets, iwram_targets[1:])
        ],
        "entries": rows,
        "limitations": [
            "Pointer values do not prove runtime reachability or installation source.",
            "Even IWRAM pointers are ARM-state candidates, not verified disassemblies.",
            "Gaps between entry addresses are not function sizes."
        ],
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--json', type=Path)
    args = ap.parse_args()
    result = audit(args.rom.read_bytes())
    print(f"PASS: {result['verified_entries']} pointer-table entries verified; "
          f"{result['iwram_target_count']} distinct IWRAM targets")
    for target in result['iwram_targets']:
        print(f"  {target}")
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
