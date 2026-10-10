# ARM rasterizer: bucket lists and edge dispatch

## Newly reconstructed entries

This pass converted two ARM-state routines into C-oriented source:

- `0x08064C38` (`+0xA80`) → `ArmRaster_InsertBucketItem` in
  `src/arm_rasterizer_tables.c`.
- `0x08064C8C` (`+0xAD4`) → `ArmRaster_BuildEdgeBuckets` in the same file.
- `0x08064DE0` (`+0xC28`) → `ArmRaster_ProcessEdgeBuckets` in the same file.

These names describe observed behavior and are not original symbols.

## `ArmRaster_InsertBucketItem`

Register-level inputs at entry are `r0` = table descriptor, `r1` = bucket
index, and `r2` = signed item value. The routine reads a halfword node count at
`+0x04`, a bucket-link array pointer at `+0x08`, and a node-link array pointer
at `+0x0C`. A node occupies four bytes: `{item, next}` as signed halfwords.
It initializes the new node's next link to `-1`; an empty bucket receives the
new node index as both head and tail, while a non-empty bucket appends the node
after its previous tail. Finally it increments the node count.

The node/bucket interpretation is high confidence from the halfword accesses,
scaled-by-four addressing, sentinel comparison, and exact store sequence. The
meaning of the stored item (later used as a vertex/edge index) is still
caller-dependent.

## `ArmRaster_BuildEdgeBuckets`

The routine at `0x08064C8C` processes either a default run of primitive
records or a sentinel-terminated selection list. The selection-map path resolves
each selection into a `{start,count}` pair. Each primitive reference record is
eight bytes and packs three 16-bit vertex indices plus a flag halfword; the
referenced vertex/coordinate records are 16 bytes apart. For non-degenerate,
non-flagged primitives, the routine computes a signed 2-D orientation
determinant and skips insertion when it is positive. Otherwise it averages
three signed fixed-point values from record offset `+8`, shifts to a 32-level
bucket domain, applies a one-unit bias selected by the alternate path, reverses
the bucket index (`31 - value`), and appends the primitive index to that bucket.

This is now translated in C. The register-level field offsets and fixed-point
operations are recovered, but the original names and semantic identity of the
`+8` vertex attribute are still unknown. The source deliberately retains raw
descriptor offsets rather than asserting a fully understood graphics format.

## `ArmRaster_ProcessEdgeBuckets`

At `0x08064DE0`, the function reads a halfword iteration count at `+0x00`,
bucket heads at `+0x08`, and node records at `+0x0C`. The second descriptor
supplies an 8-byte-stride vertex-record base at `+0x08` and row parameters at
`+0x10`. For each bucket, it follows signed-halfword node links until the
`-1` sentinel. Each node's first halfword selects an 8-byte vertex record;
the function passes that record to the primitive-edge routine at
`0x08064364`. When that routine returns nonzero, it invokes row drawing at
`0x08064850` with the original draw-list argument.

The loop and pointer strides are directly visible in the ARM instructions.
The C translation retains the raw descriptor offsets because the enclosing
structures are not fully reconstructed. Calls to `ArmRaster_ProcessPrimitiveEdges`
and `ArmRaster_DrawRows` are semantic external declarations for the source
reconstruction; their own complete C bodies are not yet present. Thus this
file improves the source-level call graph but does not make the project
linkable or prove pixel-identical output.

## Validation

The new file is compiled in ARM state (`-marm`) by the project's compile-only
Makefile, matching the original image's ARM instruction state. Other existing
source files use Thumb state. `make check` compiles objects only and is not a
ROM build.
