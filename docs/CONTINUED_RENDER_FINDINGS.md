# Continued render/resource findings

## 0x080592A8 — layout selector

This helper is now reconstructed from its complete switch. It derives a small
mode from the high bits of its first argument and a parity bit from the second
argument. It writes the selected bit counts into the child at `+0x5F` and
`+0x60`, then returns a size class.

For the normal (non-parity) path the returned values are:

| mode | +0x5F | +0x60 | size |
|---:|---:|---:|---:|
| 0 | 5 | unchanged | 0x0800 |
| 1 | 6 | 5 | 0x1000 |
| 2 | 5 | 6 | 0x1000 |
| 3 | 6 | 6 | 0x2000 |

The parity path derives both bit counts from the mode and returns `1 <<
(mode*2 + 8)`. The graphics-specific interpretation is deliberately still
unnamed.

## 0x080599CC / 0x08059A0C / 0x08059A4C

These are compact four-way selectors. Their exact return values are now
recovered:

- `0x080599CC`: `0x1000, 0x1400, 0x1800, 0x1C00`
- `0x08059A0C`: `0x1200, 0x1600, 0x1A00, 0x1E00`
- `0x08059A4C`: `0x0800, 0x0A00, 0x0C00, 0x0E00`

The values appear alongside the child/resource size calculations but their
final hardware-level meaning is not yet assigned.

## Resource record placement correction

The earlier pass described `+0x04` as a complete record span. That is too strong.
It is the **inline data length** after the 16-byte header. Pointer-table placement
is `align4(0x10 + data_size)`. This distinction matters for odd-sized records such
as `0x73D5`, where the next record is `0x73E8` bytes away.

## Resource table at 0x08075640

The table contains 8-byte records whose first two words are pointers into the
ROM's large data region. The first seven records point at contiguous pointer
lists beginning around:

- `0x08074DDC`
- `0x08074E7C`
- `0x08074F3C`
- `0x08074FD4`
- `0x08075044`
- `0x08075178`
- `0x080751FC`

The lists themselves contain many pointers into `0x0810...` through `0x0821...`,
strongly indicating that this is a structured asset/resource index rather than
ordinary executable data. It is now recorded as data rather than being treated
as an opaque pair of pointers.

## Child-resource call chain

The call chain around the recovered resource initializer is now explicit:

```text
0x080507E4  ->  0x0805898C  ->  0x08058ACC
```

`0x0805898C` normalizes the child/resource parameters, derives the nested
0x18-byte runtime record dimensions from the selected layout, and then calls
`0x08058ACC` with the resource pointer supplied by its caller. This is useful
because the resource pointer is therefore not synthesized by the renderer;
it originates in the higher-level object/resource setup path.

The renderer-side routine at `0x08059334` uses child `+0x70` as the source
base and derives a destination base from child `+0x5C` and the GBA VRAM base
`0x06000000`. Its transfer path includes the shared-register tail-dispatch
mechanism at `0x08065C5C`, so that call site should not be mistaken for a
normal C function with an ordinary fixed signature.
