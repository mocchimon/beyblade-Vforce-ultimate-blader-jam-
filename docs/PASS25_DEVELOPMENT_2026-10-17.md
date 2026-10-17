# Development pass 25 — 2026-10-17

## Selection layout recovery

Recovered the Thumb layout routine at `0x08061260` as
`RuntimeObjectSelection_ApplyLayout` and the adjacent wrapper at `0x080614D4`
as `RuntimeObjectSelection_SetFlagsAndApplyLayout`. The layout source follows
the ROM's mode-specific initial X offset, per-entry coordinate projection,
anchor marker, node-segment wrap, optional scale read from the record at
context `+0x2C`, signed row step, and final Y adjustment controlled by flag
bits `0x10`/`0x20`.

The finalizer now calls the named layout function. The wrapper stores its
second argument's low halfword at context `+0x08` and calls the same routine.
Both translation units are included by the Makefile's C-source wildcard; the
layout source is not in the ARM-state exception list and therefore follows the
project's Thumb compilation path.

## Context-layout correction

Rechecking the initializer at `0x080611B4` against its saved ROM instructions
found an earlier field-labeling error. Context `+0x04` receives the scaled Y
coordinate, `+0x08` receives the caller's selection flags, `+0x0A` is cleared
as the cursor, and `+0x0C` receives the extent. The prior source had assigned
the Y coordinate to `+0x0C`, treated the flags argument as ignored, and placed
the extent at `+0x08`. The context structure, initializer, and regression
assertions now use the ROM-observed offsets.

## Verification

- **64 Python tests passed** with the locally supplied original ROM path.
- The new layout verifier matched **320 Thumb halfwords** and decoded the
  wrapper's direct call to `0x08061260`. The finalizer verifier independently
  matched **210 halfwords, seven direct calls, and three literals**.
- Related checks passed: chain operations (**228 halfwords, 10 calls**),
  chain release (**94 halfwords, five calls**), resource-node selection
  (**214 halfwords, seven calls**), object selection (**216 halfwords, 20
  calls**), and selection dispatch (**60 halfwords, 10 calls**).
- Libclang parsed **47 C source files and two existing C harnesses** for the
  ARM7TDMI target with **zero diagnostics**. This is a syntax/frontend check,
  not object generation or an ARM/Thumb interworking test.

The layout implementation and its source-level call binding are now
recovered, but an object-symbol unresolved-external audit was not possible.
The host has no Clang compiler executable, `make`, GCC/devkitARM, ARM linker,
or MSVC compiler; the available Python libclang frontend can only parse source.
Therefore no ARM objects, partial link, or candidate ROM were produced. The
original GBA section/linker layout also remains unrecovered. Matching-ROM
progress remains **0%**.

The overall completion value remains the historical **approximately 54%
estimate**. It has no defined denominator and is **not measured source
coverage**. Halfword, call, test, and syntax counts above are measured checks
for this pass only; they do not change that estimate.
