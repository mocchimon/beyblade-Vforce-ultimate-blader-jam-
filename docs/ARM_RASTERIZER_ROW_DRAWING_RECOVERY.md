# ARM rasterizer row-drawing recovery

## Recovered entries and state

The row renderer at ROM `0x08064850` is reconstructed as
`ArmRaster_DrawRows` in `src/arm_rasterizer.c`. Its two sample emitters at
`0x080641B8` and `0x08064218` are represented by local C helpers in the same
file. `include/arm_rasterizer.h` declares the row renderer and primitive-edge
entry shared by the two ARM-state translation units. The Makefile compiles
both units with `-marm`, matching the original image's instruction state.

## Behavior preserved from the instruction flow

- Reads the first row, total row count, upper segment count, and orientation/
  degenerate flags from the edge record. It clips the ending row to row 31 and
  advances output rows at a `0x40`-byte stride.
- For ordinary triangles, calculates the signed fixed-point span from the two
  active edges, clips a negative left edge to column zero, emits samples, and
  switches the active edge/attribute record at the upper-segment boundary.
- For the repeated-index path, chooses edge order from the signed X slope,
  walks the span, and preserves the minimum 64-unit edge separation and final
  endpoint adjustment.
- Uses the reciprocal table whose pointer literal at ROM `0x08064214` is
  `0x0874D1E4`. Sample generation keeps the original fixed-point shifts and
  count-dependent increments; the packed emitter writes the same byte sample
  sequence while expressing its alignment-specific stores as byte writes.

The output structure's semantic field names and the wider graphics format are
still provisional. This C translation follows the observed loads, stores,
branches, and arithmetic; it has not been compared against rendered pixels.

## Linkage and verification limits

The bucket walker now calls C definitions for both
`ArmRaster_ProcessPrimitiveEdges` and `ArmRaster_DrawRows`. Those entries are
declared in a shared header and belong to ARM-state source units, so the
source-level call does not cross an ARM/Thumb boundary. A fresh object-symbol
audit could not be produced because this environment has no ARM object
compiler, linker, or `make` executable. The C frontend and integration tests
check source shape and target mode but do not verify emitted call veneers or
execute this renderer. The relocatable integration link and matching `.gba`
build remain unavailable; the project still lacks the required local
toolchain and recovered ROM linker layout.
