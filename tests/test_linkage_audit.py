import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from audit_linkage import parse_nm

class LinkageTests(unittest.TestCase):
    def test_defined_and_undefined(self):
        defs, refs = parse_nm('00000000 T MyFunction\n         U OtherFunction\n00000008 D global_data\n')
        self.assertEqual(defs, {'MyFunction', 'global_data'})
        self.assertEqual(refs, {'OtherFunction'})

    def test_ignores_local_symbols_and_headers(self):
        defs, refs = parse_nm('file.o:\n00000000 t local\n00000010 T exported\n')
        self.assertEqual(defs, {'exported'})
        self.assertEqual(refs, set())

    def test_deduplicates_imports(self):
        defs, refs = parse_nm(' U foo\n U foo\n U bar\n')
        self.assertEqual(refs, {'foo', 'bar'})

if __name__ == '__main__':
    unittest.main()
