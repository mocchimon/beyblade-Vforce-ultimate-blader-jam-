import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_runtime_object_dispatch",
    ROOT / "tools" / "verify_runtime_object_dispatch.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class RuntimeObjectDispatchTests(unittest.TestCase):
    def test_source_uses_named_wrapper_and_neutral_packed_fields(self):
        source = (ROOT / "src" / "runtime_object_selection_dispatch.c").read_text()
        header = (ROOT / "include" / "runtime_object_selection.h").read_text()
        makefile = (ROOT / "Makefile").read_text()
        arm_sources = next(line for line in makefile.splitlines()
                           if line.startswith("ARM_STATE_SOURCES :="))
        self.assertIn("RuntimeObjectSelection_Dispatch", header)
        self.assertIn("RuntimeObjectSelection_ResetContext", source)
        self.assertIn("ResourceNode_ReleaseChain(context + 0x14)", source)
        self.assertIn("context + 0x0A", source)
        self.assertIn("(value & 0x03u) << 10", source)
        self.assertIn("(*state_word >> 10) & 0x03u", source)
        self.assertIn("(value & 0x0Fu) << 12", source)
        self.assertNotIn("runtime_object_selection_dispatch.c", arm_sources)

    def test_saved_ranges_and_direct_call_bindings(self):
        words = VERIFY._listing_halfwords()
        for start, end in VERIFY.RANGES:
            self.assertEqual(set(range(start, end, 2)) & words.keys(),
                             set(range(start, end, 2)))
        self.assertEqual(VERIFY.CALL_TARGETS[0x08061252], 0x08060D00)
        self.assertEqual(VERIFY.CALL_TARGETS[0x0806168E], 0x0806124C)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08061698], 0x080614E0)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08050C28], 0x08061684)

    def test_verifier_rejects_modified_rom_bytes(self):
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

        offset = 0x08061684 - VERIFY.ROM_BASE
        rom[offset] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
