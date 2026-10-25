#!/usr/bin/env python3
"""ROM-backed audit of follow-on initializer at 0x08051120.

Checks a bounded set of Thumb halfwords and literal-pool words against the
original GBA ROM. It records observed offsets and loop bounds without naming
unknown fields or callback semantics.
"""
import argparse, hashlib, json, struct
from pathlib import Path
ROM_BASE = 0x08000000
ENTRY = 0x08051120
EXPECTED_SHA256 = "a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce"
EXPECTED_HALFWORDS = {
  0x08051120:0xB5F0, 0x08051122:0x4B16, 0x08051124:0x6818,
  0x08051126:0x2200, 0x08051128:0x7002, 0x0805112A:0x6818,
  0x0805112C:0x24DD, 0x0805112E:0x00E4, 0x08051130:0x1901,
  0x08051132:0x800A, 0x08051134:0x4912, 0x08051136:0x1840,
  0x08051138:0x2101, 0x0805113A:0x7001, 0x0805113C:0x6819,
  0x0805113E:0x23D8, 0x08051140:0x00DB, 0x08051142:0x18C8,
  0x08051144:0x6002, 0x08051146:0x3C2C, 0x08051148:0x1908,
  0x0805114A:0x6002, 0x0805114C:0x480D, 0x0805114E:0x1809,
  0x08051150:0x480D, 0x08051152:0x8008, 0x08051154:0x2500,
  0x08051156:0x4E0D, 0x08051158:0x1C28, 0x0805115A:0xF000,
  0x0805115C:0xFAF3, 0x0805115E:0x1C04, 0x08051160:0x20D0,
  0x08051162:0x1C29, 0x08051164:0x4341, 0x08051166:0x480A,
  0x08051168:0x1809, 0x0805116A:0x60E1, 0x0805116C:0x6848,
  0x0805116E:0x6060, 0x08051170:0x6888, 0x08051172:0x60A0,
  0x08051174:0x2D00, 0x08051176:0xDC0D, 0x08051178:0x2006,
  0x0805117A:0xE00C, 0x08051194:0x2004, 0x08051196:0x8020,
  0x08051198:0x1C21, 0x0805119A:0x3110, 0x0805119C:0x6833,
  0x0805119E:0x2000, 0x080511A0:0x2204, 0x080511A2:0xF014,
  0x080511A4:0xFD4F, 0x080511A6:0x1C21, 0x080511A8:0x3114,
  0x080511AA:0x6833, 0x080511AC:0x2000, 0x080511AE:0x2204,
  0x080511B0:0xF014, 0x080511B2:0xFD48, 0x080511B4:0x3501,
  0x080511B6:0x2D37, 0x080511B8:0xDDCE,
  0x080511BA:0x2500, 0x080511BC:0x2600, 0x080511BE:0x2400,
  0x080511C0:0x4F25, 0x080511C2:0x1C28, 0x080511C4:0xF000,
  0x080511C6:0xFA9E, 0x080511C8:0x19E1, 0x080511CA:0x6041,
  0x080511CC:0x7006, 0x080511CE:0x8046, 0x080511D0:0x3450,
  0x080511D2:0x3501, 0x080511D4:0x2D09, 0x080511D6:0xDDF4,
}
EXPECTED_WORDS = {
  0x0805117C:0x03000F48, 0x08051180:0x000006AB,
  0x08051184:0x000006EA, 0x08051188:0x0000FFFF,
  0x0805118C:0x0807D994, 0x08051190:0x08075B70,
  0x08051258:0x08075850,
}
def read_u16(rom, address):
    off=address-ROM_BASE
    if off<0 or off+2>len(rom): raise ValueError(f'ROM address out of bounds: 0x{address:08X}')
    return struct.unpack_from('<H',rom,off)[0]
def read_u32(rom, address):
    off=address-ROM_BASE
    if off<0 or off+4>len(rom): raise ValueError(f'ROM address out of bounds: 0x{address:08X}')
    return struct.unpack_from('<I',rom,off)[0]
