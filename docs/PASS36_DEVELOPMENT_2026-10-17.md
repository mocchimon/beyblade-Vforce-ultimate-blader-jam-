# Development pass 36 — 2026-10-17

## Indexed sequence renderer at `0x0805B440`

Recovered `RuntimeDisplay_DrawGlyphSequence` and its internal descriptor
lookup at `0x0805B814`. The five direct callers are at `0x0805B70C`,
`0x0805B7FE`, `0x0805B884`, `0x0805B896`, and `0x0805B8B4`; their argument
setups are now included in the ROM listing and verifier.

The renderer reads the existing 16-byte display-state record and its owner and
glyph descriptor. It selects map and character VRAM blocks from owner bytes
`+0x5C/+0x5D`, resolves the BG control register from `+0x5E`, and uses the
record's palette byte and next-tile cursor at `+0x0C/+0x0E`. It computes the
sequence metric through `RuntimeDisplay_ComputeSequenceMetric`, applies the
byte-sized alignment mode (mode 2 is a logical half-metric shift), reserves
the map span, assigns palette-tagged map entries, and dispatches a zero-valued
operation for any newly allocated character-tile span through the existing
generic callback wrapper. The callback implementation at `0x03006FAC` remains
unresolved, so its operation is not named as a clear or copy.

For bytes above `0x20`, the routine maps the byte through `0x0807D9A4`, gets a
descriptor-based source pointer, and blits the descriptor's 8x8 blocks through
`RuntimeDisplay_BlitIndexed4bppTile`. Bytes at or below `0x20` use a fixed
advance of five and do not enter the glyph-blit loop. The routine returns the
updated signed X value and stops after it exceeds 239. These instructions
support an indexed glyph-sequence interpretation; language-specific
control-byte semantics and runtime visual equivalence remain unverified.

The pass also corrects the prior description of mode-2 alignment: instruction
`0x0805B4DC` is `LSR`, so the source now subtracts a logical half, not an
arithmetic half. The call at `0x0805B5A6` gives a second recovered call-site
family for the even ARM target in slot `0x0807D994`, with a destination inside
the newly allocated tile span. The target installer and implementation are
still unresolved.

The ROM verifier matches **333 Thumb halfwords**, **11 direct calls**, **20
conditional and 3 unconditional branch destinations**, and **4 literal
words** across eight ranges. Pass 26–36 ROM-backed test coverage, including
the five caller sites, passed through the complete **124-test Python suite
with zero skips**. Libclang parsed **59 ARM7TDMI translation units** with
zero diagnostics. These results verify source parsing and recorded ROM bytes;
they do not prove machine-code equivalence or runtime output.

An AST cross-reference found that all nine distinct C call names in the new
translation unit resolve to source definitions among the project's 215
defined functions. The installed callback remains a runtime-loaded pointer,
so this source-level check does not resolve that target or replace an
object-level linkage audit.

No ARM object, relocatable link, or candidate ROM was produced. This host has
no `make`, Clang compiler executable, or ARM GNU toolchain on `PATH`; its WSL
service also returned `E_ACCESSDENIED`. The object-level linkage audit could
not run because no ARM objects exist. The historical source-recovery value
stays **approximately 54%**, a rough estimate without a coverage denominator,
and matching-ROM progress remains **0%**.
