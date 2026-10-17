# Development pass 27 — 2026-10-17

## Display-region clipping and scroll update

Recovered `0x080596D0` as `RuntimeObject_UpdateDisplayRegion` and replaced the
remaining address-only callee in `RuntimeObject_UpdateRecord`. The original
caller leaves its computed words from `+0x14/+0x18` in `r1/r2`; the C source
now passes those values explicitly. Also recovered the wrapper at `0x08059928`,
which derives the two adjustments from its frame and record inputs.

The update routine adjusts record words at `+0x0C/+0x10` and `+0x40/+0x44`,
computes its 30-by-20 clip rectangle in 11-bit fixed point, compares against
the six-word bounds record at `+0x08`, requests wrapped strips through
`Render_PrepareTransfer`, adjusts the bounds and wrap offsets, and finishes by
updating BG offsets or affine reference points.

The calls at `0x080599CC`, `0x08059A0C`, and `0x08059A4C` were also corrected.
They return the absolute BGxHOFS, BGxVOFS, and BGxCNT register addresses. The
previous source had misclassified these as layout-value selectors; their old
names and return values are removed. Exact I/O literals are now part of the
ROM verifier.

The rendering transfer helper at `0x08059334` remains an indirect-dispatch
placeholder in the C source. The clipping routine and its call arguments are
recovered, but pixel-equivalent transfer output remains unverified.

## Verification and limits

- The original-ROM verifier matched **421 Thumb halfwords across six ranges**,
  decoded **seven direct calls**, and checked **12 GBA register literals**.
- All **74 Python tests passed** with the local ROM path supplied.
- Libclang parsed all **49 C translation units** for ARM7TDMI with zero
  diagnostics. This checks frontend syntax, not generated ARM objects.
- The `RuntimeObject_UpdateRecord` source now has no address-only direct
  callee declarations. This is a source-file count, not a project-wide object
  unresolved-symbol audit.
- No ARM object, partial link, or candidate ROM was produced. This host has no
  C compiler, ARM toolchain, linker, or `make`; the original GBA linker layout
  also remains unknown.
- Overall completion remains the historical **approximately 54% estimate**.
  It has no defined denominator and is **not measured source coverage**.
  Matching-ROM progress remains **0%**.
