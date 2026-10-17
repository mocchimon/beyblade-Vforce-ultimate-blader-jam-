import importlib.util
from pathlib import Path
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "verify_resource_node_release_chain",
    ROOT / "tools" / "verify_resource_node_release_chain.py")
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class ResourceNodeReleaseChainTests(unittest.TestCase):
    def test_source_and_callers_use_the_recovered_name(self):
        source = (ROOT / "src" / "resource_node.c").read_text()
        header = (ROOT / "include" / "resource_node.h").read_text()
        dispatch = (ROOT / "src" / "runtime_object_selection_dispatch.c").read_text()
        self.assertIn("ResourceNode_ReleaseChain", header)
        self.assertIn("void ResourceNode_ReleaseChain(void *opaque_context)", source)
        self.assertIn("if (count == 0u)", source)
        self.assertIn("RESOURCE_NODE_COUNT += count", source)
        self.assertIn("context->count = 0u", source)
        self.assertNotIn("context->value_2c = 0u", source)
        self.assertIn("node->range_token = -1", source)
        self.assertIn("tail->next = RESOURCE_FREE_HEAD", source)
        self.assertIn("ResourceNode_ReleaseChain(context + 0x14)", dispatch)
        self.assertNotIn("sub_08060D00", dispatch)

    def test_saved_range_and_call_bindings(self):
        words = VERIFY._listing_halfwords()
        for start, end in VERIFY.RANGES:
            self.assertEqual(set(range(start, end, 2)) & words.keys(),
                             set(range(start, end, 2)))
        self.assertEqual(len(words), 94)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08060D56], 0x0806082C)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08060DA0], 0x080604F8)
        self.assertEqual(VERIFY.CALL_TARGETS[0x08061252], 0x08060D00)

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
        rom[0x08060D00 - VERIFY.ROM_BASE] ^= 1
        with self.assertRaisesRegex(ValueError, "Thumb bytes differ"):
            VERIFY.verify(rom)


if __name__ == "__main__":
    unittest.main()
