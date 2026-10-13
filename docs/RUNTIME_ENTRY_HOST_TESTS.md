# Runtime-entry selection and lifecycle regression tests

The `tests/test_runtime_entries.c` host harness maps the GBA IWRAM window at
`0x03000000` and initializes the runtime-entry globals used by
`src/runtime_entries.c`. It tests the previously recovered ROM routines at
`0x08062974` (indexed initializer), `0x080629B4` (indexed allocation), and
related entry-management operations.

Verified simulated behaviors:
- signed-halfword selector value 2 chooses the third source-table pointer;
- indexed initialization stores source, source+0x10, TABLE_0D98[0], and
  source-table and selector pointers at the expected record offsets;
- ordinary allocation uses a supplied TABLE_0D98 index;
- serial values advance across allocations, and a full pool returns -1;
- status 1->2->1 transitions, limit clamping to 0x100, pointer changes,
  deactivation, and reuse of a freed slot.

The host harness exercises reconstructed C logic, not original GBA instructions.
It cannot establish binary equivalence or validate behavior in an emulator.
Two pointer conversions in `src/runtime_entries.c` were made explicit through
`uintptr_t` to permit warning-clean 64-bit host compilation without changing
32-bit ARM7TDMI semantics.

Run: `make test-runtime-entries` or `make test-all`.
