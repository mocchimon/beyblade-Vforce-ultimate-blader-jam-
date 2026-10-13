# Heap-backed surface context constructor (`0x0805FEF4`)

The former stub `ResourceDescriptor_Init` has been translated from the
instruction sequence at `0x0805FEF4–0x0805FFE8` into `src/resource_descriptor.c`.
The neutral source name is retained for compatibility, but the routine is more
accurately described as a heap-backed surface/context constructor.

## Recovered behavior

Inputs are `(width, height, format)`. The routine computes the allocation
size as:

`0x44 + 2 * width * height + 2 * height`

It reports a diagnostic if `height & 3` is nonzero, allocates from the alternate
heap, and installs the payload pointer at `0x03005DC4`. The descriptor pointer
itself is saved in the payload at `+0x0C`.

Observed payload writes:

| Offset | Observed value |
|---:|---|
| `+0x00..+0x02` | zero bytes |
| `+0x03` | zero byte |
| `+0x04` | low byte of `width` |
| `+0x05` | zero byte |
| `+0x06` | low byte of `format` |
| `+0x0C` | heap descriptor pointer |
| `+0x10` | `0x20000 - (0x359E4 / (height >> 1))` using the internal division helper |
| `+0x14` | zero word |
| `+0x18` | `height` |
| `+0x1C` | zero word |
| `+0x20` | `0x10` |
| `+0x24` | payload + `0x44` |
| `+0x28` | payload + `0x44 + height` |
| `+0x2C` | payload + `0x44 + 2*height` |
| `+0x30` and `+0x38` | `+0x2C` value plus `width*height` |
| `+0x34` | same pointer as `+0x2C` |
| `+0x3C` | same pointer as `+0x24` |
| `+0x40` | same pointer as `+0x28` |

The routine also writes zero to the halfword at `0x04000134` and writes
`0x6000 | (format & 0xFFFF)` to `0x04000128`. The peripheral-level meaning of
those two register writes has not been inferred. Fields at `+0x08` and `+0x07`
are not initialized by this routine; source intentionally does not invent
values for them.

## Confidence and limitations

The allocation arithmetic, payload offsets, pointer derivations, and literal
register writes are directly visible in the disassembly. The exact semantic
meaning of each region and the two hardware registers remains unresolved. The
C version returns if allocation fails after issuing the diagnostic; the ROM
appears to expect the diagnostic routine not to return, since it proceeds to
dereference the result without a null check.

Evidence artifact: `asm/runtime/surface_context_init_5fef4.thumb.dis.txt`.
