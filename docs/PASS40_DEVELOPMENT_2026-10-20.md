# Pass 40 — shared runtime-copy callback ABI and matching-build readiness

Date: 2026-10-20

## Recovery result

The word at ROM address `0x0807D998` is confirmed as the even ARM-state IWRAM
address `0x03007034`. This is a code target, not a RAM variable that contains a
second pointer. The word is adjacent to the other mixed runtime-address entries
in the configuration region around `0x0807D920`.

Two independently recovered callers use the same slot and the same three-
argument register contract:

- `RuntimeBuffer_CopyRow` (`0x08063210`) computes a source row, a destination
  offset, and a byte count (`row_stride * 2`), then calls the slot through the
  Thumb `BX r3` trampoline at `0x08065C44`.
- `CollisionData_InitializeOwnedSegments` (`0x0805B95C`) computes a source
  segment, destination cursor, and segment byte count, then calls the same
  slot through the same trampoline for either selected segment.

At both call boundaries the arguments are prepared as `r0 = source`,
`r1 = destination`, `r2 = byte_count`; `r3` holds the loaded callback address.
This is strong evidence for a generic copy-like operation. The implementation
at `0x03007034` remains unavailable in the ROM file itself because its code is
in IWRAM at runtime; the path that installs those bytes has not been proven.
Consequently, this pass does not claim equivalence with `memcpy`, DMA, or a
particular copy algorithm.

## Verification added

`tools/verify_runtime_copy_callback.py` checks the exact callback slot value,
38 instruction halfwords across both callers, all three BL targets, and the
shared trampoline opcode. Regression tests confirm the verifier rejects a
corrupted instruction and a changed callback target. All 28 existing ROM-backed
`verify-*` Make targets also pass against the supplied original image.

Run:

```sh
make verify-runtime-copy-callback ROM=/path/to/original.gba
make test-runtime-copy-callback
```

## Matching-ROM build status

The current 61 translation units compile for ARM7TDMI, and the relocatable
integration link succeeds. The resulting object is an intermediate, not a
candidate ROM: its `.text` section is `0x84E6` bytes, it contains relocations,
and its symbols are not placed at their original ROM addresses. No original
linker script/section map or exact compiler/toolchain configuration has been
recovered, and multiple IWRAM routines and other code/data/assets remain
unresolved. Therefore the project still has no honest byte-for-byte matching
ROM candidate.

The comparison harness already exists as `tools/compare_rom.py` and
`make compare-rom ROM=... CANDIDATE=...`; it must only be run against a genuine
candidate produced from the reconstructed build. The original ROM is used as
verification input and is not copied into the source archive.

## Next targets

1. Find the installer/source bytes for the ARM routine at `0x03007034` and
   neighboring IWRAM entries, starting with descriptor-driven transfer and
   code-overlay paths.
2. Recover the original fixed address map, linker section ordering, and exact
   build flags/toolchain before converting the relocatable object into a ROM.
3. Use byte comparison by address to separate source/compiler mismatches from
   unrecovered data and layout gaps; do not claim a match based on a bootable
   ROM or on the recovered functions alone.
