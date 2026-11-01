# Development pass 30 — 2026-10-17

## Record-based background dispatch and interworking evidence

Recovered two adjacent wrappers:

- `0x0804A7EC RuntimeDisplay_DisableRecordBackground` reads record byte
  `+0x5E` and clears the selected background's DISPCNT enable bit through
  `RuntimeDisplay_SetBackgroundEnabled`.
- `0x0804A7FC RuntimeDisplay_InvokeRecordBackgroundOperation` reads the word
  at record `+0x88`, follows that pointer, reads its byte `+0x5D`, forms
  `0x06000000 + (index << 14)`, loads the operation pointer from `0x0807D994`,
  and dispatches `(0, destination, 0x8000)`.

The second wrapper calls `0x08065C44`, whose Thumb instruction is `BX r3`.
The ROM pointer slot stores `0x03006FAC`, an even IWRAM address. On ARM7TDMI,
that pointer selects ARM state when the `BX` executes. The evidence therefore
supports a Thumb-to-ARM dispatch path. It does not reveal what the installed
IWRAM operation does, and the source keeps that backend generic rather than
calling it a clear or copy routine.

The surrounding dispatch family at `0x08065C44–0x08065C70` contains twelve
four-byte entries, `BX r3` through `BX lr`, each followed by `MOV r8,r8`. The
ROM verifier matched **52 Thumb halfwords across three ranges**, decoded **two
direct calls**, checked **two pointer literals**, and confirmed all twelve
register entries. The new functions are included in the default Thumb source
set.

The larger caller at `0x0804A748` remains open. It reads and reuses the
incoming `r8` value in addition to the standard argument registers, and also
calls `0x08058C98` and `0x0805B268`. The available evidence does not establish
the custom entry contract, so this pass does not assign it a normal C ABI.
Three caller bodies for the Pass 29 display helpers remain unrecovered; no
direct ROM caller was found for the standalone BG-control reader at
`0x08059D14`.

All **89 Python tests** passed. Libclang parsed all **52 C translation units**
for ARM7TDMI with zero diagnostics. The historical source-recovery estimate
remains **~54%**, rough and unmeasured;
matching-ROM progress remains **0%**. This host has no ARM compiler/linker or
`make`, so no ARM objects, partial link, or candidate ROM were produced. The
remaining cross-state backend and original section layout still prevent a
verified ROM build.
