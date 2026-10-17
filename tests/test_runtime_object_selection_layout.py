import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_runtime_object_selection_layout",
    ROOT / "tools" / "verify_runtime_object_selection_layout.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class RuntimeObjectSelectionLayoutTests(unittest.TestCase):
    def test_source_recovers_wrap_modes_scale_and_vertical_adjustment(self):
        source = (ROOT / "src" / "runtime_object_selection_layout.c").read_text()
        header = (ROOT / "include" / "runtime_object_selection.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("RuntimeObjectSelection_ApplyLayout", header)
        self.assertIn("RuntimeObjectSelection_SetFlagsAndApplyLayout", header)
        self.assertIn("case 1u:", source)
        self.assertIn("case 2u:", source)
        self.assertIn("projected <= extent && remaining_after != 0u", source)
        self.assertIn("x_delta * scale", source)
        self.assertIn("context[0x0F] = (uint8_t)(context[0x0F] + 1u)", source)
        self.assertIn("vertical_mode == 0x10u", source)
        self.assertNotIn("sub_08061260", source)
        self.assertIn("C_SOURCES := $(wildcard src/*.c)", makefile)
        arm_sources = next(line for line in makefile.splitlines()
                           if line.startswith("ARM_STATE_SOURCES :="))
        self.assertNotIn("runtime_object_selection_layout.c", arm_sources)

        finalizer = (ROOT / "src" / "runtime_object_selection_finalize.c").read_text()
        self.assertIn("RuntimeObjectSelection_ApplyLayout(context_pointer)",
                      finalizer)

    def test_saved_rom_range_and_wrapper_linkage(self):
        words = VERIFY._listing_halfwords()
        start, end = VERIFY.RANGE
        self.assertEqual(set(range(start, end, 2)) & words.keys(),
                         set(range(start, end, 2)))
        self.assertEqual(VERIFY.CALL_TARGETS[0x080614D8], 0x08061260)
        self.assertEqual(words[0x080614D6], 0x8101)  # STRH r1, [r0, #8]

    def test_verifier_rejects_changed_rom_bytes(self):
        start, end = VERIFY.RANGE
        rom = bytearray(end - VERIFY.ROM_BASE)
        for address, halfword in VERIFY._listing_halfwords().items():
            struct.pack_into("<H", rom, address - VERIFY.ROM_BASE, halfword)
        VERIFY.verify(rom)

        rom[start - VERIFY.ROM_BASE] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
