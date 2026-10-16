import struct
import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from classify_directory_literals import candidates, classify
from trace_directory_runtime import BASE, DIRECTORY, SLOTS

class LiteralTests(unittest.TestCase):
    def test_thumb_and_arm_positive(self):
        rom = bytearray(0x200)
        struct.pack_into('<H', rom, 0x100, 0x4807)  # PC 0x104 + 28 -> 0x120
        struct.pack_into('<I', rom, 0x104, 0xe59f0014)  # PC 0x10c + 20 -> 0x120
        hits = candidates(rom, BASE + 0x120)
        self.assertEqual({x['isa'] for x in hits}, {'ARM', 'Thumb'})

    def test_arm_negative(self):
        rom = bytearray(0x200)
        struct.pack_into('<I', rom, 0x140, 0xe51f0028)  # PC 0x148 - 40 -> 0x120
        self.assertEqual(candidates(rom, BASE + 0x120)[0]['isa'], 'ARM')

    def test_directory_exclusion(self):
        rom = bytearray(DIRECTORY - BASE + SLOTS * 8 + 16)
        for slot in range(SLOTS):
            struct.pack_into('<II', rom, DIRECTORY - BASE + slot * 8, BASE + 0x200, BASE + 0x300)
        self.assertEqual(classify(rom)['hits'], [])

    def test_out_of_bounds(self):
        self.assertEqual(candidates(b'\x00' * 8, BASE + 8), [])

if __name__ == '__main__':
    unittest.main()
