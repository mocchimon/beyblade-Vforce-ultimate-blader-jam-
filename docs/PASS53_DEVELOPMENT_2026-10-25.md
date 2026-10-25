# Pass 53 — runtime-base slot write candidate

## Objective

Continue from Pass 52 by testing whether the ROM contains a nearby store through
a register loaded with the address `0x03000F48`, the runtime-base pointer slot
used by the input helpers.

## ROM-backed result

The new scanner `tools/audit_runtime_base_slot_writes.py` finds one encoding-level
candidate in the supplied ROM:

| Address | Halfword | Interpretation |
|---|---:|---|
| `0x080510A8` | `0x4B16` | Thumb `LDR r3, [PC, #0x58]`, resolving to literal `0x08051100` containing `0x03000F48` |
| `0x080510AA` | `0x6821` | Thumb `LDR r1, [r4, #0]` |
| `0x080510AC` | `0x6019` | Thumb `STR r1, [r3, #0]` |

This sequence is consistent with storing a value from the object referenced by
`r4` into the slot at `0x03000F48`. It is stronger evidence than the broad
Pass 52 literal-load inventory because it includes a nearby store using the
loaded slot address as its base register.

It is **not yet proven to be the slot initializer**. The scanner is encoding-based,
not a full disassembler or control-flow analysis. The surrounding routine has
conditional control flow and calls whose register/data-flow effects must be
verified. Do not infer the final runtime-base value or equate field `+0x6B4` to a
fixed address until the pointer's provenance is established.

## Reproduction

```sh
make audit-runtime-base-slot-writes ROM=/path/to/original.gba
make test-runtime-base-slot-writes
make test-all
make check
```

## Validation

- Four focused synthetic-ROM tests cover candidate detection, incorrect literal
  rejection, stop-on-dereference behavior, and malformed odd-length images.
- The full regression suite and ARM7TDMI compile-only check are run for this pass.
- The original ROM is not included in the project archive.
- No matching-ROM build and no Easter egg discovery are claimed.

## Next steps

1. Disassemble and trace the routine around `0x08051090` and the called targets.
2. Establish how `r4` is initialized along each branch before treating the store as
   a valid runtime-base assignment.
3. Find reads of `0x03000F48` after this candidate store and compare the loaded
   base with the input field access at `+0x6B4`.
4. Keep secret-input/Easter-egg analysis downstream of confirmed input-state flow.
