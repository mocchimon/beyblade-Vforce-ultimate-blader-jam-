# Directory consumer: 0x0804AF08 (2026-10-12)

The literal at ROM `0x0804AF50` is used by Thumb code beginning at `0x0804AF08`, **not** an unrelated aligned pointer in a data table. The function:

1. Preserves incoming `r0` as a 16-bit selection value.
2. Calls `0x0804AF60` (preparation; semantics not yet known).
3. Stores the selection halfword at `*(u32 *)0x03000FB0 + 0x0C26`.
4. Multiplies selection by 8 and reads the two 32-bit words of the corresponding directory entry (`0x08075640 + index * 8`).
5. Calls `0x080629B4(begin, end)` and saves its return at context offset `0x0C2C`.
6. Calls `0x08062AF8(handle, *(u16 *)(*(u32 *)0x03000F48 + 0x06E6))`.

This is concrete proof that the 32 directory entries are **pairs of 32-bit values** used as a begin/end-style pair by the callee, not simply a table of record pointers. The semantic meaning of each bound still depends on `0x080629B4`. In particular, the unusual even alias entry (`0xFFFF0000`, `0x080BE234`) must not be described as a conventional pointer range without examining the callee.

Source reconstruction: `src/resource_directory_dispatch.c`. Instruction evidence: `asm/resource/resource_directory_select_4af08.dis.txt`. This is compilation-checked source, **not** a byte-matched function. No bounds check appears in the observed ROM routine.

## External reference project

A separate, publicly available matching-decompilation effort exists at https://github.com/marijnvdwerf/gba-beyblade-vforce. Its README documents US/EU builds, matching checks, and an `INCLUDE_ASM` workflow. The repository has **not** been imported into this project, and its current ROM hash/compatibility has **not** been independently verified here. Comparing its function map and matching status is a high-priority follow-up; do not treat our engineering completion estimate as a measured matching percentage.

## Updated interpretation (2026-10-12)

The prior begin/end-style interpretation is superseded by `docs/RESOURCE_RUNTIME_SELECTION.md`: `0x08062974` uses the second word as a pointer to a signed 16-bit index, and the first as a pointer-table base.
