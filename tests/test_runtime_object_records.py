import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_runtime_object_records",
    ROOT / "tools" / "verify_runtime_object_records.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class RuntimeObjectRecordRecoveryTests(unittest.TestCase):
    def test_source_preserves_observed_header_and_record_layout(self):
        source = (ROOT / "src" / "runtime_object_records.c").read_text()
        header = (ROOT / "include" / "runtime_object_records.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("count_a", source)
        self.assertIn("count_b", source)
        self.assertIn("records;          /* +0x0C */", source)
        self.assertIn("sizeof(RuntimeObjectRecord) == 0x68", source)
        self.assertIn("record += 0x88", source)
        self.assertIn("RuntimeObject_UpdateRecord(record)", source)
        self.assertIn("RuntimeObject_UpdateDisplayRegion(record, value14, value18)",
                      source)
        self.assertNotIn("sub_080596D0", source)
        self.assertIn("RuntimeObject_UpdateRecordArray", header)
        self.assertIn("RuntimeObject_UpdateRecord(void *record)", header)
        arm_sources = next(line for line in makefile.splitlines()
                           if line.startswith("ARM_STATE_SOURCES :="))
        self.assertNotIn("runtime_object_records.c", arm_sources)
        self.assertIn("$(CC) $(TARGET_FLAGS) -mthumb", makefile)

    def test_rom_listing_covers_functions_and_call_targets(self):
        words = VERIFY._listing_halfwords()
        for start, end in VERIFY.RANGES:
            self.assertEqual(set(range(start, end, 2)) & words.keys(),
                             set(range(start, end, 2)))
        self.assertEqual(VERIFY.CALL_TARGETS[0x08050A8A], 0x08058F18)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08058F32], 0x080596D0)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08058F46], 0x08058F84)

    def test_verifier_rejects_a_changed_instruction(self):
        words = VERIFY._listing_halfwords()
        rom = bytearray(0x5EBA8)
        for address, halfword in words.items():
            offset = address - VERIFY.ROM_BASE
            rom[offset:offset + 2] = halfword.to_bytes(2, "little")
        VERIFY.verify(rom)

        offset = 0x08058F18 - VERIFY.ROM_BASE
        rom[offset] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
