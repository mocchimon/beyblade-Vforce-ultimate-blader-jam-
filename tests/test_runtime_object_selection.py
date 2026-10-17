import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_runtime_object_selection",
    ROOT / "tools" / "verify_runtime_object_selection.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class RuntimeObjectSelectionTests(unittest.TestCase):
    def test_source_keeps_observed_offsets_and_strides(self):
        source = (ROOT / "src" / "runtime_object_selection.c").read_text()
        header = (ROOT / "include" / "runtime_object_selection.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        self.assertIn("record_array) == 0x1C", source)
        self.assertIn("sizeof(RuntimeObjectSelectionEntry) == 0x1C", source)
        self.assertIn("sizeof(RuntimeObjectSelectionSourceRecord) == 0x30", source)
        self.assertIn("source->count * 0x1Cu", source)
        self.assertIn("angle += angle_step", source)
        self.assertIn("ResourceNode_AcquireByClass(", source)
        self.assertIn("ResourceNode_ConfigureSelectionEntry(", source)
        self.assertIn("RuntimeObjectSelection_InitializeContext(", source)
        self.assertNotIn("extern uint32_t sub_08060A04", source)
        self.assertNotIn("extern void sub_08060B8C", source)
        self.assertNotIn("extern void sub_080611B4", source)
        self.assertNotIn("extern uint32_t sub_08061684", source)
        self.assertIn("RuntimeObjectSelection_Dispatch(", source)
        dispatch = (ROOT / "src" / "runtime_object_selection_dispatch.c").read_text()
        self.assertIn("RuntimeObjectSelection_Finalize", dispatch)
        self.assertIn("ResourceNode_ReleaseChain", dispatch)
        self.assertIn("return (uint8_t)RuntimeObjectSelection_Finalize", dispatch)
        self.assertIn("RuntimeObject_InitializeEntryTable", header)
        arm_sources = next(line for line in makefile.splitlines()
                           if line.startswith("ARM_STATE_SOURCES :="))
        self.assertNotIn("runtime_object_selection.c", arm_sources)

    def test_rom_listing_and_direct_call_bindings(self):
        words = VERIFY._listing_halfwords()
        for start, end in VERIFY.RANGES:
            self.assertEqual(set(range(start, end, 2)) & words.keys(),
                             set(range(start, end, 2)))
        self.assertEqual(VERIFY.CALL_TARGETS[0x08050B8A], 0x08060A04)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08050BC0], 0x08060B8C)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08050C12], 0x08063AC4)
        self.assertEqual(VERIFY.CALL_TARGETS[0x0804874C], 0x08050AA0)

    def test_verifier_detects_changed_instruction_bytes(self):
        words = VERIFY._listing_halfwords()
        rom = bytearray(0x800000)
        for address, halfword in words.items():
            offset = address - VERIFY.ROM_BASE
            rom[offset:offset + 2] = halfword.to_bytes(2, "little")
        for address, target in VERIFY.CALL_TARGETS.items():
            displacement = target - (address + 4)
            if displacement < 0:
                displacement += 1 << 23
            upper = 0xF000 | ((displacement >> 12) & 0x7FF)
            lower = 0xF800 | ((displacement >> 1) & 0x7FF)
            struct.pack_into("<HH", rom, address - VERIFY.ROM_BASE,
                             upper, lower)
        VERIFY.verify(rom)

        offset = 0x08050AA0 - VERIFY.ROM_BASE
        rom[offset] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
