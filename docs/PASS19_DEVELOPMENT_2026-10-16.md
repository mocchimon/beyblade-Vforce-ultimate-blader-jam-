# Pass 19 development report — 2026-10-16

## Object-record update recovery

Recovered two related Thumb functions as neutral C routines. At
`0x08050A74`, the ROM adds unsigned halfwords from a header at `+0x02` and
`+0x04`, loads the record base from `+0x0C`, and calls the per-record routine
at `0x08058F18` for each entry at a `0x88`-byte stride. The existing frame
dispatcher calls this batch routine with its context at `+0x590`.

At `0x08058F18`, the source now preserves the observed word updates at
`+0x14/+0x18` from `+0x1C/+0x20`, mirrors the results at `+0x54/+0x58`, calls
`0x080596D0`, and conditionally calls `0x08058F84` when bit 0 of the halfword
at `+0x64` is set. It then follows the ROM's scaled multiply, arithmetic shift,
subtractions, and conditional stores using the word at `+0x24`. Field names
remain neutral because higher-level meaning is not established.

The callees at `0x080596D0` and `0x08058F84` remain explicit externals. Their
direct Thumb BL targets are verified; this pass does not fabricate their
behavior or resolve them to source implementations.

## Verification

Added `tools/verify_runtime_object_records.py`, a saved halfword listing, a
focused regression test, and the `make verify-runtime-object-records ROM=...`
target. The new C unit follows the project's default Thumb compile rule.
Against the supplied original ROM the verifier matched **82 Thumb halfwords
across four ranges** and decoded **five direct-call targets**. These counts
describe this verified pass, not total source coverage. All **41 Python tests
passed**, and libclang parsed **43 ARM7TDMI C translation units with zero
errors** using minimal freestanding standard headers. The parse is syntax
validation, not object generation.

The historical **approximately 54% completion estimate is unchanged**. It is
still a rough, unmeasured estimate; there is no established denominator for
total game code. No candidate ROM was produced: this workspace has CMake but
no `make`, ARM compiler, ARM linker, or `nm`, and the project has no recovered
GBA linker layout. The `make partial-link` attempt could not start because
`make` is not installed.

The next listed code target is `0x08050AA0`; the two callees above remain open
linkage work.
