import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_resource_node_chain_ops",
    ROOT / "tools" / "verify_resource_node_chain_ops.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class ResourceNodeChainOperationTests(unittest.TestCase):
    def test_source_uses_named_chain_operations_and_code_counter(self):
        node = (ROOT / "src" / "resource_node.c").read_text()
        node_header = (ROOT / "include" / "resource_node.h").read_text()
        selection = (ROOT / "src" / "runtime_object_selection_dispatch.c").read_text()
        selection_header = (ROOT / "include" / "runtime_object_selection.h").read_text()
        self.assertIn("ResourceNode_AllocateChain", node_header)
        self.assertIn("ResourceNode_ResizeChain", node_header)
        self.assertIn("RESOURCE_NODE_COUNT = available - count", node)
        self.assertIn("ResourceNode_ReleaseChain(context)", node)
        self.assertIn("ResourceNode_AllocateChain(context, requested", node)
        self.assertIn("RuntimeObjectSelection_CountEntries", selection_header)
        self.assertIn("RuntimeObjectSelection_CountEntries", selection)
        self.assertIn("if (*code_stream != 32u)", selection)

    def test_saved_ranges_and_call_bindings(self):
        words = VERIFY._listing_halfwords()
        for start, end in VERIFY.RANGES:
            self.assertEqual(set(range(start, end, 2)) & words.keys(),
                             set(range(start, end, 2)))
        self.assertEqual(len(words), 228)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08060E8C], 0x08060D00)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08060E96], 0x08060C40)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08061540], 0x08060DBC)
        self.assertEqual(VERIFY.CALL_TARGETS[0x080614F8], 0x08064F5C)

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
        rom[0x08060C40 - VERIFY.ROM_BASE] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
