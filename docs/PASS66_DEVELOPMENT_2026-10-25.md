# Pass 66 — descriptor follow-up helpers and adjacent data

## Scope

Pass 65 left the conditional helpers at `0x08049000` and `0x08049040` unclassified. This pass fingerprints both routines and the data immediately preceding the 24-byte descriptor table at `0x08069FEC`.

## Findings

- `0x08049000` loads a pointer from RAM slot `0x03000BEC`, reads a halfword at that pointer plus `0xEC`, and returns `1` if bit 0 is set, otherwise `0`. This establishes a boolean bit-test helper. The pointed-to structure and bit meaning are unknown.
- `0x08049040` writes `r1 << 8` to `0x030006DC` and `r2 << 8` to `0x030006E0`. It also reads signed halfwords from the source record at `r0 + 0x48` and `r0 + 0x4A`, shifts them left by eight, and writes them to `0x030006D4` and `0x030006D8`.
- The left shifts are consistent with storing integer-valued coordinates in a representation with eight fractional bits, but no consumer evidence in this pass establishes the units or semantic meaning. The safe labels are therefore “scaled values” and “coordinate-like source fields,” not world position, camera position, or screen position.
- The contiguous words `0x08069FC4` through `0x08069FE0` are `0xFFFFFFFF` followed by zeros. `0x08069FE4` is zero and `0x08069FE8` contains `0x08068968`. Since the relationship of this run to the descriptor table is not yet proven, the audit records the bytes without declaring a struct/header boundary.
- The table still begins at `0x08069FEC`, with 24-byte entries. Pointer-shaped and code-address-shaped words are present; the entries have not been semantically named.

## Confidence / limitations

Instruction flow and RAM addresses are directly supported by Thumb instructions and literals. The bit's purpose, pointer's type, coordinate units, table preamble's role, state identifiers, and any Easter-egg relevance remain unresolved. No Easter egg is claimed. The project is still not a byte-identical ROM rebuild.

## Validation

`tools/audit_state_descriptor_helpers_pass66.py` validates 39 instruction halfwords and 21 words against the original 8 MiB ROM hash. Five tests cover the original ROM, instruction mutations, literal mutation, and adjacent-data mutation.
