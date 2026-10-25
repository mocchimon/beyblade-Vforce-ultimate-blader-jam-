#!/usr/bin/env python3
"""Find literal-load references relevant to the unresolved IWRAM code installer.

This is a conservative xref inventory, not a disassembler or proof that every
hit is executable code. It reports Thumb LDR-literal instructions whose aligned
literal word is an IWRAM address in 0x03006000..0x03007FFF, or a DMA register
address used by known ROM copy paths. Resource-area false positives are kept
and explicitly classified instead of being silently discarded.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
IWRAM_LO = 0x03006000
IWRAM_HI = 0x03008000
DMA_REGS = {
    0x040000D0: "DMA2CNT_L",
    0x040000D4: "DMA3SAD",
    0x040000D8: "DMA3DAD",
    0x040000DC: "DMA3CNT_L",
    0x040000DE: "DMA3CNT_H",
}


def audit(rom):
    if len(rom) < 0x200:
        raise ValueError("ROM too short for GBA image analysis")
    words = {}
    for off in range(0, len(rom) - 3, 4):
        value = struct.unpack_from('<I', rom, off)[0]
        if IWRAM_LO <= value < IWRAM_HI or value in DMA_REGS:
            words[ROM_BASE + off] = value
    refs = []
    for off in range(0, len(rom) - 1, 2):
        insn = struct.unpack_from('<H', rom, off)[0]
        if (insn & 0xF800) != 0x4800:  # Thumb LDR Rd, [PC, #imm]
            continue
        pc = (ROM_BASE + off + 4) & ~3
        literal_address = pc + ((insn & 0xFF) << 2)
        if literal_address not in words:
            continue
        value = words[literal_address]
        if IWRAM_LO <= value < IWRAM_HI:
            kind = "iwram_address_literal"
        else:
            kind = "dma_register_literal"
        # ROM's upper half contains large resource/data regions; preserve hits but
        # label them as lower-confidence xrefs rather than assuming code.
        region = "main_rom_code_candidate" if 0x08040000 <= ROM_BASE + off < 0x08070000 else "other_rom_region"
        refs.append({
            "instruction": f"0x{ROM_BASE + off:08X}",
            "instruction_halfword": f"0x{insn:04X}",
            "literal_address": f"0x{literal_address:08X}",
            "literal_value": f"0x{value:08X}",
            "kind": kind,
            "register_name": DMA_REGS.get(value),
            "region_class": region,
        })
    return {
        "rom_size": len(rom),
        "rom_sha256": hashlib.sha256(rom).hexdigest(),
        "scan": {"iwram_range": [f"0x{IWRAM_LO:08X}", f"0x{IWRAM_HI:08X}"],
                 "dma_registers": {f"0x{k:08X}": v for k, v in DMA_REGS.items()},
                 "thumb_halfword_aligned_scan": True},
        "reference_count": len(refs),
        "iwram_literal_references": sum(x["kind"] == "iwram_address_literal" for x in refs),
        "dma_register_references": sum(x["kind"] == "dma_register_literal" for x in refs),
        "references": refs,
        "limitations": [
            "A matching Thumb LDR-literal encoding does not prove the halfword is executable code.",
            "A literal reference to a DMA register does not by itself establish transfer source, destination, or length.",
            "No match for a destination address does not rule out computed addresses, BIOS decompression, or runtime-generated code.",
            "This report does not establish the installer/source for IWRAM target 0x03007034."
        ]
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    parser.add_argument('--json', type=Path)
    args = parser.parse_args()
    result = audit(args.rom.read_bytes())
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')
    print(f"ROM {result['rom_sha256']}")
    print(f"LDR-literal candidates: {result['reference_count']} total; "
          f"{result['iwram_literal_references']} IWRAM-address and "
          f"{result['dma_register_references']} DMA-register references")
    for row in result['references']:
        print(f"{row['instruction']} {row['kind']} {row['literal_value']} "
              f"[{row['region_class']}]")

if __name__ == '__main__':
    main()
