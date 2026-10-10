# ARM rasterizer copy helper (`0x08064E54`)

## Recovered behavior

The function starts at `0x08064E54` (not `0x08064E50`; the first word at
`0x08064E50` is zero/padding). Its ARM instructions gather eight 8-byte slices
from source addresses separated by a caller-provided stride and emit the eight
slices contiguously as a 64-byte destination block.

Register-level interface inferred directly from the function body:

- `r0`: outer chunk count
- `r1`: source stride in bytes
- `r2`: source pointer
- `r3`: destination pointer

Each outer iteration reads eight pairs of 32-bit words from `source + row *
stride`, writes 64 bytes, and advances the source column by eight bytes. When
the remaining count is divisible by eight, the assembly adjusts the source by
`stride * 8 - 64`, advancing to the next 8-row group while accounting for the
column step already performed.

This is consistent with a block/tile-oriented gather or swizzle operation,
but the caller's data format and exact graphics meaning are not yet proven.

## Reconstructed C

A source-level equivalent is in `src/arm_rasterizer.c` as
`ArmRaster_CopyEightRowSlices`. It expresses the byte-level behavior without
assuming a particular texture format. The name is a working semantic label,
not an original symbol.

## Confidence

- Eight 8-byte source slices per iteration: high.
- Source stride and destination progression described above: high.
- Exact tile geometry/asset format: unresolved.
