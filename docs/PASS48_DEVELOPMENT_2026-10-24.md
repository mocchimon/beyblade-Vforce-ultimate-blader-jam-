# Pass 48 — Original-ROM validation and IWRAM installer candidate audit

## Input provenance

Original GBA image provided separately by the user; 8,388,608 bytes; SHA-256 `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`. **The ROM is not included in the project archive.**

## Verified results

- `make test-all` passes with the original Pass 47 regression suite.
- `make check` compiles all 62 C sources for ARM7TDMI; this is a compile-only check, not a linked ROM.
- `tools/verify_runtime_copy_callback.py` verifies 38 instruction halfwords and three callback call sites using slot `0x0807D998` -> ARM-state address `0x03007034` via trampoline `0x08065C44`.
- `tools/audit_iwram_function_table.py` verifies 25 pointer-table entries containing 16 distinct IWRAM targets.
- `tools/audit_startup_iwram_installer.py` verifies a startup DMA copy at `0x08057968` from `0x08000168` to `0x03000FE0`, with computed count `0x49` words. This transfer cannot directly populate `0x03007034`.
- `tools/audit_runtime_image_bounds.py` verifies the separate ARM runtime image `[0x080641B8,0x08064EDC)` of length `0xD24`; assuming a **hypothetical, unproven** load base of `0x030061B8`, the callback is `0x158` bytes beyond its end.
- The full ROM Thumb LDR-literal candidate scan found 23 candidates (8 IWRAM-address and 15 DMA-register references). No LDR-literal candidate directly resolves to `0x03007034`. See `iwram_install_candidates_pass48.json` for instruction-level candidates and caveats.

## Interpretation and limits

The original ROM confirms the pointer-table target and known copy paths, but does **not** yet identify the executable bytes installed at `0x03007034`. Absence of direct literals is not evidence that no loader exists: computed addresses, decompression, and other copy mechanisms remain possible. Candidate instructions may be data misidentified as Thumb code. No new implementation is claimed in this pass.

## Next work

Trace the DMA-register reference cluster around `0x080659B6` and the runtime initialization paths, verifying actual transfer source, destination, length, and reachability. Then inspect decompression destinations and any runtime relocation descriptors that cover `0x03007034`.
