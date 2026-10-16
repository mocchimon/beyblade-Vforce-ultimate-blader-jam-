# Runtime-entry service integration tests (2026-10-13)

`tests/test_runtime_entry_service.c` executes the recovered C implementation of
`RuntimeEntry_ServiceOne` (`0x080627CC`) together with `Math_ModuloUnsigned`.
The harness maps simulated GBA IWRAM and the ROM callback-pointer slot at
`0x0807D988` into the host process; it never includes or modifies ROM data.

Covered scenarios:
- Inactive status prevents callback and cursor updates.
- Active status invokes callback with the original entry, window, and threshold.
- Cursor below the first resource boundary is unchanged.
- Exact first-boundary crossing wraps to the second boundary.
- Larger overrun wraps by the recovered unsigned-modulo calculation.
- A zero second-length field clears the active status.
- Equal boundary values exercise the recovered modulo helper's zero-divisor path.

Run `make test-runtime-entry-service` or `make test-all`. The test executable
uses `-no-pie` so its callback pointer fits the GBA's 32-bit address slot.
This is host behavioral verification, **not** a matching-ROM build or proof
that the original binary's IWRAM callback has been recovered.
