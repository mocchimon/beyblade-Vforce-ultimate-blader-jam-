# Runtime-entry service recovery — 2026-10-10

## Evidence region

- `0x080627CC`: per-entry resource-boundary service.
- `0x08062814`: gated pass over the runtime-entry pool plus timing-window/transfer bookkeeping.
- Disassembly: `asm/runtime/runtime_entry_service_627cc_62814.dis.txt`.

## Confirmed behavior at 0x080627CC

1. Entries are processed only while status byte `+0x16` equals `1`.
2. The routine calls a shared refresh/transfer helper with the entry pointer in `r0` and a context word loaded through ROM literal `0x0807D988` in `r3`.
3. The entry's `+0x00` field points at a resource record. Its words at `+0x04` and `+0x08` provide two boundaries used with the record's `0x10`-byte header.
4. The entry's `+0x04` field is compared to `source + *(source+4) + 0x10`. If it has not reached that boundary, this path makes no further changes.
5. When the boundary is reached and `*(source+8)` is zero, status is cleared. Otherwise, the routine calls `0x0806625C` with the cursor overrun and signed difference between the two boundaries, then sets the cursor to the second boundary plus the helper result.

The helper at `0x0806625C` is an unsigned remainder operation: when the divisor is zero it calls a no-op divide-by-zero path and returns zero; otherwise it returns `numerator % denominator`. It is reconstructed as `Math_ModuloUnsigned` in `src/math_runtime.c`, using a shift/subtract implementation to avoid relying on compiler runtime support. The entry cursor update is therefore modeled as `second_end + ((cursor - first_end) % (first_end - second_end))` with 32-bit unsigned arithmetic.

## Confirmed service gate at 0x08062814

The function returns immediately if either `0x03005E1C` or the enabled field at `0x03005E44` is zero. Otherwise it calls `0x08062C48`, iterates the table rooted at `0x03005E24` with `0x28`-byte stride for the count at `0x03005E04`, and calls `0x080627CC` on each entry. It then updates an aligned timing window and dispatches a transfer through a separate block whose exact semantics are still being recovered.

## Confidence boundary

The field offsets, status gate, record stride, boundary comparisons, and call sequence are directly supported by instruction flow. The names “resource boundary” and “timing window” are descriptive hypotheses, not established game-specific subsystem names. The timing/transfer tail remains a helper boundary rather than an invented implementation.
