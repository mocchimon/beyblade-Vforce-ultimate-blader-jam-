"""Small synthetic fixtures for the callback literal audit."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from audit_iwram_callbacks import audit, TARGETS, ROM_BASE


def run():
    size = max(slot - ROM_BASE for _, slot in TARGETS.values()) + 8
    rom = bytearray(size)
    for target, slot in TARGETS.values():
        i = slot - ROM_BASE
        rom[i:i+4] = target.to_bytes(4, 'little')
    result = audit(rom)
    assert all(v['unique_expected_slot'] for v in result.values())
    # Missing literal must be detected.
    first_target, first_slot = next(iter(TARGETS.values()))
    i = first_slot - ROM_BASE
    rom[i:i+4] = b'\0' * 4
    assert not all(v['unique_expected_slot'] for v in audit(rom).values())
    rom[i:i+4] = first_target.to_bytes(4, 'little')
    # Duplicate literal elsewhere must be reported, not silently accepted.
    rom[16:20] = first_target.to_bytes(4, 'little')
    assert not audit(rom)['runtime_entry_refresh']['unique_expected_slot']
    print('IWRAM callback literal audit tests passed')


if __name__ == '__main__':
    run()
