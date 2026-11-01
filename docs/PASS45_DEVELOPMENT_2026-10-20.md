# Pass 45 — ARM runtime module and offset-table audit

## Goal

Continue toward a matching ROM by validating the relocatable ARM module's exact
ROM boundaries and the offset table consumed by `ArmRaster_LoadModule`. This is
a bounded static-analysis improvement; it does not pretend to identify the
separate upper-IWRAM copy callback.

## ROM identity

- Size: 8,388,608 bytes
- SHA-256: `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`

## Results

- ARM-state module starts at `0x080641B8` and ends at `0x08064EDC` (exclusive).
- Exact image length is `0xD24` bytes.
- The following offset table contains 32 words, ending at `0x08064F5C`.
- The C loader consumes 29 of those 32 slots; slots at table offsets `+0x3C`,
  `+0x4C`, and `+0x50` are intentionally not rebased into the context record.
- The table includes a value of `0xD24`, which is a one-past-end pointer, not a
  code entry. The verifier permits this exact boundary and rejects larger
  offsets.
- Twelve named ARM routine entry offsets from the existing function map were
  corroborated against the table: `0x000`, `0x060`, `0x1AC`, `0x434`, `0x56C`,
  `0x698`, `0x85C`, `0x944`, `0xA80`, `0xAD4`, `0xC28`, and `0xC9C`.
- The image's first five ARM words match the disassembly fingerprint already
  recorded in `asm/runtime/arm_runtime_image_641b8.s`.

## Tooling

Added `tools/audit_arm_runtime_module.py`, the Make target
`audit-arm-runtime-module`, and four regression tests. The JSON report is
`build/reports/arm_runtime_module_pass45.json` when generated with the supplied
ROM. The audit checks image bounds, image fingerprint, table size, consumed
slots, and the one-past-end case.

Commands:

```sh
make audit-arm-runtime-module ROM=/path/to/original.gba
make test-arm-runtime-module
```

## Validation performed

- ARM module audit against the supplied original ROM: PASS.
- New module audit tests: 4/4 PASS.
- Existing runtime copy-path tests: 4/4 PASS.
- Existing copy-path audit still finds seven direct helper calls in its configured
  code range: CpuSet 1, LZ77 2, startup IWRAM installer 1, DMA3 backend 3.
- `make check`: all 61 C translation units compiled for ARM7TDMI and the source
  compilation target completed successfully.

The full `make test-all` suite was not run to completion in this pass, so this
report does not claim the entire suite passes.

## Interpretation and next target

This confirms the relocatable ARM module's image/table structure and improves
repeatability for future ROM comparisons. It does **not** show that the module
is installed at `0x030061B8`, nor that it supplies `0x0300646C`, `0x0300682C`,
`0x03006FAC`, or the unresolved callback at `0x03007034`. The existing loader
allocates the image through the ordinary heap path; absent evidence for another
copy path, it must not be presented as the missing IWRAM installer.

Next: trace writers/readers of the upper-IWRAM function table and investigate
whether its pointers are initialized by a separate runtime descriptor or by
code outside the known DMA/LZ77 call sites. Matching-ROM progress remains 0%
verified; the historical 54% source-recovery figure remains an unmeasured
estimate.
