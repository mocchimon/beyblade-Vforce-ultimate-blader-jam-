# ROM matching status and comparison procedure

Current project: compile-only. There is no recovered linker script, verified
compiler toolchain/version/flags, fully linked GBA image, or established
byte-identical build. Compiling ARM object files does **not** demonstrate ROM
matching, and the working 54% source-recovery estimate is not byte coverage.

## New independent comparator

Run `make test-compare-rom` for ROM-independent tests. Once a candidate `.gba`
actually exists, run:

    make compare-rom ROM=/path/to/reference.gba CANDIDATE=/path/to/candidate.gba

The comparator checks complete file identity (size and SHA-256), contiguous
matching/mismatching byte ranges and GBA ROM addresses. It returns a nonzero
exit code for mismatches and writes `build/reports/rom_comparison.json`.
Reference ROM and candidate bytes are never included in the report. Keep ROMs
outside the project archive. Matching byte percentages do not measure
reconstructed functions or semantic equivalence.

## Real build blockers

1. Recover/link remaining referenced code and data (see recovery backlog).
2. Recover original ROM section layout and linker addresses.
3. Determine matching compiler, ABI, instruction-state and optimization flags.
4. Supply original assets/data locally without distributing ROM bytes.
5. Produce a bootable candidate and validate in an emulator.
6. Compare against the reference; resolve first mismatching regions and repeat.

Do not label a compile-only `make check` result as a matching ROM build.
