import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from triage_unresolved import triage
class TriageTests(unittest.TestCase):
    def test_categories_and_preserved_references(self):
        root = Path(__file__).resolve().parents[1]
        rows = triage({'unresolved_imports': [
            {'symbol': '__aeabi_uidiv', 'referenced_by': ['runtime_object_table']},
            {'symbol': 'sub_080512D0', 'referenced_by': ['main']},
            {'symbol': 'FatalError', 'referenced_by': ['runtime_memory']}]}, root)
        self.assertEqual([x['category'] for x in rows], ['compiler_runtime', 'address_named', 'named_external'])
        self.assertEqual(rows[1]['address'], '0x080512D0')
        self.assertTrue(rows[1]['callsites'])
        self.assertEqual(rows[2]['referenced_by'], ['runtime_memory'])
    def test_empty(self):
        self.assertEqual(triage({'unresolved_imports': []}, Path(__file__).resolve().parents[1]), [])
if __name__ == '__main__': unittest.main()
