# Runtime-entry timing and transfer dispatch

## Evidence recovered from the original ROM

The Thumb routine at `0x08062814` is a timer-window service, not just a gate around an entry loop. Its control flow is now represented in `src/frame_dispatch.c`.

- Gate 1: the context pointer at `0x03005E1C` must be nonzero.
- Gate 2: the word at `0x03005E44` must be nonzero.
- Calls `0x08062C48` before sampling Timer0.
- Reads Timer0 at `0x04000100`, adds one, rounds down to an even count, and handles the `0x10000` wrap sentinel by loading the replacement value from `0x03005E18`.
- Stores the current sample at `0x03000D94` and computes one contiguous elapsed segment, plus a second segment when the timer wrapped.
- Calls the per-entry service at `0x080627CC` for each 0x28-byte entry, passing the total elapsed window in `r1` and the halfword at `0x03000DA0` in `r2`.
- Calls the transfer callback through `*(uint32_t *)0x03000D8C`. A normal segment is submitted as `(cursor, segment_length, 0)`; a wrapped segment is submitted as `(cursor - interval, wrapped_length, first_segment_length)`.
- Updates the cursor at `0x03000D90` and normalizes the exact end pointer against `context + interval`.

The callback's higher-level purpose is not yet proven. It is intentionally named `RuntimeTransferCallback` rather than assuming it is audio or video.

## Corrected indirect call contract at `0x080627CC`

The call at `0x080627DC` is a `bx` dispatch through the word stored at ROM address `0x0807D988`; the word currently equals `0x03006C60`. It passes the entry pointer in `r0`, the caller's elapsed-window value in `r1`, and the per-entry threshold in `r2`. The earlier C draft incorrectly modeled this as a four-argument helper with the ROM slot address itself treated as an argument. `src/runtime_entry_service.c` now follows the observed three-argument ABI.

The callback target at `0x03006C60` is in IWRAM. Its installation/source remains unresolved; this finding does not claim the code bytes have been recovered.

## Validation and limits

- The updated source set compiles for ARM7TDMI with `-Wall -Wextra` and no warnings.
- The source reconstruction follows the observed register and memory operations, but no linked ROM or cycle/timing equivalence has been demonstrated.
- The per-entry threshold is read inside the loop, matching the original load placement rather than caching it once for the whole pass.
