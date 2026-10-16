# Development pass 11 — arithmetic, resource wiring, and build status

## Source and linkage changes

- Reconstructed the signed and unsigned division routines at `0x080660A8` and
  `0x080661E4`; retained the previously recovered remainder routine at
  `0x0806625C`.
- Added the `__aeabi_uidiv` compiler support entry and removed the direct
  unsigned divide expression from `RuntimeObjectTable_Init`.
- Replaced the unresolved `System_VBlankWait` declaration-only state with the
  direct BIOS SWI `0x05` wrapper at `0x080578FC`.
- Reconstructed the return-only ROM entries `0x08057B60` and `0x08057C5C` from
  their Thumb instructions, preserving neutral address names.
- Consolidated the duplicate directory-selection entry with the full
  `RuntimeResource_Select` implementation. That routine calls the recovered
  cleanup, indexed allocator, and limit update at `0x0804AF60`, `0x080629B4`,
  and `0x08062AF8`.
- Updated host test coverage for quotient and remainder behavior.

## Evidence and counts

The archive's previous ARM object audit measured 40 object files, 94 defined
symbols, 47 resolved cross-unit references, 32 unresolved external names, and
no duplicate definitions. Those are the prior build's object-symbol counts.
This environment has no ARM compiler or linker, so those object counts have
not been regenerated after the source edits. The eight previously unresolved
names addressed by this pass are `System_VBlankWait`, `sub_080660A8`,
`__aeabi_uidiv`, the three `ResourceDirectory_*` imports, and
`sub_08057B60` / `sub_08057C5C`. A fresh compile and symbol audit are required
before claiming the unresolved count fell from 32 to 24 or reporting a new
cross-unit reference count.

## ROM build

No candidate ROM was produced. The project snapshot has no recovered ROM
linker script, and this execution environment has no ARM7TDMI C compiler or
ARM linker. The source tree is a partial reconstruction rather than the full
game source/assets required for an independent image build. The original ROM
was used only as an analysis input and is not included in the archive.

The historical `~54%` source-recovery figure remains an estimate. This pass
does not turn it into a measured coverage percentage. The reproducible measured
items remain the prior object-symbol counts above and the directory/resource
data inventories recorded in their respective findings documents.

## Verification performed here

- The current source inventory is 42 C translation units. The Makefile assigns
  two to ARM state and the remaining 40 to Thumb state.
- LLVM 19.1.5's C frontend parsed all 42 units with ARM7TDMI/ARMv4T settings
  and the matching per-unit state flags. This was a syntax/frontend check with
  temporary standard-type headers; it did not emit ARM objects.
- Four ROM-independent Python regression modules passed 12 tests, and the new
  source-wiring tests passed two more. The division algorithm was separately
  checked in a Python model over 2048 x 257 small input pairs, 100,000
  deterministic 32-bit pairs, and signed edge cases. The C math test itself
  was not executed.
- The configured `make check`, `make partial-link`, and ROM link were not
  available because this environment has no `make`, ARM C compiler, or ARM
  linker. The project also lacks the original ROM section layout, so no
  candidate `.gba` was produced.
