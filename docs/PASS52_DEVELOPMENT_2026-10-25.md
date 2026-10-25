# Pass 52 — runtime-base pointer reference inventory

## Objective

Continue from Pass 51 without claiming an Easter egg or assuming the platformer's
input helper is a secret-input detector. The immediate unresolved question is the
value and initialization path of the runtime-base pointer stored at `0x03000F48`,
which the helper at `0x080517A4` dereferences before reading field `+0x6B4`.

## ROM-backed result

`tools/audit_runtime_base_pointer.py` scans halfword-aligned ROM positions for
Thumb-1 PC-relative `LDR literal` encodings whose resolved literal word equals
`0x03000F48`. Against the supplied 8 MiB ROM, it reports **90 encoding-level
candidates**. Each result includes the candidate address, halfword, literal
address, destination register, and surrounding raw halfwords. The machine-readable
report is `docs/runtime_base_pointer_xrefs_pass52.json`.

This count is deliberately called *candidate references*, not 90 confirmed code
references or callers. A byte scan can land on embedded data or on halfwords that
are not reachable instructions. Each candidate still needs disassembly and
control-flow context. The scan does not identify the store that initializes the
pointer slot and does not establish the runtime value in that slot.

## Reproduction

```sh
make audit-runtime-base-pointer ROM=/path/to/original.gba
make test-runtime-base-pointer
make test-all
make check
```

## Validation

- Four focused synthetic-ROM tests cover literal address calculation, false-value
  rejection, evidence limits, and malformed odd-length images.
- Full regression suite and ARM7TDMI compile-only check are recorded in the
  validation log for this pass.
- No matching-ROM build is claimed.

## Next steps

1. Separate reachable Thumb code from data for the candidates near `0x08051650`
   through `0x08051880` and the known helper at `0x080517A4`.
2. Trace callers of `Input_TestMask` and `Input_SetState` using decoded branches,
   not raw BL-shaped halfwords alone.
3. Search the startup/runtime context setup for a write to `0x03000F48` and prove
   the effective base before mapping `+0x6B4` to any fixed RAM address.
4. Only after input flow is mapped should unusual input sequences be assessed as
   possible secrets. No Easter egg has been confirmed in this pass.
