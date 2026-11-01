#!/usr/bin/env python3
"""ROM-backed Thumb entry candidate discovery, not function recovery.

Collect word-aligned odd ROM pointers, confirm only whether the target begins
with a recognizable PUSH/STMDB prologue, and independently decode Thumb BLs
in a bounded region. No inferred entry is treated as a proved function.
"""
import argparse, collections, hashlib, json, struct
from pathlib import Path
BASE=0x08000000
SIZE=0x800000
EXPECTED="a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce"

def signed(value,bits):
    sign=1<<(bits-1)
    return (value^sign)-sign

def decode_bl(pc,first,second):
    """ARMv4T two-halfword Thumb BL immediate; pc is first halfword ROM address."""
    if (first&0xF800)!=0xF000 or (second&0xF800)!=0xF800:
        return None
    disp=signed(((first&0x7FF)<<12)|((second&0x7FF)<<1),23)
    return (pc+4+disp)&0xFFFFFFFF

def scan(data,limit=0x80000):
    if len(data)!=SIZE: raise ValueError('expected 8 MiB ROM')
    if limit<4 or limit>SIZE or limit%4: raise ValueError('limit must be 4-byte aligned and within ROM')
    counts=collections.Counter()
    refs=collections.defaultdict(list)
    for off in range(0,SIZE-3,4):
        word=struct.unpack_from('<I',data,off)[0]
        if (word&1)==0: continue
        dest=word&~1
        if not BASE<=dest<BASE+SIZE: continue
        counts['rom_odd_word_refs']+=1
        target=dest-BASE
        op=struct.unpack_from('<H',data,target)[0]
        # PUSH {...,lr} in Thumb: 0xB5xx; PUSH without LR also possible but weaker.
        if (op&0xFF00)==0xB500:
            counts['refs_to_push_lr']+=1
            refs[dest].append(BASE+off)
    bl_counts=collections.Counter()
    examples=[]
    # Linear BL-pattern scan is only a candidate scan: literal/data false positives possible.
    for off in range(0,limit-3,2):
        first,second=struct.unpack_from('<HH',data,off)
        dest=decode_bl(BASE+off,first,second)
        if dest is None or not BASE<=dest<BASE+SIZE: continue
        bl_counts[dest]+=1
        if len(examples)<32: examples.append({'callsite':BASE+off,'target':dest})
    overlap=sorted(set(refs)&set(bl_counts))
    entries=[{'target':addr,'pointer_refs':len(refs[addr]),'sample_pointer_sites':refs[addr][:8],
              'bl_pattern_refs':bl_counts[addr]} for addr in sorted(refs)]
    return {'pass_number':74,'rom_sha256':hashlib.sha256(data).hexdigest(),
            'matches_expected_rom':hashlib.sha256(data).hexdigest()==EXPECTED,
            'rom_size':SIZE,'linear_bl_scan_bytes':limit,
            'counts':dict(counts),'distinct_push_lr_targets':len(refs),
            'linear_bl_patterns_in_range':sum(bl_counts.values()),
            'distinct_bl_pattern_targets':len(bl_counts),
            'pointer_and_bl_overlap_targets':len(overlap),
            'overlap_target_samples':overlap[:64],
            'bl_pattern_samples':examples,'entry_candidates':entries,
            'limitations':[
              'Odd ROM words can be non-pointer data, even when they point to a PUSH opcode.',
              'PUSH prologues are common but not mandatory for real Thumb functions.',
              'Linear BL-pattern scanning may misinterpret literal pools and asset data as instructions.',
              'No byte count from this scan is credited as reconstructed/decompiled code.',
              'Full 8 MiB pointer-word scan; BL-pattern scan only in the configured bounded prefix.']}

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('rom',type=Path)
    parser.add_argument('--json',type=Path,required=True)
    parser.add_argument('--bl-limit',type=lambda x:int(x,0),default=0x80000)
    args=parser.parse_args()
    report=scan(args.rom.read_bytes(),args.bl_limit)
    args.json.parent.mkdir(parents=True,exist_ok=True)
    args.json.write_text(json.dumps(report,indent=2)+'\n')
    print('Pass 74:',report['counts'],'distinct candidates:',report['distinct_push_lr_targets'],
          'BL patterns:',report['linear_bl_patterns_in_range'],'overlap:',report['pointer_and_bl_overlap_targets'])
if __name__=='__main__':main()
