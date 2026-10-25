#!/usr/bin/env python3
"""ROM-backed local control-flow audit for Thumb routine 0x08051090.

This is a bounded decoder for the known Thumb instruction forms in this routine,
not a whole-ROM disassembler. It resolves Thumb BL pairs, conditional branch
0xD103, and PC-relative LDR literals, then records the surrounding halfwords of
callee entry points needed to reason about the runtime-base slot write.
"""
import argparse
import hashlib
import json
import struct
from pathlib import Path

ROM_BASE = 0x08000000
ENTRY = 0x08051090
END = 0x080510F8
TARGETS = (0x0805A444, 0x08057C5C, 0x08051120)


def u16(data, off):
    return struct.unpack_from('<H', data, off)[0]


def rom_u16(rom, address):
    off = address - ROM_BASE
    if off < 0 or off + 2 > len(rom):
        raise ValueError(f'address outside ROM: 0x{address:08X}')
    return u16(rom, off)


def sign_extend(value, bits):
    sign = 1 << (bits - 1)
    return (value ^ sign) - sign


def decode_bl_target(address, first, second):
    if first & 0xF800 != 0xF000 or second & 0xF800 != 0xF800:
        raise ValueError('not a Thumb BL pair')
    displacement = ((first & 0x07FF) << 12) | ((second & 0x07FF) << 1)
    displacement = sign_extend(displacement, 23)
    return (address + 4 + displacement) & 0xFFFFFFFF


def literal_address(address, insn):
    if insn & 0xF800 != 0x4800:
        raise ValueError('not a Thumb LDR literal')
    pc = (address + 4) & ~3
    return pc + ((insn & 0xFF) * 4)


def scan(rom):
    if len(rom) < 0x200 or len(rom) % 2:
        raise ValueError('expected an even-length GBA ROM image')
    instructions = []
    addr = ENTRY
    while addr < END:
        insn = rom_u16(rom, addr)
        row = {'address': f'0x{addr:08X}', 'halfword': f'0x{insn:04X}'}
        if insn & 0xF800 == 0xF000 and addr + 2 < END:
            second = rom_u16(rom, addr + 2)
            target = decode_bl_target(addr, insn, second)
            row.update({'mnemonic': 'BL', 'second_halfword': f'0x{second:04X}',
                        'target': f'0x{target:08X}'})
            instructions.append(row)
            addr += 4
            continue
        if insn & 0xF800 == 0x4800:
            lit = literal_address(addr, insn)
            off = lit - ROM_BASE
            value = u16(rom, off) | (u16(rom, off + 2) << 16)
            row.update({'mnemonic': 'LDR_literal', 'literal_address': f'0x{lit:08X}',
                        'literal_value': f'0x{value:08X}'})
        elif insn & 0xF000 == 0xD000 and (insn & 0x0F00) != 0x0F00:
            disp = sign_extend(insn & 0xFF, 8) * 2
            row.update({'mnemonic': 'conditional_branch',
                        'condition': {0:'EQ',1:'NE',2:'CS/HS',3:'CC/LO',4:'MI',5:'PL',6:'VS',7:'VC',8:'HI',9:'LS',10:'GE',11:'LT',12:'GT',13:'LE'}.get((insn >> 8) & 0xF, 'unknown'),
                        'target': f'0x{(addr + 4 + disp) & 0xFFFFFFFF:08X}'})
        instructions.append(row)
        addr += 2
    target_context = []
    for target in TARGETS:
        words = [f'0x{rom_u16(rom, target + i*2):04X}' for i in range(4)]
        target_context.append({'address': f'0x{target:08X}', 'halfwords': words})
    # The branch at 0x0805109E is BNE to 0x080510A8, so the slot store is
    # reached with r4 != 0 on the taken path. The fall-through path executes
    # the BL at 0x080510A4 before joining at 0x080510A8.
    return {
        'rom_size': len(rom), 'rom_sha256': hashlib.sha256(rom).hexdigest(),
        'entry': f'0x{ENTRY:08X}', 'end_exclusive': f'0x{END:08X}',
        'instructions': instructions, 'callee_entry_context': target_context,
        'control_flow_findings': [
            {'address':'0x08051096','kind':'BL','target':'0x0805A444','meaning':'return value copied into r4 at 0x0805109A'},
            {'address':'0x0805109E','kind':'BNE','target':'0x080510A8','meaning':'taken only when r4 != 0; skips the fallback call at 0x080510A4'},
            {'address':'0x080510A4','kind':'BL','target':'0x08057C5C','meaning':'executed on the r4 == 0 fall-through path'},
            {'address':'0x080510A8','kind':'LDR_LITERAL','literal_address':'0x08051104','literal_value':'0x03000F48'},
            {'address':'0x080510AA','kind':'LDR','meaning':'loads r1 from [r4, #0]'},
            {'address':'0x080510AC','kind':'STR','meaning':'stores r1 to [r3, #0], where r3 holds address 0x03000F48'}
        ],
        'interpretation': 'The slot store is real at the encoding level. Normal-path provenance depends on the return value from 0x0805A444. If that value is zero, execution calls 0x08057C5C before joining at 0x080510A8; this path and the subsequent [r4] load need further semantic investigation. Do not yet label this a proven initializer.',
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--json', type=Path)
    args = ap.parse_args()
    result = scan(args.rom.read_bytes())
    print(f"Routine audit at {result['entry']}: {len(result['instructions'])} decoded halfword/BL records")
    for row in result['control_flow_findings']:
        detail = row.get('target') or row.get('literal_value') or row.get('meaning', '')
        print(f"  {row['address']}: {row['kind']} -> {detail}")
    print('NOTE: bounded local decoding only; no full control-flow proof.')
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')

if __name__ == '__main__':
    main()
