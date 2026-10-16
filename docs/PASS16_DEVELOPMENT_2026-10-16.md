# Pass 16 development report — 2026-10-16

## Frame-preparation recovery correction

Rechecked `0x08049268` against `asm/pass7/game_state_cluster.thumb.s`. The
function uses the context at `0x03000650`; it separately loads the object pointer
stored at `0x03000FB0` and writes `0xFFFF` to that object's halfword at `+0xC26`.
Renamed the source binding to `GameState_FramePrepare` and updated the startup
loop to call it. The body now reflects the disassembly's verified writes:

- words at context offsets `+0x00` and `+0x08` set to `-1`; `+0x04`, `+0x0C`,
  `+0x424`, `+0x470`, `+0x578`, `+0x57C`, `+0x580`, `+0x588`, `+0x58C`, and
  `+0x5A8` cleared;
- context `+0x10` set to `7`, then `RuntimeRecord_Clear` called on `+0x458`;
- halfword `+0x474` and bytes `+0x7C`, `+0x7F`, `+0x80`, `+0x81`, `+0x481`, `+0x584`,
  `+0x585`, and `+0x586` cleared.

This corrects concrete source-level layout and a prior offset error. The game
meaning and ownership of every field remain provisional, and the reconstruction
is not an object-level or matching-ROM proof.

## Verification

The assembly offsets and store widths were checked instruction-by-instruction
against the saved Thumb listing: 23 explicit stores and the call to
`RuntimeRecord_Clear`. A source integration regression pins the two RAM bases,
the separate object-field write, the runtime-record call, key field offsets,
and the renamed startup binding. All 42 C translation units parsed for
ARM7TDMI with zero frontend errors, and all 34 Python regressions passed,
including the ROM-backed alias metadata check.

The environment still lacks the project's `make` command and ARM object/linker
toolchain, so an object-symbol unresolved-external audit, partial link, and ROM
build could not be produced. Source-level declaration inventory is not a
substitute for that audit. The missing `ResourceTable_Generate`,
`ResourceTable_Transform`, and `ResourceTable_Combine` implementations remain
unresolved; no behavior was invented for them.

## Completion estimate

Overall traditional decompilation remains **approximately 54%**, the same
historical rough estimate. It is not a measured source-coverage percentage.
Matching-ROM build progress remains unverified; no ROM was built in this pass.
