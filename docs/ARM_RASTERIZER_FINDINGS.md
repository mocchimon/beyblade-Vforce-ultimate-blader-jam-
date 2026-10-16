# ARM-state rasterizer image: instruction-level recovery

## Scope and confidence

This document describes the ARM-state image at ROM `0x080641B8–0x08064EDB` (length `0xD24`) using its instructions and control flow. The original ROM bytes are not included in this repository. The high-level names below are semantic working labels, not recovered original symbols.

**High confidence:** the image contains pixel/sample generation, fixed-point interpolation, primitive-edge processing, and row-stepping routines. **Not proven:** the precise graphics primitive type for every routine, the runtime address where the image is installed, or a connection between this image and the direct IWRAM targets `0x0300646C` / `0x0300682C`.

## Recovered routine map

| ROM address | Image offset | Working label | Evidence |
|---|---:|---|---|
| `0x080641B8` | `0x000` | `ArmRaster_EmitSamples` | C sample-sequence helper in `src/arm_rasterizer.c`; computes up to three fixed-point samples from `r1/r2/r3`. |
| `0x08064218` | `0x060` | `ArmRaster_EmitPackedSamples` | C sample-sequence helper in `src/arm_rasterizer.c`; reproduces the reciprocal-table increments and output bytes. |
| `0x08064364` | `0x1AC` | `ArmRaster_ProcessPrimitiveEdges` | Reads three 16-byte-stride coordinate records and an 8-byte primitive record, sorts by signed Y, calculates reciprocal-table slopes, and writes a compact edge/attribute descriptor; C source is in `src/arm_rasterizer_tables.c`. |
| `0x080645EC` | `0x434` | `ArmRaster_ProcessAlternateEdgeCase` | Alternate edge path with the same fixed-point slope/table operations and output-record writes. Treat as a helper/alternate branch until full callers are recovered. |
| `0x08064724` | `0x56C` | `ArmRaster_ClampSpan` | Orders endpoint values, converts coordinates to a 64-unit row/column domain, and clamps span/count fields. |
| `0x08064850` | `0x698` | `ArmRaster_DrawRows` | C behavior reconstruction in `src/arm_rasterizer.c`; draws clipped spans at 64-byte row increments and advances fixed-point endpoints. |
| `0x08064A14` | `0x85C` | `ArmRaster_ApplyVertexParameters` | C behavior reconstruction in `src/arm_rasterizer.c`; uses a coefficient table and signed per-row transforms, with caller semantics provisional. |
| `0x08064AFC` | `0x944` | `ArmRaster_TransformVertexRows` | C behavior reconstruction in `src/arm_rasterizer.c`; transforms 10-byte input records into 16-byte outputs, with caller semantics provisional. |
| `0x08064C38` | `0xA80` | `ArmRaster_InsertBucketItem` | Appends a node to a bucket-linked list with a signed-halfword `-1` terminator. |
| `0x08064C8C` | `0xAD4` | `ArmRaster_BuildEdgeBuckets` | Builds primitive buckets using packed vertex references, a signed orientation test, and a 32-level fixed-point bucket domain. |
| `0x08064DE0` | `0xC28` | `ArmRaster_ProcessEdgeBuckets` | Walks bucket chains and dispatches primitive processing/row drawing. |
| `0x08064E54` | `0xC9C` | `ArmRaster_CopyEightRowSlices` | Gathers eight 8-byte slices from source rows at a caller-provided stride and writes a 64-byte block; exact texture/layout semantics unresolved. |

The routine at `0x08064E50` is not an entry: its first word is zero/padding. The copy helper begins at `0x08064E54`. The relocation/entry-offset table begins at `0x08064EDC`. Its early values include `0x1AC`, `0x60`, `0xA80`, `0xAD4`, `0xC98`, `0x698`, `0xC9C`, `0x85C`, and `0xC28`. These correspond to offsets inside this image and support the function-boundary map above, but the loader's complete table interpretation still needs to be reconstructed.

## Structural observations

- The image is ARM-state code, not Thumb. Disassembly must use ARM decoding for this range.
- The routines use signed-halfword lookup values and shifts around 6, 7, 8, 9, 12, and 16 bits, consistent with fixed-point coordinate/attribute calculations.
- `ArmRaster_EmitPackedSamples` writes byte-oriented output while packing four samples per 32-bit word, including unaligned head/tail handling.
- `ArmRaster_DrawRows` advances its destination by `0x40` bytes per iteration and calls the sample generators. That is strong evidence of a 64-byte row stride in the output surface or intermediate buffer.
- The primitive processor consumes three records at a `0x10`-byte stride and computes edge slopes/intersections before producing row/sample data.

