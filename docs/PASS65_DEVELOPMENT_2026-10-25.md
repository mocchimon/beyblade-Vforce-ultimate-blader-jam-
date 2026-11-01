# Pass 65 — state descriptor records and fixed-point record builders

## Scope

Pass 65 follows the state follow-up at `0x080495C8` into its three record helpers and fingerprints representative descriptor-table words at `0x08069FEC` against the original ROM.

## Findings

- The routine reads the state index from `0x03000654`. `0xFFFFFFFF` takes a no-descriptor branch.
- Otherwise it calculates `0x08069FEC + state_index * 0x18` and reads the word at descriptor offset `+4`.
- The table contains 24-byte records with mixed scalar and pointer-shaped words. Their semantic types and the full valid state-index range remain unresolved.
- A signed halfword at `0x03000AB4` gates the record-processing path. If the pointer chain from `[0x03000704]` through `[descriptor_pointer + 0x10]` and `[that_pointer + 0x28]` is non-null, the routine sends groups of four words from the pointed-to record to `0x080504E8` and `0x08050530`; the three argument groups are read from offsets `0x00`, `0x10`, and `0x20` of the same pointed-to record.
- `0x080504E8` and `0x08050530` use a signed halfword count at their argument object `+0x0C`, use the pointer at argument object `+8` as output base, and advance the output by `0x18` per iteration. The first builder stores two arithmetic-shifted, scaled values at output offsets `+0x10` and `+0x14`; the companion stores at `+0x08` and `+0x0C`.
- The scale recurrence begins with `0x100` and values are shifted right by eight after multiplication. This is consistent with fixed-point arithmetic, but the coordinate units and semantic use are not yet established.
- `0x0805057C` writes a word at destination `+0x10` and sign-extends a halfword argument before writing it as a word at `+0x14`. Nearby `0x08050578` writes a halfword at `+0x0E`.
- The shared path also calls `0x08043558`; conditional follow-up calls at `0x08049000` and `0x08049040` remain unclassified.

## Cross-pass correction / confidence

The Pass 64 report's `0x03000AB4` gate is consistent with the actual literal `0x464` added to base `0x03000650`. The table lookup arithmetic is `index * 24`, confirmed by `LSL index,1`, `ADD index`, then `LSL result,3`.

These are structural findings only. No state names, object types, coordinate units, or Easter-egg triggers are inferred. The project still has not demonstrated a byte-identical ROM rebuild.

## Validation

`tools/audit_state_descriptor_records_pass65.py` checks 130 instruction halfwords and 14 words (including descriptor-table entries) against the 8 MiB ROM. Five unit tests pass, including instruction and table-data mutation rejection.
