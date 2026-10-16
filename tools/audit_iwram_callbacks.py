#!/usr/bin/env python3
"""ROM-specific audit of unresolved IWRAM callback literals.

No ROM data is copied into the project. Literal occurrences are evidence of
references, not evidence of the code's origin or installation mechanism.
"""
import argparse
import json
from pathlib import Path

ROM_BASE = 0x08000000
TARGETS = {
    'runtime_entry_refresh': (0x03006C60, 0x0807D988),
    'render_backend_a': (0x0300646C, 0x0807D968),
    'render_backend_b': (0x0300682C, 0x0807D96C),
    'runtime_config_pointer': (0x0300717C, 0x0807D920),
}


def audit(rom: bytes):
    report = {}
    for name, (target, expected_slot) in TARGETS.items():
        needle = target.to_bytes(4, 'little')
        offsets = [i for i in range(len(rom) - 3) if rom[i:i+4] == needle]
        addresses = [ROM_BASE + i for i in offsets]
        report[name] = {
            'target': f'0x{target:08X}',
            'expected_slot': f'0x{expected_slot:08X}',
            'literal_sites': [f'0x{x:08X}' for x in addresses],
            'expected_slot_present': expected_slot in addresses,
            'unique_expected_slot': addresses == [expected_slot],
        }
    return report


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('rom', type=Path)
    p.add_argument('--json', action='store_true')
    args = p.parse_args()
    rom = args.rom.read_bytes()
    result = audit(rom)
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        for name, item in result.items():
            print(f"{name}: {item['target']} -> {', '.join(item['literal_sites']) or 'none'}")
    if not all(x['unique_expected_slot'] for x in result.values()):
        raise SystemExit('IWRAM callback literal layout differs from the documented ROM')


if __name__ == '__main__':
    main()
