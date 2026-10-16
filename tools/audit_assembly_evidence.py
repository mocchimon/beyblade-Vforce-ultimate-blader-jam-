#!/usr/bin/env python3
"""Inventory evidence in archived Thumb listings; never infer ROM verification."""
import argparse
import json
import re
from pathlib import Path

LINE = re.compile(r'^\s*([0-9a-fA-F]{5,8}):\s+((?:[0-9a-fA-F]{4}(?:\s+|$)){1,2})\s+([a-z][a-z0-9.]*)\s*(.*)$')
TARGET = re.compile(r'\b0x([0-9a-fA-F]{5,8})\b')
BRANCHES = {'bl', 'blx', 'b', 'bx'}

def analyze(path):
    instructions = []
    for line in path.read_text(errors='replace').splitlines():
        m = LINE.match(line)
        if not m:
            continue
        addr, encoding, mnemonic, operands = m.groups()
        targets = [int(t, 16) for t in TARGET.findall(operands.split('@')[0])]
        instructions.append({'address': int(addr,16), 'mnemonic': mnemonic, 'operands': operands.strip(), 'targets': targets, 'bytes': len(re.findall(r'\b[0-9a-fA-F]{4}\b',encoding))*2})
    if not instructions:
        return {'file': str(path), 'instructions': 0, 'warning': 'no decoded instructions'}
    addresses = {i['address'] for i in instructions}
    calls = sorted({t for i in instructions if i['mnemonic'] in ('bl','blx') for t in i['targets']})
    branches = sorted({t for i in instructions if i['mnemonic'].startswith('b') and i['mnemonic'] not in ('bl','blx','bx') for t in i['targets']})
    writes = [i['address'] for i in instructions if i['mnemonic'].startswith(('str','stm','push'))]
    loads = [i['address'] for i in instructions if i['mnemonic'].startswith(('ldr','ldm','pop'))]
    return {'file':str(path),'start':hex(min(addresses)),'last_instruction':hex(max(addresses)),
            'instructions':len(instructions),'call_targets':[hex(t) for t in calls],
            'internal_call_targets':[hex(t) for t in calls if t in addresses],
            'external_call_targets':[hex(t) for t in calls if t not in addresses],
            'branch_targets':[hex(t) for t in branches],
            'branch_targets_outside_listing':[hex(t) for t in branches if t not in addresses],
            'memory_write_instructions':len(writes),'memory_read_instructions':len(loads),
            'has_return_pattern':any(i['mnemonic']=='bx' and i['operands'].startswith('lr') or i['mnemonic']=='pop' and 'pc' in i['operands'] for i in instructions),
            'ends_at_file_boundary':True,
            'caution':'archived listing may be partial, branch target may be outside listing; not ROM verified'}

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--directory',default='asm/pass5')
    p.add_argument('--output',default='build/reports/assembly_evidence.json')
    args=p.parse_args()
    paths=sorted(Path(args.directory).glob('*.s'))
    results=[analyze(path) for path in paths]
    out=Path(args.output);out.parent.mkdir(parents=True,exist_ok=True)
    out.write_text(json.dumps({'files':results,'totals':{'listings':len(results),'decoded_instructions':sum(r['instructions'] for r in results),'distinct_external_calls':len(set(t for r in results for t in r.get('external_call_targets',[]))) }},indent=2)+'\n')
    print(f'Audited {len(results)} listings; report: {out}')
if __name__=='__main__':main()
