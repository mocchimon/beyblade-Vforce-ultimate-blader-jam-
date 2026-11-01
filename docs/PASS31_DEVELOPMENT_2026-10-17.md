# Development pass 31 — 2026-10-17

## Child runtime initializer at 0x08058C98

`ChildRuntime_InitVariantC` is now source-defined in
`src/child_runtime_init_variant_c.c`. It calls the recovered layout selector,
sets up the child and its indexed 0x18-byte nested record, derives the child
allocation length, updates the byte-sized background allocation counters,
dispatches the selected layout length through the installed operation slot,
and writes the final value to the selected BGxCNT register.

ROM checks matched **233 Thumb halfwords** across the initializer, the
observed call setup at `0x0804A76E`, and the shared `BX r3` entry. Four direct
call destinations and five literal words were checked. The operation pointer
slot at `0x0807D994` contains the even ARM address `0x03006FAC`, confirming the
Thumb-to-ARM interworking path. The IWRAM callback's behavior remains unknown.

## Child display-state record at 0x0805B268

`RuntimeDisplayState_InitializeRecord` now models the observed 16-byte record
writes: three words, a truncated byte, a byte copied from source `+0x05`, and
a halfword set to 1. The caller setup at `0x0804A780` is checked against
the five-argument function. ROM checks matched **22 Thumb halfwords** across
the initializer and its call setup.

The larger caller at `0x0804A748` remains unresolved as a source function. It
saves its incoming `r8` into `r7` and uses that value in a 0x400-word fill
loop; separately, it keeps an incoming `r2` value in `r8` for a later helper
call. Its overall entry ABI is not established, so this pass records only the
concrete arguments visible at the two verified child-call sites.

## Verification and remaining limits

- **98 Python tests passed**, including the locally supplied ROM checks, with
  zero skips.
- ROM verifiers for development passes 26–31 all passed. Pass 31 checks its
  two recovered routines, direct call targets, literals, and the ARM/Thumb
  thunk bytes.
- Libclang parsed all **54 C translation units** for ARM7TDMI with zero
  diagnostics. This is a frontend syntax check, not object generation.
- A matching or candidate ROM was not built. The host has no ARM compiler,
  linker, `make`, or project linker script; original code/data section layout
  remains unavailable.
- The background transfer operation at `0x03006FAC` and the renderer transfer
  path at `0x08059334` remain unresolved. No object-level unresolved-symbol
  audit was possible without ARM objects.

The historical source-recovery estimate remains **about 54%**. It is a rough,
unmeasured estimate, not a count produced by this pass. Matching-ROM progress
remains **0%**.
