import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from compare_rom import compare


class RomComparisonTests(unittest.TestCase):
    def test_identical(self):
        r = compare(b'\x00\x01\x02', b'\x00\x01\x02')
        self.assertTrue(r['exact_match'])
        self.assertEqual(r['matching_bytes_in_common_length'], 3)

    def test_mismatch_spans_and_addresses(self):
        r = compare(b'abcdef', b'abXdYf')
        self.assertFalse(r['exact_match'])
        self.assertEqual([s['start_offset'] for s in r['spans'] if not s['equal']], [2, 4])
        self.assertEqual(r['spans'][1]['start_address'], '0x08000002')

    def test_short_candidate(self):
        r = compare(b'abcde', b'abc')
        self.assertEqual(r['missing_candidate_bytes'], 2)
        self.assertEqual(r['matching_fraction_of_reference'], 0.6)

    def test_long_candidate(self):
        r = compare(b'abc', b'abcde')
        self.assertEqual(r['extra_candidate_bytes'], 2)
        self.assertFalse(r['exact_match'])

    def test_empty(self):
        self.assertTrue(compare(b'', b'')['exact_match'])
        self.assertFalse(compare(b'', b'X')['exact_match'])


if __name__ == '__main__':
    unittest.main()
