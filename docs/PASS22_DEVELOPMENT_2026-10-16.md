# Pass 22 development report — 2026-10-16

## Selection dispatch and packed context fields

Recovered the wrapper at `0x08061684` as
`RuntimeObjectSelection_Dispatch`. It narrows the third argument to one byte,
calls the reset entry at `0x0806124C`, calls the finalizer at `0x080614E0`,
then returns only the finalizer's low byte. The reset entry calls
`0x08060D00` with `context + 0x14` and clears the halfword at `context + 0x0A`.
The builder at `0x08050AA0` now calls this named source function instead of
importing `sub_08061684` directly.

Also recovered five small context helpers:

- `0x08061154` ORs the low two bits of its second argument into bits 10–11 of
  the word at context `+0x10`.
- `0x08061170` returns those two bits.
- `0x0806117C` and `0x08061184` write 1 and 0, respectively, at byte `+0x19`.
- `0x0806118C` replaces the high nibble of the halfword at `+0x14` while
  preserving its low 12 bits.

The next large source gap is now explicit: `0x080614E0` is the complex finalizer
and `0x08060D00` releases the embedded subcontext. Their behavior is still
unresolved; the source does not fake either implementation. The adjacent direct
calls from the finalizer to the newly recovered field helpers are verified.

## Verification and build status

The Pass 22 ROM verifier checks **60 Thumb halfwords across seven ranges** and
decodes **10 direct BL targets**, including the builder-to-wrapper edge, the
wrapper's reset/finalizer calls, and the finalizer's field-helper calls. It
also checks independent callers of the field helpers. The new dispatcher source
is assigned Thumb state by the Makefile's default rule; the ARM-state source
list remains limited to the two rasterizer files. This confirms the intended
source/build-mode assignment, not generated interworking stubs or object
linkage.

All **52 Python tests passed** when the two ROM-dependent cases were given the
local original ROM. Default test discovery also completes cleanly and skips
those two cases when no ROM path is supplied. Libclang parsed all **45 C
translation units** for ARM7TDMI with no diagnostics using minimal freestanding
standard headers. A C host-behavior harness was added for the dispatcher and
packed fields, but could not be executed because this host has no C compiler.

The original ROM is used only as a local verification input and is not copied
into the project or archive. No ARM object, partial link, or candidate ROM was
produced: this Windows host has no `make`, C compiler, ARM compiler, or linker
on its command path, and the original GBA linker layout remains unrecovered.
The historical overall completion estimate remains **approximately 54%**;
it is unchanged, subjective, and not a measured coverage value. Pass-specific
byte and call counts are measured checks, not a total completion percentage.
