import importlib.util
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).resolve().parents[1] / 'tools' / 'audit_state_switch_pass59.py'
spec = importlib.util.spec_from_file_location('audit_state_switch_pass59', MODULE_PATH)
audit_module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit_module)

class StateSwitchPass59Tests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rom = bytearray(Path('/mnt/data/Beyblade V-Force - Ultimate Blader # GBA(2).GBA').read_bytes())

    def test_original_rom_passes(self):
        result = audit_module.audit(bytes(self.rom))
        self.assertEqual(result['selector_load_offset'], '0x4B4')
        self.assertTrue(result['sha256_matches_expected_rom'])

    def test_selector_instruction_mismatch_fails(self):
        rom = bytearray(self.rom)
        rom[0x45A0E] ^= 2
        with self.assertRaisesRegex(ValueError, 'instruction mismatch'):
            audit_module.audit(bytes(rom))

    def test_jump_table_corruption_fails(self):
        rom = bytearray(self.rom)
        rom[0x45A34] ^= 1
        with self.assertRaisesRegex(ValueError, 'jump-table target mismatch'):
            audit_module.audit(bytes(rom))

    def test_case_argument_corruption_fails(self):
        rom = bytearray(self.rom)
        rom[0x45A60] ^= 1
        with self.assertRaisesRegex(ValueError, 'case instruction mismatch'):
            audit_module.audit(bytes(rom))

    def test_odd_length_image_fails(self):
        with self.assertRaisesRegex(ValueError, 'even-length'):
            audit_module.audit(bytes(self.rom) + b'\x00')

if __name__ == '__main__':
    unittest.main()
