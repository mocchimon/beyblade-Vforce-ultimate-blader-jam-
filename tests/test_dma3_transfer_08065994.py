import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    'audit_dma3_transfer_08065994', ROOT / 'tools' / 'audit_dma3_transfer_08065994.py')
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)
ROM = Path('/mnt/data/Beyblade V-Force - Ultimate Blader # GBA(2).GBA')


class TestDma3TransferAudit(unittest.TestCase):
    def test_original_rom_transfer_contract(self):
        if not ROM.exists():
            self.skipTest('user-supplied original ROM is not mounted at standard path')
        result = AUDIT.audit(ROM.read_bytes())
        self.assertEqual(result['entry'], '0x08065994')
        self.assertEqual(result['instruction_halfwords_verified'], 47)
        self.assertEqual(result['abi']['r0'], 'source address')
        self.assertEqual(result['abi']['r1'], 'destination address')
        self.assertEqual(result['transfer']['unit'], '16-bit halfwords; 32-bit transfer bit is not set')
        self.assertIn('0x03007034', result['conclusion'])

    def test_mutated_instruction_rejected(self):
        rom = bytearray(0x800000)
        rom[0x65994:0x65996] = b'\x00\x00'
        with self.assertRaises(ValueError):
            AUDIT.audit(bytes(rom))


if __name__ == '__main__':
    unittest.main()
