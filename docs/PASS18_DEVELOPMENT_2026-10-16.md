# Pass 18 development report — 2026-10-16

## Runtime record manager source recovery

Re-read the Thumb code at `0x08050388-0x080504E6` against the C sources. The
initializer stores the alternate-heap descriptor at manager `+0x00` and its
payload at `+0x08`; it initializes records from a linked source list, rather
than copying two words from the source descriptor. The count used for allocation
is the full 32-bit source value, while the manager stores a signed 16-bit count
for the subsequent loops.

Recovered the failure paths directly: a zero computed allocation size calls
`0x08057C5C` with message `0x087270A4` and returns without writing the manager;
a failed allocation stores a null descriptor, calls the same service with
message `0x087270DC`, byte count, and source count, then returns without writing
the other fields. The ROM bytes at `0x08057C5C` are `push {r0-r3}; add sp,
#0x10; bx lr`, confirming that it ignores its inputs and returns. The shared C
prototype is now variadic to represent the observed one-, two-, and three-
argument call sites.

Recovered the matching update data flow at `0x08050420`: position and velocity
integration, acceleration addition, source-list position mirroring, signed
boundary-crossing conditions, and optional scaled velocity reversal. Higher-
level gameplay meaning remains provisional.

## Files and linkage

Updated `src/object_record.c`, `include/runtime_record.h`, the shared
`sub_08057C5C` declarations, and the return-only implementation. Corrected the
stale `0x1C`-byte claims in the pass-8 and object-runtime findings, updated the
function map and recovery backlog, and added `tools/verify_record_manager.py`
with a `make verify-record-manager ROM=...` target.

## Verification and limits

Against the supplied original ROM, the new verifier matched 176 Thumb
halfwords across the clear/init and update routines, both diagnostic pointers,
all three direct call targets, and the six-byte return-only sequence at
`0x08057C5C`. All 38 discovered Python tests passed, including the focused
source integration checks. Libclang parsed all 42 ARM7TDMI translation units
with zero errors using minimal freestanding standard headers; this was a syntax
parse, not object compilation.

`make partial-link` could not run because this host has no `make`, ARM compiler,
or linker. The project only has a relocatable partial-link target and no
recovered GBA linker script or final ROM layout, so no candidate ROM was
produced. Source parsing and ROM-byte verification do not establish a matching
ROM. Overall completion remains **approximately 54%**, an unchanged historical
estimate rather than measured coverage. Pass-specific verified counts above
are the measured progress for this pass.
