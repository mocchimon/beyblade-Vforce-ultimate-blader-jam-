# Development pass 33 — 2026-10-17

## Indexed tile compositor at `0x0805B2A4`

Recovered the complete routine as
`RuntimeDisplay_BlitIndexed4bppTile` in
`src/runtime_display_tile_blit.c`. ROM instructions establish that it:

- Rejects an unsigned `y` above 152 and uses the wrap-aware `x + 7` check,
  which admits `x` from -7 through 239.
- Reads four halfword indices from `map_cell[0]`, `[1]`, `[32]`, and `[33]`.
  The shared address helper masks each index to 10 bits and scales it by
  32 bytes.
- Reads eight source words. The low three `x` bits shift each word by four
  bits per pixel; the low three `y` bits split the eight source rows between
  the two selected map rows.
- Writes left/right fragments into up to four destinations using bitwise OR,
  preserving the existing destination bits. Writes are clipped at tile
  columns `-1` and `29`.

The direct caller at `0x0805B638` calculates the map-cell pointer from tile
coordinates and passes `x` in `r3`, with `y` as the fifth stack argument. This
supports the provisional interpretation as an 8x8 4bpp tile blitter. No
runtime image comparison has been performed, so visual output equivalence is
not claimed.

The new ROM verifier matches **150 Thumb halfwords** across the full routine
and caller setup, checks **5 direct call destinations**, and checks **10
conditional branch targets**. The four internal helper calls remain Thumb to
Thumb; the separate background callback's Thumb-to-ARM path and unresolved
IWRAM installer status are unchanged.

## Verification and project status

- ROM verifiers for passes 26–33 passed, as did the pass 32 IWRAM target scan.
- The complete ROM-enabled Python suite passed **112 tests with zero skips**.
- Libclang parsed **56 C translation units** for ARM7TDMI with zero
  diagnostics. This is a frontend syntax check, not object generation.
- No ARM object/link or candidate ROM was produced. The local host still lacks
  the required ARM toolchain and original link layout.
- Source-recovery progress remains the historical **~54% estimate**, which is
  rough and unmeasured. Matching-ROM progress remains **0%**.
