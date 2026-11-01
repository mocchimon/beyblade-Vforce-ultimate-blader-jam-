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

## 0x08058C98 — internally allocated child display initializer

`ChildRuntime_InitVariantC` now has a source reconstruction in
`src/child_runtime_init_variant_c.c`. It clears the resource pointers, calls
the existing layout selector, initializes the child and its indexed 0x18-byte
nested record, derives a byte length from the caller's 16-bit dimension and
control bit, updates the IWRAM allocation counters at `0x03000DE0` and
`0x03000E3C`, dispatches the selected layout length to the installed operation,
and writes the composed value to the selected BGxCNT register.

The ROM body, its one observed call setup at `0x0804A76E`, its three direct
calls, four embedded pointer literals, and the `BX r3` interworking entry are
checked by `make verify-child-runtime-init-variant-c ROM=...`. The callback
slot still contains the even ARM address `0x03006FAC`. Its operation remains
unidentified; the source keeps the dispatch generic. The containing caller at
`0x0804A748` is not source-defined because its wider incoming `r8` contract
remains unresolved.

## 0x0805B268 — child display-state record initialization

`RuntimeDisplayState_InitializeRecord` writes the five incoming values into
the observed record layout: owner at `+0x00`, a word at `+0x04`, the source
pointer at `+0x08`, a truncated byte at `+0x0C`, a byte copied from source
`+0x05` to record `+0x0D`, and halfword value 1 at `+0x0E`. The call setup at
`0x0804A780` matches this five-argument layout. The wider caller remains
unrecovered; this callee's local field behavior is established independently.

The neighboring entries at `0x0805B284`, `0x0805B28C`, and `0x0805B290` are
small field setters. `0x0805B294` returns `base + ((index & 0x03FF) << 5)`;
four calls in the containing routine at `0x0805B2A4` reach this same entry
using four halfword indices. The mask literal and all four call destinations
are checked by `make verify-runtime-display-state-helpers ROM=...`. The
containing routine's full behavior and the wider meaning of these record
fields remain open.

## 0x0805B2A4 — indexed tile compositor

`RuntimeDisplay_BlitIndexed4bppTile` reconstructs the full ROM routine. It
reads eight source words, treats each word as a row of eight packed nibbles,
and uses map entries `0`, `1`, `32`, and `33` to select four 32-byte tile
blocks. It shifts each row by the low three bits of `x` and `y`, splits
overflow into neighboring tiles, and ORs the fragments into existing words.
The ROM clips `x` to the range `-7..239` and accepts `y` only in `0..152`.
The direct caller at `0x0805B638` computes a map-cell pointer from the tile
coordinates and passes `x` in `r3` and `y` on the stack, supporting the
provisional 8x8 4bpp interpretation.

The verifier compares the full routine and caller setup against 150 Thumb
halfwords, checks all five call destinations, and validates ten conditional
branch targets. This establishes instruction-level structure; output has not
been compared with a runtime rendering fixture.

## 0x080599CC / 0x08059A0C / 0x08059A4C

Pass 27 corrected the earlier source interpretation of these selectors. The
ROM returns absolute GBA register addresses, not the 16-bit layout values
previously recorded here:

- `0x080599CC`: BG0HOFS/BG1HOFS/BG2HOFS/BG3HOFS at `0x04000010/14/18/1C`
- `0x08059A0C`: BG0VOFS/BG1VOFS/BG2VOFS/BG3VOFS at `0x04000012/16/1A/1E`
- `0x08059A4C`: BG0CNT/BG1CNT/BG2CNT/BG3CNT at `0x04000008/0A/0C/0E`

The selector input is truncated to one byte. Inputs 0 through 3 select the
listed addresses; other byte values are returned unchanged, matching the
ROM's default branch. The old `ChildResource_LayoutValueA/B/C` source stubs
were replaced with register-address selectors.

## 0x080596D0 — display-region update

This routine adds its two word inputs to record `+0x0C/+0x10` and `+0x40/+0x44`,
derives 30-by-20 bounds in 11-bit fixed point, and compares them with the six
words reached through the pointer at record `+0x08`. It adjusts those bounds,
optionally requests horizontal and vertical wrapped strips through
`0x08059334`, applies the wrap flags at `+0x7C`, then writes either BGxHOFS/
BGxVOFS or the BG2/BG3 affine reference points. The source field names remain
neutral where the records do not establish higher-level meaning.

The `0x08059334` rendering transfer remains an indirect-dispatch placeholder
in C. This pass recovers the caller's clipping state and arguments but does
not establish pixel-equivalent transfer output.

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

## 0x08059958 / 0x080599B8 — display initialization and flags

`0x08059958` clears bytes at `0x03000DE0` and `0x03000E40`, stores 32 at
`0x03000E3C`, clears BG0–BG3 horizontal and vertical scroll offsets, then calls
the affine updater for BG2 and BG3 with angle zero and `0x100` X/Y inputs.
Direct calls appear at `0x0804277E`, `0x0805073E`, and `0x0805E996`; their
surrounding callers remain unrecovered in C.

`0x080599B8` reads the record halfword at `+0x64`, ANDs it with the supplied
mask, and returns normalized 0 or 1. A full-ROM Thumb-BL scan found no direct
call to this helper, so its caller or indirect use is not yet identified. The
three IWRAM bytes retain address-based labels pending broader data-flow
evidence.

## 0x08059C3C–0x08059D28 — background control fields

`0x08059C3C` takes four values, truncates each to its low two bits, and writes
them to the low two bits of BG0CNT through BG3CNT while preserving the other
bits in each low byte. `0x08059CEC` performs the same update for one selected
background. `0x08059D14` reads those two bits, and `0x08059CD8` selects the
background from a record byte at `+0x5E` before reading them.

`0x08059D28` sets or clears the selected background enable bit in DISPCNT
(bits 8 through 11). Indices above three return without a register write; the
enable argument is treated as true when its low byte is nonzero. Its two
incoming direct calls are at `0x0804A7D4` and `0x0804A7F4`. Other confirmed
incoming calls are `0x0805EAAE` to the four-register writer, `0x08057F5A` to
the record reader, and `0x0804A7CC` to the single-register writer. These
callers remain unrecovered in C. No direct caller was found for the standalone
two-bit reader at `0x08059D14`.
