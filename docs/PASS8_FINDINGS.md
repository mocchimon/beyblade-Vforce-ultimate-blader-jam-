# Pass 8 findings

This pass follows the `0x0804901C–0x0804945C` context/state cluster and checks
nearby runtime helpers against their actual Thumb control flow.

## State dispatcher correction

`0x08049348` is a five-entry indirect dispatcher, but the five addresses are
not five conventional standalone C functions. The selected targets at
`0x0804937C`, `0x08049390`, `0x0804939E`, and `0x080493B0` execute as shared
continuations using registers established by the dispatcher. The target table
is at `0x03000650`; a separate context pointer at `0x03000BD8` can override the
selected table entry. A non-null resulting callback/context is passed to
`0x08065C40` with the dispatcher context and mode.

This is why `src/game_state.c` should not model the targets as ordinary
`void handler(void)` functions. The assembly slice in
`asm/pass8/game_state_dispatch.thumb.txt` is authoritative.

## Frame/state dispatch

`0x0804945C` is a substantial loop around VBlank, context history, queued
control processing, object/resource checks, and state dispatch. It repeatedly
returns to the queued-state path until the context pair reaches its terminal
condition. Its exact game-state meaning remains unresolved, so it is still
kept under a neutral name.

## Runtime context service: 0x0804A284

`0x0804A284` compares the current/previous indices in the `0x03000650`
context and examines a per-entry word at `+0x04`. It also checks two byte fields
near `0x03000650 + 0x586`, and conditionally calls `0x0804AF60` or `0x0804AF08`.
This looks like a context/resource synchronization check rather than a direct
gameplay routine.

## Runtime record initialization: 0x08050398

The function beginning at `0x08050398` takes a manager, a source descriptor,
and 16-bit flags. It allocates `source[2] * 0x18` bytes through
`Heap_AllocAlt`, stores the returned heap descriptor at manager `+0x00`, and
stores the descriptor's payload address at `+0x08`. It copies position pairs
from the linked list headed by `source[0]` into 0x18-byte records and zeros
their velocity/acceleration fields. The manager's count is a signed halfword.
Zero-size and failed-allocation paths call the ROM-confirmed return-only
service at `0x08057C5C` and return early.

The update routine at `0x08050420` integrates positions and velocities,
mirrors integrated positions to linked source nodes, and conditionally clamps
one axis at the manager boundary. `src/object_record.c` now reflects these
data flows; it remains behavior-level recovery rather than byte-matching C.

## Next targets

1. `0x0804AF08` / `0x0804AF60` — callers from the runtime synchronization path.
2. `0x08050398` consumers — correlate the record's position/velocity fields
   with higher-level behavior.
3. `0x08050AA0` — related object-table routine; its neighboring updater at
   `0x08050A74` and record helper at `0x08058F18` are now recovered at the
   source/control-flow level. The `0x08058F84` and `0x080596D0` callees remain
   unresolved.
4. Continue outward from `0x0804945C` into the actual state handlers.
