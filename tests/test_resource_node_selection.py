import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_resource_node_selection",
    ROOT / "tools" / "verify_resource_node_selection.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class ResourceNodeSelectionTests(unittest.TestCase):
    def test_source_recovers_list_acquire_and_entry_writes(self):
        source = (ROOT / "src" / "resource_node.c").read_text()
        header = (ROOT / "include" / "resource_node.h").read_text()
        self.assertIn("ResourceNode_FindInsertionPoint", source)
        self.assertIn("ResourceNode_AcquireByClass", source)
        self.assertIn("ResourceNode_ConfigureSelectionEntry", source)
        self.assertIn("insertion_class) == 0x22", source)
        self.assertIn("RESOURCE_NODE_COUNT -= 1u", source)
        self.assertIn("0x08755AD8u", source)
        self.assertIn("entry->token_24 = -1", source)
        self.assertIn("entry->metadata_2c", source)
        self.assertIn("((arg6 & 0x03u) << 28)", source)
        self.assertIn("entry->value_18 = (uint16_t)handle", source)
        self.assertIn("ResourceNode_AcquireByClass", header)

    def test_context_initializer_has_observed_offsets_and_selection_flags(self):
        source = (ROOT / "src" / "runtime_object_selection.c").read_text()
        self.assertIn("RuntimeObjectSelection_InitializeContext", source)
        self.assertIn("selection_flags;      /* +0x08 */", source)
        self.assertIn("position_y_scaled;     /* +0x04 */", source)
        self.assertIn("context->selection_flags = (uint16_t)selection_flags", source)
        self.assertIn("context->extent = (uint16_t)extent", source)
        self.assertIn("object[5] + 4u", source)
        self.assertIn("sizeof(RuntimeObjectSelectionContext) == 0x30", source)

    def test_saved_ranges_and_direct_call_bindings(self):
        words = VERIFY._listing_halfwords()
        for start, end in VERIFY.RANGES:
            self.assertEqual(set(range(start, end, 2)) & words.keys(),
                             set(range(start, end, 2)))
        self.assertEqual(VERIFY.CALL_TARGETS[0x08060A18], 0x080609E8)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08050B8A], 0x08060A04)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08050BC0], 0x08060B8C)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08050BFE], 0x080611B4)
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

        offset = 0x080609E8 - VERIFY.ROM_BASE
        rom[offset] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
