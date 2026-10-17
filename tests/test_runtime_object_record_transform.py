import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_runtime_object_record_transform",
    ROOT / "tools" / "verify_runtime_object_record_transform.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class RuntimeObjectRecordTransformTests(unittest.TestCase):
    def test_listing_covers_every_rom_range(self):
        words = VERIFY._listing_halfwords()
        for start, end in VERIFY.RANGES:
            self.assertEqual(set(range(start, end, 2)) & words.keys(),
                             set(range(start, end, 2)))

    def test_calls_bind_the_recovered_transform_cluster(self):
        self.assertEqual(VERIFY.CALL_TARGETS[0x08058FCA], 0x08059B24)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08059020], 0x08059A8C)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08059C1C], 0x08059ADC)
        self.assertEqual(sum(target == 0x08059FC4
                             for target in VERIFY.CALL_TARGETS.values()), 4)

    def test_literals_identify_the_table_and_affine_registers(self):
        self.assertEqual(VERIFY.LITERALS[0x08059078], 0x03000D00)
        self.assertEqual(VERIFY.LITERALS[0x08059C34], 0x0874CC60)
        self.assertEqual(VERIFY.LITERALS[0x08059C38], 0x0872CC60)
        self.assertEqual(VERIFY.LITERALS[0x08059B04], 0x04000020)
        self.assertEqual(VERIFY.LITERALS[0x08059B20], 0x04000030)

    def test_source_models_the_record_and_affine_table_layouts(self):
        source = (ROOT / "src" / "runtime_object_record_transform.c").read_text()
        record_source = (ROOT / "src" / "runtime_object_records.c").read_text()
        header = (ROOT / "include" / "runtime_object_records.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("transformMode5E", source)
        self.assertIn("sizeof(RuntimeObjectAffineEntry) == 0x18", source)
        self.assertIn("RuntimeObject_ApplyRecordTransform(record)", record_source)
        self.assertNotIn("sub_08058F84", record_source)
        self.assertIn("RuntimeObject_ApplyRecordTransform(void *record)", header)
        arm_sources = next(line for line in makefile.splitlines()
                           if line.startswith("ARM_STATE_SOURCES :="))
        self.assertNotIn("runtime_object_record_transform.c", arm_sources)
        self.assertIn("C_SOURCES := $(wildcard src/*.c)", makefile)

    def test_verifier_rejects_changed_instruction_and_table_literal(self):
        words = VERIFY._listing_halfwords()
        rom_end = max(max(end for _, end in VERIFY.RANGES),
                      max(VERIFY.LITERALS) + 4)
        rom = bytearray(rom_end - VERIFY.ROM_BASE)
        for address, halfword in words.items():
            offset = address - VERIFY.ROM_BASE
            rom[offset:offset + 2] = halfword.to_bytes(2, "little")

        VERIFY.verify(rom)

        instruction_offset = 0x08058F84 - VERIFY.ROM_BASE
        rom[instruction_offset] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)

        rom[instruction_offset] ^= 1
        literal_offset = 0x08059C34 - VERIFY.ROM_BASE
        rom[literal_offset] ^= 1
        with self.assertRaises(ValueError):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
