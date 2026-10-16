# Development pass 14 — ARM vertex transforms

## Work completed

Added `ArmRaster_TransformVertexRows` for image entry `0x08064AFC` in
`src/arm_rasterizer.c`, with its ARM-state declaration in
`include/arm_rasterizer.h`. The entry reads 10-byte input records and six-byte
target records, writes 16-byte output records, optionally interpolates values,
applies the observed scale and 3x3 matrix accumulation, conditionally projects
the coordinates, and stores signed minima into the transform context. The
matrix direction follows the ARM `MLA` instructions as additions with 32-bit
wraparound.

The previous pass's `ArmRaster_ApplyVertexParameters` at `0x08064A14` remains
documented in `docs/PASS13_DEVELOPMENT_2026-10-16.md`. Both entries' caller-side
semantics are unresolved. The new entry's field offsets and evidence are in
`docs/ARM_RASTERIZER_VERTEX_ROWS_RECOVERY.md`.

## Verification

- C frontend parse: **42/42 translation units**, with **2 ARM-state** and
  **40 Thumb-state** modes; **0 frontend errors**.
- Python regression suite: **32 tests passed**. The ROM-backed alias metadata
  integrity check also passed.
- Static integration checks confirm both new rasterizer entries are declared
  and defined in the ARM-state unit; the `0x08064AFC` instruction stream and
  original record strides are referenced by the recovery test.
- The table literal at `0x08064AF8` remains verified as `0x0874CC60`; the
  earlier rasterizer table literal at `0x08064214` remains `0x0874D1E4`.

The environment still lacks `make`, a command-line C compiler, ARM object
tools, and a recovered ROM linker script. `make check` and `make partial-link`
therefore remain unavailable. No object inventory, relocatable link, or
candidate `.gba` was produced.

## Progress estimate

The historical **~54%** traditional-decompilation figure remains a rough,
unrecalculated estimate. This pass adds one instruction-backed ARM entry in C;
it does not provide a measured coverage percentage. Matching-ROM build progress
remains unverified; no candidate ROM was built.
