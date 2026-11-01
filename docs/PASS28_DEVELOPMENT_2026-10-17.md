# Development pass 28 — 2026-10-17

## Display-state initialization and flag helper

Recovered `0x08059958` as `RuntimeObject_InitializeDisplayState`. It zeros
observed state bytes at `0x03000DE0` and `0x03000E40`, sets the byte at
`0x03000E3C` to 32, clears BG0–BG3 horizontal and vertical scroll registers,
then initializes BG2/BG3 affine state through the previously recovered
`RuntimeObject_UpdateAffineTransform` routine with zero angle and `0x100`
inputs. A scan located direct calls at `0x0804277E`, `0x0805073E`, and
`0x0805E996`; these caller bodies are not yet source-recovered.

Also recovered `0x080599B8` as `RuntimeObject_TestFlagsAt64`, which returns
whether the halfword at record `+0x64` intersects its mask. The instruction
`ADDS r0, #0x64` encodes decimal immediate 100, establishing the byte offset
as hexadecimal `0x64`. A full-ROM Thumb-BL scan found no direct callers.

The new ROM verifier matched **63 Thumb halfwords across five ranges**, decoded
**seven direct calls** (three incoming to the initializer and four outgoing),
and checked **three IWRAM pointer literals**. The Pass 26 and 27 ROM checks
also passed at 352 and 421 halfwords respectively. All **78 Python tests**
passed, and libclang parsed all **50 C translation units** for ARM7TDMI with
zero diagnostics. These are pass measurements, not total project coverage.
The estimated overall completion remains the historical **~54%**, unchanged
and not measured coverage; matching-ROM progress remains **0%**.

The `0x08059334` render transfer still uses an indirect-dispatch placeholder,
so pixel equivalence is not established. No ARM object build, partial link, or
candidate ROM was produced: the host has no C/ARM compiler, linker, or `make`,
and the original GBA linker layout remains unrecovered. The object-level
unresolved-import and ISA/interworking audits therefore remain unavailable.
