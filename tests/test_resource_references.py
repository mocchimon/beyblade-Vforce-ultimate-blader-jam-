"""Regression checks for ROM resource-pointer reference discovery."""
import importlib.util
import struct
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('trace_resource_references', ROOT / 'tools' / 'trace_resource_references.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

class ScanTests(unittest.TestCase):
    def test_aligned_refs_and_duplicates(self):
        data = bytearray(40)
        struct.pack_into('<I', data, 4, 0x08075640)
        struct.pack_into('<I', data, 12, 0x08075640)
        self.assertEqual(mod.scan(data, {'dir': 0x08075640})['dir'],
                         [0x08000004, 0x0800000c])

    def test_unaligned_pattern_is_not_reported(self):
        data = b'X' + struct.pack('<I', 0x08075640) + b'Y' * 8
        self.assertEqual(mod.scan(data, {'dir': 0x08075640})['dir'], [])

    def test_no_false_matches(self):
        self.assertEqual(mod.scan(bytes(64), {'dir': 0x08075640})['dir'], [])

if __name__ == '__main__':
    unittest.main()
