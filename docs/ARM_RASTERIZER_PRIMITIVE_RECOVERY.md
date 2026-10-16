# ARM rasterizer primitive-edge recovery

## Entry and call contract

`0x08064364` is reconstructed in C as `ArmRaster_ProcessPrimitiveEdges` in
`src/arm_rasterizer_tables.c`. The call at `0x08064DE0` supplies:

- `r0`: edge/attribute output record.
- `r1`: coordinate-record base, from the second descriptor at `+0x10`.
- `r2`: selected 8-byte primitive record, from the second descriptor at
  `+0x08` plus `primitive_index * 8`.

The primitive record contains three 16-bit coordinate-record indices at
`+0`, `+2`, and `+4`, followed by a 16-bit flag word at `+6`. Coordinate
records have a 16-byte stride: signed X at `+0`, signed Y at `+4`, and a byte
attribute at `+0x0C`. The address and stride evidence comes from the entry
loads at `0x08064368–0x08064390` and its caller at
`0x08064DE0–0x08064E20`.

## Recovered control flow

The C source follows the ARM instructions for these paths:

1. If the second and third indices are equal, process the remaining two
   records through the repeated-index path beginning at `0x08064724`.
2. Otherwise sort the three records by signed Y using the same stable compare
   and swap order. Convert the minimum, middle, and maximum Y values to the
   64-unit row domain. Return zero when the full row span is nonpositive.
3. Pack the total and upper row counts, calculate the signed orientation
   comparison from wrapped 32-bit products, and generate slopes from the
   reciprocal table.
4. Select the alternate edge path at `0x080645EC` when the total row count
   equals the upper row count. That path writes a different set of edge fields
   because the lower two vertices occupy the same raster row.

The original ARM code multiplies a shifted difference by a signed halfword
from the reciprocal table and uses an arithmetic shift of 12 or 16 bits. The
table pointer is the literal word at `0x08064214`, whose value in the supplied
ROM is `0x0874D1E4`. The C source refers to that address and does not copy table
bytes into the project.

## Output record offsets

These names describe observed writes only. The renderer's higher-level field
semantics remain provisional.

| Offset | Observed contents |
|---:|---|
| `+0x00`, `+0x08` | Packed attribute origin and slope values; the two-row-span path writes a zero to both fields. |
| `+0x04`, `+0x0C` | Packed X origin and slope for two selected edges; the repeated-index path writes only the low halfword. |
| `+0x06` | Repeated-index path's signed X slope, stored as a halfword. |
| `+0x10` | Packed upper-edge X origin and slope; the equal-row alternate path does not write this field. |
| `+0x14` | Total row count in the low byte and upper row count in the next byte; repeated-index path stores a minimum-one count. |
| `+0x17` | First row, stored as a byte after arithmetic shift by six. |
| `+0x18` | Upper-edge attribute origin and slope; written by the ordinary three-row path. |
| `+0x1E` | Primitive flags with bit zero cleared and shifted left, combined with the orientation bit; repeated-index path forces the low input bit before shifting. |

The exact byte-versus-halfword store widths are preserved because the ARM code
leaves portions of the record untouched on some paths.

## Linkage, state, and verification limits

The definition is in `src/arm_rasterizer_tables.c`, which the Makefile places
in ARM state with `-marm`. The row renderer is defined in
`src/arm_rasterizer.c`; both public contracts are declared in
`include/arm_rasterizer.h`, and both source units use ARM state. The bucket
walker's two rasterizer calls now have source definitions, but no ARM
object-symbol inventory was regenerated in this environment.

The C frontend parsed all source units for ARM7TDMI with each unit's configured
ARM/Thumb mode, and the source-integration checks passed. These checks do not
execute the C routine. There is no rendering fixture or pixel comparison for
this translation, no ARM object compiler/linker or recovered ROM linker script
available here, and no candidate ROM was produced. The historical `~54%`
source-recovery value remains an estimate; source-level definitions do not
establish a coverage percentage.
