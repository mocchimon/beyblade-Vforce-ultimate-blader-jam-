# Development pass 13 — vertex-parameter rasterizer recovery

## Work completed

Added `ArmRaster_ApplyVertexParameters` in `src/arm_rasterizer.c` for the ARM
image entry at ROM `0x08064A14`, and added its declaration to
`include/arm_rasterizer.h`. The C reconstruction preserves the signed table
lookup at `0x0874CC60`, wrapped coefficient products, signed offset
subtractions, three-byte row transform, logical phase shift, signed `GT`
clamp, do/while row count, and final halfword store. The literal at
`0x08064AF8` was checked against the supplied ROM and contains `0x0874CC60`.

The field names and caller-level meaning remain provisional. The current
disassembly establishes the entry behavior, but no caller-side execution
fixture or rendered output is available.

## Verification performed

- C frontend parse: **42/42 translation units**, with **2 ARM-state** and
  **40 Thumb-state** modes; **0 frontend errors**.
- Python regression suite: **31 tests passed**. The ROM-backed alias metadata
  integrity check also passed.
- Static source integration checks confirm the new entry is declared and
  defined in the ARM-state rasterizer unit.

The environment still lacks `make`, a command-line C compiler, ARM object
tools, and a recovered ROM linker script. `make check` and `make partial-link`
therefore remain unavailable. No object inventory, relocatable link, or
candidate `.gba` was produced.

## Progress estimate

The historical **~54%** traditional-decompilation figure remains a rough
estimate and was not recalculated. This pass adds one instruction-backed ARM
entry in C; that is a concrete source change, not a measured coverage rate.
