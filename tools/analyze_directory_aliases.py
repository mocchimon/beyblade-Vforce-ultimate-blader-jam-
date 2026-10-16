#!/usr/bin/env python3
"""Read-only analysis of shared directory descriptors, tables, and selected records."""
import argparse
import json
from collections import defaultdict
from pathlib import Path
from trace_directory_runtime import trace


def analyze(rom):
    entries = trace(rom)
    groups = {}
    for field in ('descriptor', 'table', 'pointer_address', 'resource'):
        grouped = defaultdict(list)
        for entry in entries:
            grouped[entry[field]].append(entry['slot'])
        groups[field] = {k: v for k, v in sorted(grouped.items()) if len(v) > 1}
    descriptor_to_tables = defaultdict(set)
    for entry in entries:
        descriptor_to_tables[entry['descriptor']].add(entry['table'])
    return {
        'slot_count': len(entries),
        'unique_counts': {field: len({e[field] for e in entries}) for field in groups},
        'shared_slot_groups': groups,
        'descriptors_used_with_multiple_tables': {
            k: sorted(v) for k, v in sorted(descriptor_to_tables.items()) if len(v) > 1
        },
        'entries': entries,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('rom', type=Path)
    ap.add_argument('--summary', action='store_true', help='omit individual slot entries')
    args = ap.parse_args()
    report = analyze(args.rom.read_bytes())
    if args.summary:
        del report['entries']
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