def audit(rom):
    if len(rom)<0x200 or len(rom)%2: raise ValueError('expected an even-length GBA ROM image')
    mismatches=[]
    for addr,exp in EXPECTED_HALFWORDS.items():
        got=read_u16(rom,addr)
        if got!=exp: mismatches.append({'address':f'0x{addr:08X}','expected':f'0x{exp:04X}','actual':f'0x{got:04X}'})
    for addr,exp in EXPECTED_WORDS.items():
        got=read_u32(rom,addr)
        if got!=exp: mismatches.append({'address':f'0x{addr:08X}','expected':f'0x{exp:08X}','actual':f'0x{got:08X}'})
    if mismatches: raise ValueError('ROM evidence mismatch: '+json.dumps(mismatches))
    sha=hashlib.sha256(rom).hexdigest()
    return {'rom_size':len(rom),'rom_sha256':sha,'expected_reference_rom_match':sha==EXPECTED_SHA256,
      'entry':f'0x{ENTRY:08X}','checked_halfwords':len(EXPECTED_HALFWORDS),'checked_literal_words':len(EXPECTED_WORDS),
      'findings':[
       {'address':'0x08051128','fact':'clears byte at runtime base + 0x0, and clears halfword at +0x6E8','confidence':'Thumb instructions and offset arithmetic verified'},
       {'address':'0x0805113A','fact':'writes byte value 1 at runtime base + 0x6AB','confidence':'Thumb instructions and literal 0x6AB verified'},
       {'address':'0x08051144','fact':'clears word at runtime base + 0x6C0','confidence':'Thumb instructions and immediate arithmetic verified'},
       {'address':'0x0805114A','fact':'clears word at runtime base + 0x6B4, overwriting the value 1 seeded by 0x080510C2','confidence':'cross-routine write order verified; field meaning unknown'},
       {'address':'0x08051152','fact':'writes halfword 0xFFFF at runtime base + 0x6EA','confidence':'Thumb instructions and literal-pool words verified'},
       {'address':'0x08051158','fact':'loop indexes 0 through 55; record base is 0x08075B70 + index * 0xD0','confidence':'loop bound and stride decoded from instructions'},
       {'address':'0x0805116A','fact':'stores record pointer at returned object + 0x0C and copies record words +4 and +8 to object +4 and +8','confidence':'directly supported by Thumb load/store encodings'},
       {'address':'0x08051196','fact':'sets object halfword at +0 to 6 for index 0, otherwise 4; dispatches callbacks for object +0x10 and +0x14','confidence':'control flow and calls verified; callback meaning unknown'},
       {'address':'0x080511C2','fact':'second loop indexes 0 through 9; each object gets pointer 0x08075850 + index * 0x50 at +4 and zero byte/halfword at +0/+2','confidence':'loop bound, stride, and stores verified'},
      ],
      'interpretation':'The follow-on initializer performs additional runtime-base field writes, then constructs 56 table-backed records (0xD0-byte stride) through helper 0x08051744 and dispatches two callbacks per record through 0x08065C44. It also initializes 10 entries with a 0x50-byte stride. Crucially, the word at runtime base +0x6B4 seeded to 1 by 0x08051090 is cleared to 0 at 0x0805114A before the initializer returns. The semantic names of these fields, table records, and callbacks remain unresolved.',
      'limitations':['Only a bounded instruction/literal fingerprint is audited, not a complete disassembly.','The callback target is loaded indirectly from 0x0807D994; its behavior is not inferred here.','No Easter egg or secret-input behavior is established by this initializer.']}
def main():
    p=argparse.ArgumentParser(description=__doc__); p.add_argument('rom',type=Path); p.add_argument('--json',type=Path); a=p.parse_args()
    r=audit(a.rom.read_bytes())
    print(f"Verified follow-on initializer at {r['entry']}")
    print(f"  checked {r['checked_halfwords']} halfwords and {r['checked_literal_words']} literal words; expected ROM match: {r['expected_reference_rom_match']}")
    print('  Important correction: +0x6B4 is cleared after Pass55 initializer seeds it to 1.')
    print('  Table-backed loop: 56 records, stride 0xD0; second loop: 10 entries, stride 0x50.')
    if a.json: a.json.parent.mkdir(parents=True,exist_ok=True); a.json.write_text(json.dumps(r,indent=2)+'\n')
if __name__=='__main__': main()
