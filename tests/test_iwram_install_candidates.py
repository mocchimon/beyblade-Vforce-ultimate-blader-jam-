import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    'audit_iwram_install_candidates', ROOT / 'tools' / 'audit_iwram_install_candidates.py')
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)


class TestIWRAMInstallCandidates(unittest.TestCase):
    def test_finds_thumb_literal_for_iwram_address(self):
        rom = bytearray(0x200)
        # LDR r0, [PC, #0] at ROM + 0x100 resolves to aligned PC + 0 = 0x08000104.
        struct.pack_into('<H', rom, 0x100, 0x4800)
        struct.pack_into('<I', rom, 0x104, 0x03007034)
        result = AUDIT.audit(bytes(rom))
        row = next(r for r in result['references'] if r['instruction'] == '0x08000100')
        self.assertEqual(row['literal_value'], '0x03007034')
        self.assertEqual(row['kind'], 'iwram_address_literal')

    def test_finds_dma_register_literal(self):
        rom = bytearray(0x200)
        struct.pack_into('<H', rom, 0x100, 0x4800)
        struct.pack_into('<I', rom, 0x104, 0x040000D4)
        result = AUDIT.audit(bytes(rom))
        row = next(r for r in result['references'] if r['instruction'] == '0x08000100')
        self.assertEqual(row['kind'], 'dma_register_literal')
        self.assertEqual(row['register_name'], 'DMA3SAD')

    def test_dma_register_map_uses_gba_channel_offsets(self):
        self.assertEqual(AUDIT.DMA_REGS[0x040000D0], 'DMA2CNT_L')
        self.assertEqual(AUDIT.DMA_REGS[0x040000D4], 'DMA3SAD')
        self.assertEqual(AUDIT.DMA_REGS[0x040000D8], 'DMA3DAD')
        self.assertEqual(AUDIT.DMA_REGS[0x040000DC], 'DMA3CNT_L')
        self.assertEqual(AUDIT.DMA_REGS[0x040000DE], 'DMA3CNT_H')

    def test_truncated_rom_rejected(self):
        with self.assertRaises(ValueError):
            AUDIT.audit(bytes(32))


if __name__ == '__main__':
    unittest.main()
