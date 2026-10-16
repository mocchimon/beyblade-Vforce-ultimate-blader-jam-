# Development pass 12 — ARM rasterizer source recovery

## Work completed

- Reconstructed ROM entry `0x08064364` as
  `ArmRaster_ProcessPrimitiveEdges`, including signed-Y sorting, repeated
  indices, the row-span branch, reciprocal-table slopes, orientation, and
  edge/attribute output writes.
- Reconstructed `0x08064850` as `ArmRaster_DrawRows`, plus the sample sequence
  helpers at `0x080641B8` and `0x08064218`. The C path covers row clipping,
  ordinary and repeated-index spans, segment transitions, and the observed
  `0x40`-byte row stride.
- Added `include/arm_rasterizer.h` to share the primitive and row entry
  signatures. The caller and definitions are in the two source units that the
  Makefile compiles in ARM state. Both direct rasterizer calls now have C
  definitions at source level.
- Confirmed the literal at ROM `0x08064214` points to `0x0874D1E4`. The original
  ROM remains an analysis input and is not copied into the source archive.

## Verification performed

- C frontend parse: **42/42 translation units**, with **2 ARM-state** and
  **40 Thumb-state** source modes; **0 frontend errors**.
- Python regression suite: **31 tests passed**. The ROM-backed alias metadata
  integrity check also passed.
- Source integration checks confirm both rasterizer entries have definitions
  and the bucket walker uses the shared interfaces.

These checks do not execute the new C routines or compare pixels. No ARM
machine-code objects or symbol inventory were generated. Attempts to run
`make check` and `make partial-link` stopped because `make` is unavailable;
`clang`, the ARM GCC/binutils tools, and a recovered ROM linker script are also
unavailable. No relocatable integration object or candidate `.gba` was built.

## Progress estimate

The project's historical **~54%** traditional-decompilation figure remains a
rough estimate and was not recalculated. This pass measures four rasterizer
entry behaviors represented in C and the verification results above; it does
not establish a source-coverage percentage. Matching-ROM build progress remains
unverified.
