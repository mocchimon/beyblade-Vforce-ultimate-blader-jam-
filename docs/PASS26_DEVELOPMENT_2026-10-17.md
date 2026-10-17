# Development pass 26 — 2026-10-17

## Runtime-object affine transform recovery

Recovered `0x08058F84` as `RuntimeObject_ApplyRecordTransform` and replaced the
address-only call from `RuntimeObject_UpdateRecord`. The record view now names
the observed transform fields at `+0x28` through `+0x50` and the selector byte
at `+0x5E`, while keeping their gameplay meaning provisional.

The routine advances the fixed-point words at `+0x28`, `+0x30`, and `+0x34`,
passes their ROM-observed byte/halfword slices into the affine-table updater,
projects the signed halfwords at `+0x48/+0x4A` through the four matrix values,
writes BG2/BG3 reference coordinates, and applies the scale at `+0x24` to
three velocity-like words. The low-byte mode selects one of three 0x18-byte
entries at `0x03000D00`; modes 2 and 3 also write affine parameters and
reference points to GBA display registers.

The helper path is source-defined as well: `0x08059B24` updates the selected
entry using ROM tables at `0x0874CC60` and `0x0872CC60`; `0x08059A8C` writes
BG2X/BG2Y or BG3X/BG3Y; `0x08059ADC` writes PA/PB/PC/PD for BG2 or BG3; and
`0x08059FC4` performs the signed fixed-point multiply. The negative-value
correction in the last helper corresponds to division by 256 rounded toward
zero, with the resulting value wrapped to a signed halfword.

The source-level `0x08058F18` updater now has one explicit external,
`0x080596D0`, down from two before this pass. This is a measured change to
that source file's declarations, not a project-wide unresolved-symbol count.
No global object-symbol audit was possible because this host cannot produce
ARM objects.

## Verification and limits

- The original-ROM verifier matched **352 Thumb halfwords across five ranges**,
  decoded **seven direct calls**, and checked **12 literal words**. The existing
  record-updater verifier also passed at **82 halfwords and five direct calls**.
- All **69 Python tests passed** with the local ROM path supplied.
- Libclang parsed all **48 C translation units** for ARM7TDMI with zero
  diagnostics. This is a frontend syntax check, not ARM object generation.
- Source-level function and call-edge recovery advanced, but no ARM object,
  partial link, or candidate ROM was produced. The host still lacks a C/ARM
  compiler, linker, and `make`; the original GBA linker layout also remains
  unknown.
- Overall completion remains the historical **approximately 54% estimate**.
  It has no defined denominator and is **not measured source coverage**.
  Matching-ROM progress remains **0%**.
