# Development pass 37 — 2026-10-17

## Encoded display byte stream at `0x0805B824`

Recovered `RuntimeDisplay_ProcessByteStream` with its full 97-halfword Thumb
body in `asm/pass37/runtime_display_byte_stream.thumb.txt`. It copies ordinary
bytes into the renderer's temporary NUL-terminated span and calls
`RuntimeDisplay_DrawGlyphSequence` at `0x0805B440` from three control paths.

The byte-level behavior is:

- A null stream pointer or initially NUL byte returns without drawing.
- `0xFB` consumes a following byte into record `+0x0D`; that byte is later
  added to Y on line feed.
- `0xFC` flushes the current span, keeps the renderer's returned X, consumes
  a following byte into record `+0x0C`, and starts a new span.
- `0x0A` flushes, restores the signed 16-bit starting X, advances Y by record
  `+0x0D`, and continues.
- A later NUL or `0xFF` flushes and returns. `0xFD` and `0xFE` are ordinary
  buffered bytes.

The values and effects are verified; language-specific names for the record
bytes are not asserted. The parser entry's argument setup truncates X and Y to
signed 16-bit values and the fifth argument to one byte before calling the
renderer.

## Verification and linkage status

The ROM verifier matches **97 Thumb halfwords**, all **3 direct calls** to the
renderer, **9 conditional branch destinations**, and **5 unconditional branch
destinations**. A whole-ROM aligned Thumb-BL scan found **0 direct calls to
`0x0805B824`**, an aligned Thumb branch scan found **0 direct branch
references**, and a whole-ROM scan found **0 stored Thumb pointers** to the
entry (`0x0805B825`). Its incoming dispatch remains unresolved. Each of the
three outgoing calls remains within Thumb code and targets the recovered
Thumb renderer at `0x0805B440`; this is ROM-level call-target evidence, not an
object-level ARM/Thumb relocation audit.

The complete ROM-enabled Python suite passed: **128 tests, 0 failures, 0
errors, and 0 skips**. Libclang parsed all **60 ARM7TDMI C translation units**
with **0 frontend errors**. For this new translation unit, all three call
expressions resolve to the project's `RuntimeDisplay_DrawGlyphSequence`
declaration, which has a source definition in the renderer unit.

No `make`, Clang compiler executable, or ARM GNU compiler/linker is available
on this host, so `make check`, `make partial-link`, the object-level unresolved
symbol audit, and candidate ROM generation could not be performed. The parser
is included automatically by the Makefile's `src/*.c` source wildcard. The
input ROM remains external to the archive.

The overall source-recovery value stays at the historical **approximately
54% rough estimate**. It has no measured coverage denominator and is not
recalculated from these pass counts. Matching-ROM build progress remains
**0%**. Archive integrity and digest are reported with the delivered archive.
