# Runtime buffer descriptor (`0x080631D4–0x08063244`)

## Constructor at `0x080631D4`

The constructor accepts a descriptor pointer, a source pointer, two dimensions,
and a row/count argument. It rounds both dimensions down to even values, then
allocates `2 * aligned_stride * row_count` bytes through `Heap_Alloc`. Because
that allocator returns a heap-block descriptor rather than the payload address,
the constructor stores both the allocation descriptor at `+0x10` and the first
word of that allocation descriptor (the payload address) at `+0x0C`.

Observed descriptor layout (`0x14` bytes):

| Offset | Width | Meaning supported by use |
|---|---:|---|
| `+0x00` | 32 | source pointer |
| `+0x04` | 16 | destination horizontal offset, measured in halfwords |
| `+0x06` | 16 | row stride, measured in halfwords |
| `+0x08` | 16 | row count/bound |
| `+0x0A` | 16 | not written by this constructor; retained as reserved |
| `+0x0C` | 32 | allocated buffer payload pointer |
| `+0x10` | 32 | heap allocation descriptor pointer |

## Row operation at `0x08063210`

The row routine returns when the signed row index is negative or not less than
the count at `+0x08`. Otherwise it calculates `payload + row * stride * 2`,
adds `destination_x * 2` to the supplied destination, and dispatches a copy of
`stride * 2` bytes through the function pointer stored at `0x0807D998`.
The call reaches the shared `bx r3` trampoline at `0x08065C44`; the concrete
runtime copy target is not identified here.

## Confidence boundary

Offsets, alignment masks, allocation-size expression, row bounds, byte scaling,
and callback slot are directly visible in the instructions. The broader semantic
role of the descriptor and the identity of the installed copy backend remain
unresolved. The C reconstruction preserves this distinction.
