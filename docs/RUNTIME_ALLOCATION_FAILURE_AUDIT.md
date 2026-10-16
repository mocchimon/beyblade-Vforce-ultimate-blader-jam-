# Runtime allocation failure audit

## Corrected: script-owned entry creation

`RuntimeEntry_Alloc` returns `-1` when the fixed-size runtime pool has no free entry. `Script_AddEntry` previously stored `0xffffffff` as the handle and marked the script slot active. It now leaves the slot inactive and does not call `RuntimeEntry_SetLimit` on a failed allocation. The host regression test simulates pool exhaustion and checks both invariants.

## Remaining audit targets

- `RuntimeResource_Select` also records the allocator return as an unsigned serial and selects the resource even if allocation fails. Its ROM-specific error semantics are unknown; do not change without disassembly evidence.
- `RuntimeTable_AllocateIndexed` ignores the allocator result, but has no script-slot state to corrupt.
- `RuntimeEntry_AllocIndexed` uses an unbounded signed index read from a secondary table. Bounds and negative-index behavior require original ROM evidence.
- `RuntimeEntry_Alloc` serial wraparound and entry-pool exhaustion semantics are not yet ROM-matched.

This change improves source robustness, but is not evidence of an exact assembly match or additional recovered functions.
