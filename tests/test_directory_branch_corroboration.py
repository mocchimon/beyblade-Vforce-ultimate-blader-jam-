import struct
import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from corroborate_directory_loads import branch_sources, corroborate
from trace_directory_runtime import BASE

class BranchEvidenceTests(unittest.TestCase):
    def test_arm_forward_branch(self):
        rom = bytearray(0x100)
        struct.pack_into('<I', rom, 0x20, 0xea000006)  # target 0x40
        self.assertEqual(branch_sources(rom, BASE+0x40, 'ARM')[0]['kind'], 'ARM B')

    def test_arm_backward_branch_and_nv_exclusion(self):
        rom = bytearray(0x100)
        struct.pack_into('<I', rom, 0x40, 0xebfffff6)  # target 0x20
        struct.pack_into('<I', rom, 0x44, 0xfafffff5)  # NV, must not count
        self.assertEqual(len(branch_sources(rom, BASE+0x20, 'ARM')), 1)

    def test_thumb_unconditional_and_conditional(self):
        rom = bytearray(0x100)
        struct.pack_into('<H', rom, 0x20, 0xe006)  # target 0x30
        struct.pack_into('<H', rom, 0x24, 0xd004)  # target 0x30
        self.assertEqual({x['kind'] for x in branch_sources(rom, BASE+0x30, 'Thumb')}, {'Thumb B', 'Thumb Bcond'})

    def test_empty_report(self):
        self.assertEqual(corroborate(b'', {'hits': []})['with_direct_branches'], 0)

if __name__ == '__main__':
    unittest.main()
