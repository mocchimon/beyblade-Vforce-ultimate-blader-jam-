#!/usr/bin/env python3
"""Read-only, byte-exact comparison of a candidate GBA ROM against a reference.

Does not assume that matching bytes imply matching functions or source coverage.
"""
import argparse
import hashlib
import json
from pathlib import Path


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def compare(reference, candidate, base=0x08000000):
    n = min(len(reference), len(candidate))
    spans = []
    if n:
        start = 0
        same = reference[0] == candidate[0]
        for i in range(1, n):
            now = reference[i] == candidate[i]
            if now != same:
                spans.append({'start_offset': start, 'end_offset_exclusive': i, 'start_address': f'0x{base+start:08X}', 'length': i-start, 'equal': same})
                start, same = i, now
        spans.append({'start_offset': start, 'end_offset_exclusive': n, 'start_address': f'0x{base+start:08X}', 'length': n-start, 'equal': same})
    matched = sum(s['length'] for s in spans if s['equal'])
    return {
        'reference_size': len(reference), 'candidate_size': len(candidate),
        'reference_sha256': sha256(reference), 'candidate_sha256': sha256(candidate),
        'exact_match': reference == candidate,
        'common_length': n, 'matching_bytes_in_common_length': matched,
        'matching_fraction_of_reference': matched / len(reference) if reference else (1.0 if not candidate else 0.0),
        'different_bytes_in_common_length': n-matched,
        'missing_candidate_bytes': max(0, len(reference)-len(candidate)),
        'extra_candidate_bytes': max(0, len(candidate)-len(reference)),
        'spans': spans,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('reference', type=Path)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('--json', type=Path, help='Optional output report path')
    parser.add_argument('--max-spans', type=int, default=12)
    args = parser.parse_args()
    result = compare(args.reference.read_bytes(), args.candidate.read_bytes())
    print('Reference SHA256:', result['reference_sha256'])
    print('Candidate SHA256:', result['candidate_sha256'])
    print('Exact match:', result['exact_match'])
    print('Matching bytes in common length:', result['matching_bytes_in_common_length'], '/', result['common_length'])
    print('Missing/extra bytes:', result['missing_candidate_bytes'], '/', result['extra_candidate_bytes'])
    for span in (s for s in result['spans'] if not s['equal']):
        if args.max_spans <= 0:
            break
        print('Mismatch:', span['start_address'], 'length', span['length'])
        args.max_spans -= 1
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(result, indent=2) + '\n')
    return 0 if result['exact_match'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
