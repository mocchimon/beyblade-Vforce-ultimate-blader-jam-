import struct
import unittest
from tools.audit_sub_08051090 import ROM_BASE, decode_bl_target, literal_address, scan


def put16(buf, off, value): struct.pack_into('<H', buf, off, value)
def put32(buf, off, value): struct.pack_into('<I', buf, off, value)

class Sub08051090AuditTests(unittest.TestCase):
    def test_decodes_known_bl_target(self):
        self.assertEqual(decode_bl_target(0x08051096, 0xF009, 0xF9D5), 0x0805A444)
        self.assertEqual(decode_bl_target(0x080510A4, 0xF006, 0xFDDA), 0x08057C5C)

    def test_literal_pc_alignment(self):
        self.assertEqual(literal_address(0x080510A8, 0x4B16), 0x08051104)

    def test_rejects_non_bl_pair(self):
        with self.assertRaises(ValueError): decode_bl_target(0x08000000, 0x2000, 0x3000)

    def test_scan_rejects_odd_rom(self):
        with self.assertRaises(ValueError): scan(bytes(0x201))

if __name__ == '__main__': unittest.main()
