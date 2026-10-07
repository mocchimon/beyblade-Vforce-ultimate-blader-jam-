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

The function beginning at `0x08050398` takes a destination record, a source
record, and a 16-bit-sized third argument. The source's `+0x08` count is
multiplied by `0x1C`, allocated through `Heap_AllocAlt`, and the resulting
record receives source/count/capacity fields. It then initializes a sequence
of `0x1C`-byte entries from the source descriptor.

A conservative C reconstruction is in `src/object_record.c`; it should be
considered structural rather than byte-matching C until all writes in the
loop are correlated with its consumers.

## Next targets

1. `0x0804AF08` / `0x0804AF60` — callers from the runtime synchronization path.
2. `0x08050398` consumers — identify the meaning of the `0x1C`-byte records.
3. `0x08050A74` / `0x08050AA0` — related table/object allocation path.
4. Continue outward from `0x0804945C` into the actual state handlers.
