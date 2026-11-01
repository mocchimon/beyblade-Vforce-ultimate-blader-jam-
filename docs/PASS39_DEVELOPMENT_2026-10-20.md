# Pass 39 — collision owned-segment initializer

Date: 2026-10-20

## Recovery

Recovered `0x0805B95C` from the user-supplied 8 MiB GBA ROM and added a
conservative C reconstruction as `CollisionData_InitializeOwnedSegments`.

The function:
- stores the source pointer and resolves the source-relative fields at
  `+0x10`, `+0x14`, and `+0x18` into the record's `+0x00..+0x0C` header;
- stores the caller-supplied low 16 bits of flags at record `+0x118`;
- computes two optional segment sizes from source words `+0x00` and `+0x08`,
  scaled by 16 and 32 respectively, and requests one alternate-heap allocation
  for their selected combined size;
- stores the allocation result at record `+0x10`; on a null result it calls the
  ROM diagnostic service with message `0x08755430` and the requested size;
- for selected segments, reads the runtime-installed callback from `0x0807D998`
  and invokes it through the shared Thumb trampoline at `0x08065C44`, then
  updates the corresponding record pointer;
- builds the same capped packed-spline pointer cache used by the already
  recovered `0x0805B8E8` routine and clears record `+0x114`.

The callback's installed target and exact operation semantics remain unresolved.
The source deliberately calls it an installed operation rather than claiming
that it is a standard `memcpy`. The exact runtime behavior of the diagnostic
service also remains unresolved.

## Verification

`tools/verify_collision_data_owned_segments.py` checks 123 Thumb halfwords,
six direct call targets, nine conditional branch targets, two unconditional
branch targets, four literal-load targets, and three literal words. The test
suite also checks listing coverage, source-level invariants, and verifier
corruption detection.

Run:
```
make verify-collision-owned-segments ROM=/path/to/original.gba
make test-collision-owned-segments
```

The ROM is an input to verification only and is not included in the project
archive. This pass is a source recovery pass, not a matching-ROM build.
