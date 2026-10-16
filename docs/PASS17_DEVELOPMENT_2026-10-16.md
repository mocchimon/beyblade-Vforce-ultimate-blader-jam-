# Pass 17 development report — 2026-10-16

## Active-list validator recovery

Recovered `ResourceNode_ValidateActiveList` at `0x080604F8` from the original
Thumb instructions. The routine returns on a null head, checks the head's
previous pointer, then walks the list and checks adjacent forward/back links.
Three mismatch branches pass ROM message pointers `0x0875591C`, `0x08755938`,
and `0x08755954` to `sub_08057C5C` at `0x08057C5C`. That separately recovered
callee returns without observable effects, so this helper continues traversal
and does not repair or terminate on a mismatch.

Added the saved instruction bytes in
`asm/runtime/resource_node_validate_604f8.thumb.dis.txt`, defined the helper in
`src/resource_node.c`, removed its external-only declaration, and updated the
function map and resource-node findings. The C lifecycle harness now uses the
real validator and records diagnostic-sink calls. It adds cases for a non-null
head predecessor and a broken backward link on a later node.

## Runtime diagnostic call linkage

Also removed the stale source-level `FatalError` import. ROM evidence shows
`RuntimeMemory_Init` and `RuntimeBlock_FindFree` call `0x08057B60` with only a
message pointer, while `RuntimeObjectTable_Init` calls `0x08057C5C` with a
message pointer plus the corresponding allocation size (`3*n + 40*count` or
`0x440`). Updated those C call sites and shared prototypes to use the recovered
entries and preserve the observed argument registers. These are return-only
calls, not proven termination paths.

## Verification and limits

All 37 Python tests passed, and all 42 C translation units parsed with ARM7TDMI
frontend settings with zero errors. The new ROM verifier matched all 32
halfwords at `0x080604F8`, the three diagnostic pointers, and all three calls to
`0x08057C5C`. The expanded C host harness requires Linux
`mmap(MAP_FIXED_NOREPLACE)`; WSL startup is denied in this environment, so its
new runtime cases are added but not claimed as run. The
`ResourceNode_ValidateActiveList` and stale `FatalError` source-level import
gaps are removed; no object-symbol audit was available to measure import
counts. `Runtime_Fatal` remains an open boundary.

The original-ROM call-site check also confirmed the three one-argument calls
target `0x08057B60` and the two object-table calls target `0x08057C5C`. Their
literal message words are `0x08755E48`, `0x08755E78`, `0x08755EB0`,
`0x08755DB4`, and `0x08755DE8`; the last two paths pass the allocation sizes
as their second argument. `make verify-resource-node-validator ROM=...` now
provides a reproducible check for the validator's instruction bytes, pointers,
and call targets.

Overall traditional decompilation remains **approximately 54%**, the same
rough historical estimate rather than measured source coverage. No candidate
ROM was built; matching-ROM progress is unchanged.
