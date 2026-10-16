# Development pass 15 — runtime-record linkage correction

## Work completed

Replaced the stale address-named call `sub_08050388` in `GameState_Init` with
the recovered `RuntimeRecord_Clear` function. Added a shared declaration in
`include/runtime_record.h`. Comparing the source with the original Thumb
instructions showed that `RuntimeRecord_Clear` must preserve the manager's
record pointer at `+0x00`; the earlier C body incorrectly zeroed it. The
function now clears only the six fields written by the ROM. The function map
also now gives the confirmed `0x18`-byte record stride.

Details are in `docs/RUNTIME_RECORD_CLEAR_LINKAGE_RECOVERY.md`.

## Verification

- C frontend parse: **42/42 translation units**, with **2 ARM-state** and
  **40 Thumb-state** modes; **0 frontend errors**.
- Python regression suite: **33 tests passed**. The ROM-backed alias metadata
  integrity check also passed.
- Source integration check confirms `GameState_Init` imports the recovered
  name and exactly one C definition provides it. The test also confirms the
  clear body preserves `+0x00` and clears the fields observed in the ROM.

`make check` and `make partial-link` remain unavailable because `make` is not
installed. No object-symbol inventory, partial link, or candidate `.gba` was
produced. The historical **~54%** completion figure remains a rough estimate,
not a measured coverage rate; it is unchanged by this pass.
