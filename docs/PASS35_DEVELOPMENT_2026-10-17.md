# Development pass 35 — 2026-10-17

## Sequence metric helper at `0x0805B400`

Recovered `RuntimeDisplay_ComputeSequenceMetric` from the complete Thumb
routine and its direct caller setup at `0x0805B4C0`. The helper reads bytes
until a zero terminator. Byte `0x20` contributes 5. Every other byte first
indexes the ROM table at `0x0807D9A4`; when the caller's table offset is
nonzero, that table result plus the offset indexes the table again, and the
second value is subtracted from the caller's base metric. The per-byte values
are accumulated with 32-bit unsigned arithmetic.

After the helper returns, the caller masks its alignment field to two bits.
For mode 1 it subtracts the full metric from the origin; for mode 2 it
subtracts a logical half (`metric >> 1`). Pass 36 recovered the containing
renderer and its descriptor/table path, supporting an indexed glyph-sequence
interpretation. The metric units and product-specific table semantics remain
unresolved.

The ROM verifier matches **51 Thumb halfwords**, **1 direct call**, **6 branch
destinations**, and **1 table-pointer literal**. It checks the incoming
arguments and following alignment adjustment at the observed caller.

## IWRAM callback trace update

The callback at `0x03006FAC` remains unresolved. The known `0xD24` ARM image
would place that address at offset `0xDF4` if based at `0x030061B8`, which is
`0xD0` bytes past the image. The loader's destination is allocator-provided
EWRAM, so this rules out that specific hypothetical mapping while leaving the
actual installer/source unknown.

## Verification and build status

- The ROM-enabled Python suite passed **120 tests with zero skips**.
- Passes 26–35 ROM verifiers and the pass 32 IWRAM pointer audit passed.
- Libclang parsed **58 C translation units** for ARM7TDMI with zero
  diagnostics. This is frontend parsing only.
- The partial-link attempt remains unavailable because this host has no
  `make`; no ARM object or candidate ROM was produced.
- Overall source recovery stays at the historical **~54% rough estimate**,
  not measured coverage. Matching-ROM progress remains **0%**.
