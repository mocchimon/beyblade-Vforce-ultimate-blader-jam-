# Development pass 38 — 2026-10-17

## Collision spline pointer cache

Recovered `CollisionData_BuildSplineIndex` at `0x0805B8E8` and
`CollisionData_GetSplineByIndex` at `0x0805DBA4` in
`src/collision_data_spline.c`. The builder stores the source pointer, resolves
the three 32-bit source-relative offsets at `+0x10`, `+0x14`, and `+0x18`,
caps a signed halfword count at 64 after calling the ROM-confirmed return-only
diagnostic, and caches pointers at record `+0x14`. The lookup routine uses the
full signed count at source `+0x04` and advances through packed entries by the
32-bit stride at entry `+0x04`. The builder then clears words at record
`+0x114` and `+0x10` and a halfword at `+0x230`.

Whole-ROM aligned Thumb-BL scanning found nine direct callers to each routine.
Constructor callers are `0x0804A3DA`, `0x08053662`, `0x08054168`,
`0x080547D4`, `0x08056C50`, `0x08056CC8`, `0x08056DB8`, `0x08057658`, and
`0x0805EADA`. Lookup callers are `0x0805B924`, `0x0805BA2A`, `0x0805D6BE`,
`0x0805DBEA`, `0x0805DCDC`, `0x0805DCFC`, `0x0805DD4E`, `0x0805E006`, and
`0x0805E09C`. The raw listing preserves both function bodies, the diagnostic
literal, and call-site snippets. `make verify-collision-data-spline
ROM=...` checks the ROM bytes, direct call targets, branch destinations, and
caller sets.

The allocator/copy routine at `0x0805B95C` remains unresolved. It allocates
the collision-data block and routes a row copy through the installed callback
slot at `0x0807D998`; the callback's installation and implementation remain
open.

## Validation and build status

- ROM verifier: **145 Thumb halfwords**, **19 direct call targets**, six
  conditional and one unconditional branch destination, and one literal word
  across 19 ranges; nine constructor callers and nine lookup callers matched.
- Focused Pass 38 tests: **3 passed**.
- Full discovered Python suite with the original ROM supplied:
  **131 passed, 0 failures, 0 errors, 0 skips**.
- Libclang parsed all **61 C translation units** for ARM7TDMI with zero
  frontend errors. This is syntax/front-end validation only.
- No `make`, Clang compiler executable, or ARM GNU compiler/linker is
  available on this host. ARM object generation, partial linking, object-level
  unresolved-symbol auditing, and candidate ROM generation could not run.
  ROM byte verification does not constitute a rebuilt ROM.

The source-recovery estimate stays at the historical **approximately 54%**.
That figure has no defined denominator and is not measured coverage. Matching
ROM progress remains **0%**.
