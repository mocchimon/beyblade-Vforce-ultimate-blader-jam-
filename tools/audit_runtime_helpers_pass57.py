#!/usr/bin/env python3
"""ROM-verified helper geometry and callback pointer indirection, Pass 57."""
import argparse,hashlib,json,struct
from pathlib import Path
BASE=0x08000000
EXPECTED_SHA256='a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce'
HALFWORDS={134551300: 18691, 134551302: 192, 134551304: 18947, 134551306: 6272, 134551308: 26633, 134551310: 6153, 134551312: 7176, 134551314: 18288, 134551364: 18947, 134551366: 65, 134551368: 6153, 134551370: 201, 134551372: 12548, 134551374: 26640, 134551376: 6208, 134551378: 18288, 134634564: 18200, 134551460: 7169, 134551462: 18435, 134551464: 26624, 134551466: 18947, 134551468: 6272, 134551470: 26624, 134551472: 16392, 134551474: 18288}
WORDS={134551316: 50335560, 134551320: 1348, 134551380: 50335560, 134551476: 50335560, 134551480: 1716, 134549900: 134732180, 134732180: 50360236}
def audit(data):
    if len(data)!=0x800000: raise ValueError('expected 8 MiB ROM')
    mismatches=[]
    for addr,expected in HALFWORDS.items():
        actual=struct.unpack_from('<H',data,addr-BASE)[0]
        if actual!=expected:mismatches.append(f'{addr:#010x}: {actual:#06x} != {expected:#06x}')
    for addr,expected in WORDS.items():
        actual=struct.unpack_from('<I',data,addr-BASE)[0]
        if actual!=expected:mismatches.append(f'{addr:#010x}: {actual:#010x} != {expected:#010x}')
    if mismatches:raise ValueError('ROM evidence mismatch: '+', '.join(mismatches))
    digest=hashlib.sha256(data).hexdigest()
    return {'rom_sha256':digest,'reference_rom_match':digest==EXPECTED_SHA256,'checked_halfwords':len(HALFWORDS),'checked_words':len(WORDS),'runtime_slot':'0x03000F48','helper_08051704':{'base_offset':'0x544','stride':'0x8','formula':'runtime_base + 0x544 + index * 8','pass56_entries':10},'helper_08051744':{'base_offset':'0x4','stride':'0x18','formula':'runtime_base + 4 + index * 24','pass56_entries':56},'callback':{'dispatch_site':'0x08065C44','instruction':'BX R3','rom_pointer_slot':'0x0807D994','ram_pointer_slot':'0x03006FAC','interpretation':'RAM slot holds runtime callback address; target cannot be determined statically from this ROM literal'},'bitmask_helper_080517A4':{'formula':'input_mask & *(runtime_base + 0x6B4)','initial_state_after_08051120':0},'limitations':['No callback target is proven; requires tracing writes to RAM 0x03006FAC.','No secret or Easter egg behavior is established.']}
def main():
    p=argparse.ArgumentParser();p.add_argument('rom',type=Path);p.add_argument('--json',type=Path);a=p.parse_args()
    report=audit(a.rom.read_bytes());print(json.dumps(report,indent=2))
    if a.json:a.json.parent.mkdir(parents=True,exist_ok=True);a.json.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':main()
