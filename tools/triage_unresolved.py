#!/usr/bin/env python3
"""Create a reproducible unresolved-symbol triage report without guessing behavior."""
import argparse
import json
import re
from pathlib import Path

ADDR = re.compile(r'^sub_0([0-9A-Fa-f]{7})$')

def triage(linkage, root):
    sources = sorted((root / 'src').glob('*.c'))
    asm_files = sorted((root / 'asm').rglob('*'))
    asm_files = [p for p in asm_files if p.is_file() and p.suffix in ('.s', '.txt', '.dis')]
    results = []
    for entry in linkage['unresolved_imports']:
        symbol = entry['symbol']
        callsites = []
        for path in sources:
            for number, line in enumerate(path.read_text(errors='replace').splitlines(), 1):
                if re.search(r'\b' + re.escape(symbol) + r'\s*\(', line) and not re.match(r'\s*(extern\s+)?(?:void|int|unsigned|uint\d+_t|size_t|bool)\s+' + re.escape(symbol) + r'\s*\(', line):
                    callsites.append({'file': str(path.relative_to(root)), 'line': number, 'text': line.strip()[:180]})
        m = ADDR.match(symbol)
        address = '0x0' + m.group(1).upper() if m else None
        evidence = []
        if m:
            suffix = m.group(1).lower()
            for path in asm_files:
                name = path.name.lower()
                if any(token in name for token in (suffix, suffix[2:], suffix.lstrip('0'))):
                    evidence.append(str(path.relative_to(root)))
        category = ('compiler_runtime' if symbol.startswith('__aeabi_') else
                    'address_named' if address else 'named_external')
        results.append({'symbol': symbol, 'category': category, 'address': address,
                        'referenced_by': entry['referenced_by'], 'callsites': callsites,
                        'assembly_filename_candidates': evidence,
                        'status': 'unresolved; no implementation inferred'})
    return results

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--linkage', default='build/reports/linkage.json')
    ap.add_argument('--output', default='build/reports/unresolved_triage.json')
    args = ap.parse_args()
    root = Path(__file__).resolve().parent.parent
    report = triage(json.loads(Path(args.linkage).read_text()), root)
    out = Path(args.output); out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2) + '\n')
    print(f'Triaged {len(report)} unresolved symbols; {sum(bool(x["assembly_filename_candidates"]) for x in report)} have assembly filename candidates; report: {out}')
if __name__ == '__main__': main()
