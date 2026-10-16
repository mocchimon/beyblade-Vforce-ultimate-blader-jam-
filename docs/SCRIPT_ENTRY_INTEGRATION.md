# Runtime script and entry integration test

The script interpreter (`src/runtime_script.c`, original routine at 0x08062C48) and runtime-entry manager (`src/runtime_entries.c`, 0x08062934/0x08062974/0x080629B4/0x08062A14) are now exercised **together** in `tests/test_script_entry_integration.c`, with a simulated 64 KiB IWRAM mapping.

The test executes the following reconstructed control path:

1. Install and start a script descriptor.
2. Execute `C0 03` to select a source pointer through the descriptor's table.
3. Execute `90 07 0C` to allocate entry identifier 7 and apply limit 12.
4. Verify entry serial, selected source, `source+0x10`, table value, active state, and fixed-point delay.
5. Execute `80 07 00` to remove the script-owned entry.
6. Allocate another entry and confirm freed-slot reuse with a new serial.
7. Stop the script and verify that the separately allocated entry is not incorrectly deactivated.

## Portability correction

The original GBA globals at `0x03005E24` and `0x03000D98` contain **32-bit addresses**. Earlier C read them as native `RuntimeEntry *` and `uint32_t *` pointer objects. On a 64-bit host, the first load also consumed the adjacent script-record global at `0x03005E28`, constructing an invalid pointer. The macros now load a 32-bit word and convert via `uintptr_t`. The ARM7TDMI representation remains 32-bit.

This test checks reconstructed C behavior and shared RAM layout, **not** exact ROM instruction equivalence, full GBA execution, or a matching-ROM build.
