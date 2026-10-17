import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_runtime_object_selection_finalize",
    ROOT / "tools" / "verify_runtime_object_selection_finalize.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class RuntimeObjectSelectionFinalizeTests(unittest.TestCase):
    def test_source_recovers_code_stream_and_chain_updates(self):
        source = (ROOT / "src" / "runtime_object_selection_finalize.c").read_text()
        header = (ROOT / "include" / "runtime_object_selection.h").read_text()
        dispatch = (ROOT / "src" / "runtime_object_selection_dispatch.c").read_text()
        caller = (ROOT / "src" / "runtime_object_selection.c").read_text()
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("RuntimeObjectSelection_Finalize", header)
        self.assertIn("RuntimeObjectSelection_CountEntries(code_stream)", source)
        self.assertIn("ResourceNode_ResizeChain(context + 0x14", source)
        self.assertIn("pending_marker = 0x8000u", source)
        self.assertIn("code_map[code]", source)
        self.assertIn("RuntimeObjectSelection_ApplyLayout(context_pointer)", source)
        self.assertIn("RuntimeObjectSelection_Finalize(", dispatch)
        self.assertNotIn("sub_080614E0", dispatch)
        self.assertIn("(const uint8_t *)(uintptr_t)selected_stream_address", caller)
        arm_sources = next(line for line in makefile.splitlines()
                           if line.startswith("ARM_STATE_SOURCES :="))
        self.assertNotIn("runtime_object_selection_finalize.c", arm_sources)

    def test_saved_rom_range_calls_and_literals(self):
        words = VERIFY._listing_halfwords()
        start, end = VERIFY.RANGE
        self.assertEqual(set(range(start, end, 2)) & words.keys(),
                         set(range(start, end, 2)))
        self.assertEqual(len(words), (end - start) // 2)
        self.assertEqual(VERIFY.CALL_TARGETS[0x0806165E], 0x08061260)
        self.assertEqual(VERIFY.LITERALS[0x0806167C], 0x0807D9A4)

    def test_verifier_rejects_modified_rom_bytes(self):
        start, end = VERIFY.RANGE
        rom = bytearray(end - VERIFY.ROM_BASE)
        words = VERIFY._listing_halfwords()
        for address, halfword in words.items():
            struct.pack_into("<H", rom, address - VERIFY.ROM_BASE, halfword)
        for address, target in VERIFY.CALL_TARGETS.items():
            displacement = target - (address + 4)
            upper = 0xF000 | ((displacement >> 12) & 0x7FF)
            lower = 0xF800 | ((displacement >> 1) & 0x7FF)
            struct.pack_into("<HH", rom, address - VERIFY.ROM_BASE,
                             upper, lower)
        for address, value in VERIFY.LITERALS.items():
            struct.pack_into("<I", rom, address - VERIFY.ROM_BASE, value)
        VERIFY.verify(rom)
        rom[start - VERIFY.ROM_BASE] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
