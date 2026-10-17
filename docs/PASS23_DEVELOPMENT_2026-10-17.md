# Pass 23 development report — 2026-10-17

## Resource-node chain release

Recovered ROM routine `0x08060D00` as `ResourceNode_ReleaseChain` and wired
the selection-context reset at `0x0806124C` to the source definition. The
routine returns immediately for a zero count. For a populated context, it
increments the tracked node count, walks exactly that many primary nodes,
recycles each auxiliary node when present, releases each nonnegative range
token with its class-derived mask, marks every token invalid, detaches the
segment from the active list, prepends the segment to the primary free chain,
clears context fields `+0`, `+4`, and `+8`, and validates the repaired active
list. It leaves `+0x2C` untouched.

Corrections recorded in Pass 24: the earlier reconstruction incorrectly
described the count as retained and `+0x2C` as cleared. ROM stores zero to
`+0x08` with the head and tail but does not write `+0x2C`; the C source and
harness were updated accordingly.

The implementation shares the already recovered
`ResourceNode_UnlinkAuxiliary`, `RuntimeRange_Release`, and
`ResourceNode_ValidateActiveList` functions. The C behavior harness now covers
an empty context and a two-node middle segment with both range and auxiliary
ownership. It is source-checked only; the harness could not run because no C
compiler is installed on this host.

## Verification and build status

`tools/verify_resource_node_release_chain.py` matches **94 Thumb halfwords**
from `0x08060D00–0x08060DBB`, including the embedded literal data, and decodes
**five direct calls**: the two callers, auxiliary unlink, range release, and
active-list validation. The related object-selection and resource-node ROM
verifiers passed as well. All **55 Python unit tests passed** with the local
ROM supplied, and five additional ROM-backed checks passed for alias metadata,
the 111-record manifest, resource-directory audit, descriptor storage, and
directory-runtime tracing.

Libclang parsed all **45 C source translation units** and both modified C
behavior harnesses with zero diagnostics. This is syntax validation, not code
generation. The `make partial-link` attempt could not start because `make` is
not installed; no C compiler, ARM compiler, or linker is available either.
No ARM objects, integration link, or candidate ROM were produced. The original
GBA linker layout also remains unrecovered.

The overall completion estimate remains **approximately 54%**, unchanged and
not measured coverage. The count of matched bytes and calls above describes
this pass only. Matching-ROM progress remains **0%**.
