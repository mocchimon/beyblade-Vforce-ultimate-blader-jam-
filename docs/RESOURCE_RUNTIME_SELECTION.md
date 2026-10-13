# Directory selection reaches indexed resource records (2026-10-12)

## Original instruction chain

`0x0804AF08` loads two words from directory `0x08075640 + selection*8` and calls `0x080629B4` with them as `(r0, r1)`.

`0x080629B4` finds an inactive 0x28-byte runtime entry and passes its two arguments through to `0x08062974` as `(r1, r2)`, with the entry pointer in `r0`.

`0x08062974` performs these key operations:

- `ldrsh r3, [r2, #0]` — read a **signed 16-bit index** from the second directory word's target.
- `lsls r3, #2; adds r3, r1; ldr r4, [r3]` — read a **resource pointer** from the first directory word's target, indexed by that signed halfword.
- `str r4, [r0, #0]` and `str r4+0x10, [r0, #4]` — install resource header and payload pointers.
- `str r1, [r0, #0x1C]`, `str r2, [r0, #0x20]`, `strh #1, [r0, #0x24]` — retain table/descriptor pointers and set indexed mode.

**Correction:** The directory entries are **(resource pointer-table base, signed-index descriptor pointer)**, not conventional begin/end ranges. The second word is dereferenced as a signed halfword; it is not an end address.

## ROM-backed results

All 32 directory slots currently select index **0** when initially passed through this function. Slots 0–6 select their respective first resource; odd slots 7–31 select `0x0807DCA4` and even slots 8–30 select `0x080BE234`. The repeated `0xFFFF0000` at the alias descriptor addresses has low halfword `0x0000`, which is why index zero is selected. The high halfword `0xFFFF` is not read by this initializer. The significance of any later index updates and the remainder of the descriptor are unresolved.

The 111-record resource manifest covers **all entries** in the resource directory's pointer tables, whereas this **initial selection** only reaches 9 distinct records. These counts answer different questions and should not be conflated.

Verification: `make trace-directory-runtime ROM=/path/to/game.gba` and `make test-directory-runtime ROM=/path/to/game.gba`.

## Independent reference

The separate `marijnvdwerf/gba-beyblade-vforce` GitHub repository documents a matching-decomp workflow, but its target ROM hash and revision have not been confirmed against our ROM. No upstream code was imported in this pass.
