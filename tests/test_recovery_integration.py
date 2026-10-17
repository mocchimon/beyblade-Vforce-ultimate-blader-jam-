import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class RecoveryIntegrationTests(unittest.TestCase):
    def read(self, relative_path):
        return (ROOT / relative_path).read_text(encoding="utf-8")

    def test_recovered_division_exports_and_callers_are_wired(self):
        math_runtime = self.read("src/math_runtime.c")
        descriptor = self.read("src/resource_descriptor.c")
        object_table = self.read("src/runtime_object_table.c")

        self.assertRegex(math_runtime, r"uint32_t\s+Math_DivideUnsigned\s*\(")
        self.assertRegex(math_runtime, r"int32_t\s+Math_DivideSigned\s*\(")
        self.assertRegex(math_runtime, r"uint32_t\s+__aeabi_uidiv\s*\(")
        self.assertIn("Math_DivideSigned(", descriptor)
        self.assertNotIn("sub_080660A8", descriptor)
        self.assertIn("Math_DivideUnsigned(", object_table)

    def test_vblank_and_directory_imports_resolve_to_existing_sources(self):
        bios = self.read("src/bios.c")
        dispatcher = self.read("src/resource_directory_dispatch.c")
        handle = self.read("src/resource_handle.c")
        noops = self.read("src/runtime_noop.c")

        self.assertRegex(bios, r"void\s+System_VBlankWait\s*\(")
        self.assertIn('swi 0x05', bios)
        self.assertIn("RuntimeResource_Select(index)", dispatcher)
        self.assertRegex(handle, r"void\s+RuntimeResource_Select\s*\(")
        self.assertNotRegex(dispatcher, r"extern\s+.*ResourceDirectory_(?:Prepare|Create|Apply)")
        self.assertIn("void sub_08057B60(", noops)
        self.assertIn("void sub_08057C5C(", noops)

    def test_runtime_record_clear_symbol_matches_rom_call_and_preserves_pointer(self):
        game_state = self.read("src/game_state.c")
        object_record = self.read("src/object_record.c")
        header = self.read("include/runtime_record.h")
        clear_body = object_record.split("void RuntimeRecord_Clear(", 1)[1].split("\n}", 1)[0]

        self.assertIn("RuntimeRecord_Clear(", game_state)
        self.assertNotIn("sub_08050388", game_state)
        self.assertIn("RuntimeRecord_Clear(", header)
        self.assertNotIn("m->allocation", clear_body)
        for field in ("source", "flags", "records", "count", "bounce_scale", "boundary"):
            self.assertIn("m->" + field + " = 0", clear_body)

    def test_runtime_record_init_and_update_follow_rom_data_flow(self):
        source = self.read("src/object_record.c")
        header = self.read("include/runtime_record.h")
        init = source.split("void RuntimeRecord_Init(", 1)[1].split(
            "/* Arithmetic shift", 1
        )[0]
        update = source.split("void RuntimeRecord_Update(", 1)[1].split("\n}", 1)[0]

        self.assertIn("RuntimeRecord_Init(", header)
        self.assertNotIn("Runtime_Fatal", source)
        self.assertLess(init.index("if (bytes == 0)"), init.index("Heap_AllocAlt(bytes)"))
        self.assertIn("sub_08057C5C((const void *)(uintptr_t)0x087270A4u);", init)
        self.assertIn("sub_08057C5C((const void *)(uintptr_t)0x087270DCu, bytes, count)", init)
        self.assertIn("m->allocation = allocation", init)
        self.assertIn("allocation->address", init)
        self.assertIn("(int16_t)count", init)
        self.assertIn("source[0]", init)
        self.assertIn("node->position_x", init)
        self.assertIn("node = node->next", init)
        self.assertIn("node->position_x = record->position_x", update)
        self.assertIn("record->velocity_x += record->acceleration_x", update)
        self.assertIn("(flags & 3u)", update)
        self.assertIn("*position = m->boundary", update)
        self.assertIn("RuntimeRecord_ArithmeticShiftRight8", update)

    def test_frame_prepare_uses_rom_context_and_object_bases(self):
        game_state = self.read("src/game_state.c")
        startup = self.read("src/main.c")

        self.assertIn("GAME_STATE_CONTEXT ((volatile uint8_t *)0x03000650u)", game_state)
        self.assertIn("(uintptr_t)0x03000FB0u", game_state)
        self.assertRegex(game_state, r"void\s+GameState_FramePrepare\s*\(")
        self.assertIn("(object + 0xC26) = 0xFFFF", game_state)
        self.assertIn("RuntimeRecord_Clear((volatile RuntimeRecordManager *)(s + 0x458))", game_state)
        self.assertIn("s[0x7F] = 0", game_state)
        self.assertIn("s[0x481] = 0", game_state)
        self.assertIn("*(volatile uint32_t *)(s + 0x5A8) = 0", game_state)
        self.assertNotIn("s[0x47F]", game_state)
        self.assertNotIn("sub_08049268", startup)
        self.assertIn("GameState_FramePrepare();", startup)

    def test_resource_node_validator_is_recovered_and_uses_rom_diagnostics(self):
        source = self.read("src/resource_node.c")
        harness = self.read("tests/test_resource_node.c")
        listing = self.read("asm/runtime/resource_node_validate_604f8.thumb.dis.txt")
        body = source.split("void ResourceNode_ValidateActiveList(", 1)[1].split(
            "/* 0x08060B5C", 1
        )[0]

        self.assertIn("ResourceNode_ValidateActiveList(void *opaque_head)", source)
        self.assertNotIn("extern void ResourceNode_ValidateActiveList", source)
        self.assertIn("current + 0x04", body)
        self.assertIn("previous + 0x04", body)
        self.assertIn("current + 0x00", body)
        for message in ("0x0875591Cu", "0x08755938u", "0x08755954u"):
            self.assertIn(message, body)
        self.assertIn("bl 0x08057C5C", listing)
        self.assertIn("diagnostic_messages[0] == 0x08755954", harness)
        self.assertIn("diagnostic_messages[1] == 0x08755938", harness)

    def test_old_fatal_imports_bind_to_observed_return_only_abis(self):
        memory = self.read("src/runtime_memory.c")
        blocks = self.read("src/runtime_block_helpers.c")
        object_table = self.read("src/runtime_object_table.c")
        prototypes = self.read("include/recovered_runtime.h")
        memory_asm = self.read("asm/pass5/sub_62e94.thumb.s")
        block_asm = self.read("asm/runtime/runtime_block_helpers_62fcc_631d4.thumb.dis.txt")
        object_asm = self.read("asm/pass5/sub_62490.thumb.s")

        self.assertNotIn("FatalError", memory + blocks + object_table + prototypes)
        self.assertIn("sub_08057B60((const void *)(uintptr_t)0x08755E48u)", memory)
        self.assertIn("sub_08057B60((const void *)(uintptr_t)0x08755EB0u)", blocks)
        self.assertIn("sub_08057C5C((const void *)(uintptr_t)0x08755DB4u,", object_table)
        self.assertIn("allocation_size);", object_table)
        self.assertIn("0x08755DE8u, 0x440u", object_table)
        self.assertIn("0x57b60", memory_asm.lower())
        self.assertIn("0x8057b60", block_asm.lower())
        self.assertGreaterEqual(object_asm.lower().count("0x57c5c"), 2)


if __name__ == "__main__":
    unittest.main()
