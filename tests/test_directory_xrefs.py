import struct
import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from scan_directory_xrefs import scan
from trace_directory_runtime import BASE, DIRECTORY, SLOTS


class XrefsTests(unittest.TestCase):
    def test_aliases_and_external_reference(self):
        blob = bytearray(DIRECTORY - BASE + SLOTS * 8 + 64)
        for slot in range(SLOTS):
            struct.pack_into('<II', blob, DIRECTORY - BASE + slot * 8,
                             BASE + 0x200 + (slot % 2) * 4, BASE + 0x300)
        struct.pack_into('<I', blob, len(blob) - 4, BASE + 0x300)
        result = scan(blob)
        desc = next(x for x in result['targets'] if x['address'] == f'{BASE + 0x300:#010x}')
        self.assertEqual(desc['slots'], list(range(SLOTS)))
        self.assertEqual(len(desc['directory_occurrences']), SLOTS)
        self.assertEqual(desc['other_occurrences'], [f'{BASE + len(blob) - 4:#010x}'])
        self.assertEqual(len(result['targets']), 3)

    def test_truncated_rom(self):
        with self.assertRaises(ValueError):
            scan(bytes(128))


if __name__ == '__main__':
    unittest.main()