## Important limitation: do not conflate this with the IWRAM targets

The tempting offset comparison between `0x0300646C` / `0x0300682C` and offsets `0x2B4` / `0x674` within this image is not a proven installation path. The currently recovered loader at `0x0805EFC0` copies this image into a heap allocation, and the ordinary heap is in EWRAM. The two IWRAM dispatch targets remain a separate unresolved problem.

## Next steps

1. Validate `ArmRaster_BuildEdgeBuckets` against disassembly-level tests and recover the caller-side descriptor types.
2. Compare the C primitive and row renderers against rendered-output fixtures, including repeated-index and clipped spans.
3. Trace callers of the relocated image's entry points and reconstruct the relocation-table consumer.
4. Continue a separate writer audit for `0x0300646C` and `0x0300682C`; do not use this image as their source without byte-level evidence.
5. Recover the larger game-state, audio, and asset-semantic layers.

## 2026-10-10 — bucket-list and edge-dispatch source recovery

Two additional entries were converted from instruction-level analysis into C
source in `src/arm_rasterizer_tables.c`. The helper at `0x08064C38` appends an
item to an indexed bucket list using 4-byte nodes containing two signed
halfwords (`item`, `next`) and `-1` as the terminal link. The routine at
`0x08064DE0` walks bucket heads and node chains, resolves each node's vertex
index into an 8-byte-stride record table, calls the primitive-edge processor,
and conditionally calls the row renderer.

This clarifies a previously opaque part of the rasterizer's data flow: the
image includes linked bucket lists that feed edge/row rendering. The source
keeps descriptor offsets and semantic names provisional. The adjacent helper
at `0x08064C8C` has also been translated as `ArmRaster_BuildEdgeBuckets`. It
handles default or selected primitive ranges, applies a signed orientation
test, derives a bucket from three fixed-point attributes, and inserts accepted
primitive indices into linked buckets. Descriptor field names and attribute
semantics remain provisional. The matching-ROM build remains unimplemented.

## 2026-10-16 — primitive-edge source recovery

`0x08064364` now has a C behavior reconstruction named
`ArmRaster_ProcessPrimitiveEdges` in `src/arm_rasterizer_tables.c`. It covers
the three-record signed-Y ordering, the repeated-index branch to `0x08064724`,
the row-span split at `0x080645EC`, the reciprocal-table multiply/shift
sequence, and the packed output writes. The table pointer was read from the
literal at `0x08064214` (`0x0874D1E4` in the supplied ROM).

The `0x08064DE0` walker now passes the descriptor's `+0x10` coordinate-record
base and the selected 8-byte primitive record from `+0x08`. It calls the
primitive processor and row renderer through source definitions. The source
has frontend and integration validation, but no object-symbol audit or
rendered-output comparison was available. See
`docs/ARM_RASTERIZER_PRIMITIVE_RECOVERY.md` for primitive field offsets and
`docs/ARM_RASTERIZER_ROW_DRAWING_RECOVERY.md` for row-rendering details.

`0x08064850` and its sample emitters now have C behavior reconstructions in
`src/arm_rasterizer.c`; the shared ARM-state entry declarations are in
`include/arm_rasterizer.h`. See `docs/ARM_RASTERIZER_ROW_DRAWING_RECOVERY.md`.
Pixel comparison and object-level linkage verification remain outstanding.

## 2026-10-16 — vertex-parameter source recovery

`0x08064A14` now has a C behavior reconstruction named
`ArmRaster_ApplyVertexParameters`. The source preserves the table indexing,
wrapped matrix products, adjusted output words, per-row weighted-byte
transform, signed clamp condition, and `+0x30` maximum store. The table pointer
literal at `0x08064AF8` was confirmed as `0x0874CC60` in the supplied ROM.
The caller and graphics-level meanings of the input record remain unresolved;
see `docs/ARM_RASTERIZER_VERTEX_PARAMETERS_RECOVERY.md`.

## 2026-10-16 — vertex-row transform source recovery

`0x08064AFC` now has a C behavior reconstruction named
`ArmRaster_TransformVertexRows`. It preserves the 10-byte input, 6-byte
interpolation-target, and 16-byte output strides; optional signed interpolation;
the scale-plus-3x3 matrix multiply/accumulate order; the zero-mode projection
branch; signed minimum tracking; and final context stores. Matrix accumulations
use the ARM `MLA` add semantics. The entry's caller and field meanings remain
unresolved; see `docs/ARM_RASTERIZER_VERTEX_ROWS_RECOVERY.md`.
