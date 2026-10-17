import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_runtime_object_display_region",
    ROOT / "tools" / "verify_runtime_object_display_region.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class RuntimeObjectDisplayRegionTests(unittest.TestCase):
    def test_listing_covers_every_rom_range(self):
        words = VERIFY._listing_halfwords()
        for start, end in VERIFY.RANGES:
            self.assertEqual(set(range(start, end, 2)) & words.keys(),
                             set(range(start, end, 2)))

    def test_calls_bind_updater_renderer_and_register_helpers(self):
        self.assertEqual(VERIFY.CALL_TARGETS[0x08058F32], 0x080596D0)
        self.assertEqual(VERIFY.CALL_TARGETS[0x080597D2], 0x08059334)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08059880], 0x08059334)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08059914], 0x08059A8C)
        self.assertEqual(VERIFY.CALL_TARGETS[0x0805994C], 0x080596D0)

    def test_register_literals_match_gba_display_registers(self):
        self.assertEqual(VERIFY.LITERALS[0x080599F0], 0x04000010)
        self.assertEqual(VERIFY.LITERALS[0x08059A30], 0x04000012)
        self.assertEqual(VERIFY.LITERALS[0x08059A70], 0x04000008)
        self.assertEqual(VERIFY.LITERALS[0x08059A88], 0x0400000E)

    def test_source_uses_record_call_arguments_and_real_register_selectors(self):
        record_source = (ROOT / "src" / "runtime_object_records.c").read_text()
        display_source = (ROOT / "src" / "runtime_object_display_region.c").read_text()
        helper_source = (ROOT / "src" / "child_resource_helpers.c").read_text()
        helper_header = (ROOT / "include" / "child_resource_helpers.h").read_text()
        self.assertIn("RuntimeObject_UpdateDisplayRegion(record, value14, value18)",
                      record_source)
        self.assertNotIn("sub_080596D0", record_source)
        self.assertEqual(display_source.count("Render_PrepareTransfer(record_pointer"),
                         2)
        self.assertIn("ChildResource_HorizontalOffsetRegister", helper_source)
        self.assertIn("0x04000010u", helper_source)
        self.assertIn("ChildResource_BackgroundControlRegister", helper_header)
        self.assertNotIn("ChildResource_LayoutValueA", helper_source)

    def test_verifier_rejects_a_changed_instruction(self):
        words = VERIFY._listing_halfwords()
        rom_end = max(max(end for _, end in VERIFY.RANGES),
                      max(VERIFY.LITERALS) + 4)
        rom = bytearray(rom_end - VERIFY.ROM_BASE)
        for address, halfword in words.items():
            offset = address - VERIFY.ROM_BASE
            rom[offset:offset + 2] = halfword.to_bytes(2, "little")
        VERIFY.verify(rom)

        offset = 0x080596D0 - VERIFY.ROM_BASE
        rom[offset] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
