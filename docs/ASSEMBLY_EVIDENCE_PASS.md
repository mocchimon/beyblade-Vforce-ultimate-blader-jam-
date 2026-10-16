# Pass: Assembly evidence inventory

This pass processes **all nine** archived pass5 Thumb listings together, instead of incrementally modifying the CFG tracer. `make audit-assembly-evidence` generates `build/reports/assembly_evidence.json`, with per-listing instruction counts, call destinations, branch destinations, and load/store counts. The parser is deliberately simple: it is an evidence index, **not** a disassembler or a source recovery claim.

Observed from the supplied listings: 1,215 decoded instruction lines; 36 distinct BL/BLX destinations outside the respective individual listings. "Outside listing" does not mean undefined in the project, and the listings may be truncated. Four listings match names in the unresolved-linkage report; these are candidates for follow-up, not verified implementations.

## Immediate recovery plan

1. Compare each unresolved call site with its matching listing, then map its parameters and return convention.
2. Cross-link targets across the nine listings and other recovered sources before deciding whether a function is missing.
3. Reconstruct `sub_08049268` initialization as a set of field writes only after confirming literal-pool constants and RAM layout.
4. Reconstruct `sub_0804945C` control loop only after determining state transitions and callees.
5. Separate the distinct routines appearing inside `sub_080512D0` and `sub_0805A6DC` listings; filenames are not necessarily single functions.
6. Validate recovered behavior against the original ROM when available. Do not use fake stubs or raise the 54% estimate for tooling.

## Validation

`make check` compiled all 40 C source units; `make test-assembly-evidence` passed both synthetic tests. This does not establish a matching ROM build.
