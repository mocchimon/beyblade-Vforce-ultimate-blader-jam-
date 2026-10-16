#!/usr/bin/env python3
"""Inventory ARM object definitions, cross-unit dependencies and unresolved imports.

No ROM is required. This is an evidence inventory, not decompilation coverage.
"""
import argparse
import collections
import json
from pathlib import Path
import re
import subprocess

NM_LINE = re.compile(r'^\s*(?:(?:[0-9a-fA-F]+)\s+)?([A-Za-z])\s+(\S+)\s*$')

def parse_nm(output):
    defined, undefined = set(), set()
    for line in output.splitlines():
        m = NM_LINE.match(line)
        if not m:
            continue
        kind, symbol = m.groups()
        if kind.upper() == 'U':
            undefined.add(symbol)
        elif kind.isupper() and kind not in ('N', '?'):
            defined.add(symbol)
    return defined, undefined

def audit(objects, nm='nm'):
    definitions = collections.defaultdict(list)
    imports = {}
    for obj in sorted(objects):
        result = subprocess.run([nm, '-g', str(obj)], capture_output=True, text=True, check=True)
        defined, undefined = parse_nm(result.stdout)
        for name in defined:
            definitions[name].append(obj.stem)
        imports[obj.stem] = undefined
    unresolved = collections.defaultdict(list)
    edges = []
    for unit, symbols in sorted(imports.items()):
        for sym in sorted(symbols):
            providers = definitions.get(sym)
            if providers:
                edges.append({'caller': unit, 'symbol': sym, 'providers': sorted(providers)})
            else:
                unresolved[sym].append(unit)
    return {
        'object_count': len(imports),
        'defined_symbol_count': len(definitions),
        'cross_unit_references': edges,
        'unresolved_imports': [{'symbol': s, 'referenced_by': sorted(unresolved[s])} for s in sorted(unresolved)],
        'duplicate_definitions': {s: v for s, v in sorted(definitions.items()) if len(v) > 1},
        'unresolved_by_unit': {unit: sorted(s for s in symbols if s not in definitions) for unit, symbols in sorted(imports.items())},
    }

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--objects', default='build/objects')
    parser.add_argument('--output', default='build/reports/linkage.json')
    parser.add_argument('--nm', default='nm')
    args = parser.parse_args()
    objects = list(Path(args.objects).glob('*.o'))
    if not objects:
        parser.error('no ARM object files found: run make check first')
    result = audit(objects, args.nm)
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + '\n')
    print(f"{result['object_count']} objects, {result['defined_symbol_count']} definitions, "
          f"{len(result['cross_unit_references'])} internal imports, "
          f"{len(result['unresolved_imports'])} unresolved external symbols")
    print(f'Report: {out}')

if __name__ == '__main__':
    main()
