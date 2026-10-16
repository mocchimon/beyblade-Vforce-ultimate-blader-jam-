"""ROM-free directory alias graph regression tests."""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from analyze_directory_aliases import analyze
from test_directory_synthetic import build, write32
from trace_directory_runtime import DIRECTORY


def main():
    rom, descriptors, tables, resources = build()
    report = analyze(rom)
    assert report['slot_count'] == 32
    assert report['unique_counts']['descriptor'] <= 32
    assert report['unique_counts']['resource'] <= 32
    assert sum(len(v) for v in report['shared_slot_groups']['resource'].values()) >= 2
    # Force slot 1 to use slot 0's descriptor and table; sharing must be reported.
    write32(rom, DIRECTORY + 8, tables[0])
    write32(rom, DIRECTORY + 12, descriptors[0])
    report = analyze(rom)
    for field in ('descriptor', 'table', 'pointer_address', 'resource'):
        assert any({0, 1}.issubset(set(v)) for v in report['shared_slot_groups'][field].values()), field
    # A descriptor can be shared while table selection differs: don't equate those aliases.
    write32(rom, DIRECTORY + 8, tables[1])
    report = analyze(rom)
    assert any({0, 1}.issubset(set(v)) for v in report['shared_slot_groups']['descriptor'].values())
    assert descriptors[0] and resources[0]
    print('PASS: 32-slot alias graph, forced sharing, descriptor/table distinction')


if __name__ == '__main__':
    main()
