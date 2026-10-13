#!/usr/bin/env python3
"""Compare a locally owned ROM to upstream's published build fingerprints."""
import argparse
import hashlib
from pathlib import Path

UPSTREAM = {
    'us': 'cd527c8c24e20e33913fc45199e64b3e6138a6e5',
    'eu': '6d20a586e7bb52b4a9352bbeaec9d7be65e93369',
    'debug': '9210a12ce01fefbf7994af2a8d51351ed82d7253',
}

def identify(digest):
    return next((name for name, sha in UPSTREAM.items() if sha == digest.lower()), None)

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('rom', type=Path)
    args = p.parse_args()
    sha = hashlib.sha1(args.rom.read_bytes()).hexdigest()
    version = identify(sha)
    print(f'ROM SHA1: {sha}')
    if version:
        print(f'Exact upstream build fingerprint: {version}')
    else:
        print('No exact upstream US/EU/debug build fingerprint match.')
        print('This does not establish whether the underlying game code is equivalent.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
