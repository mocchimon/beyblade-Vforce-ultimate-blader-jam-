# Pass 64 — follow-up after state selection at `0x080495C8`

## Scope

Pass 63 established that both state selection and history restoration converge on `0x080495C8`. This pass fingerprints that routine and follows its initial descriptor lookup and conditional record-processing path. It does not assign human-readable meanings to the numeric state IDs.

## ROM-backed observations

- The routine reads the state block through `0x03000650`; the state word at block offset `+4` is compared with `0xFFFFFFFF`.
- For a non-sentinel state, it computes `0x08069FEC + state_id * 0x18`, then reads the word at descriptor offset `+4`. This supports a table of 0x18-byte records, but does not establish the record type's semantic name.
- It also reads a pointer from `0x03000704`, then the word at that pointer's `+4` field.
- A signed halfword at `0x03000AB4` gates one record-processing path. That path follows pointers at `[r2+0x10]` and then `[pointer+0x28]`; when non-null, it forwards two groups of record words to `0x080504E8` and `0x08050530`, and a word plus signed halfword at record offset `0x26` to `0x0805057C`.
- The shared path calls `0x08043558`. If a descriptor pointer was obtained, the routine checks its field at `+0x24`, calls `0x08049000`, and may then call `0x08049040` with fields from the object at `+0x24`.

The disassembly does not prove that these are “state entry callbacks” or that any of the numeric IDs correspond to a particular screen. Those remain hypotheses until the descriptor table and caller data are decoded further.

## Validation

`tools/audit_state_followup_pass64.py` checks 75 instruction halfwords and four literal words against the original 8 MiB ROM (SHA-256 `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`). `tests/test_state_followup_pass64.py` has five tests, including mutation rejection for the prologue, descriptor lookup, record dispatch, and global literal.

Run:

```sh
make audit-state-followup-pass64 ROM=/path/to/original.gba
make test-state-followup-pass64
```

## Next step

Inspect descriptor records in `0x08069FEC` and identify where the state block's word at `+4` is set. Then map the targets `0x080504E8`, `0x08050530`, `0x0805057C`, and `0x08043558` to determine what the follow-up routine actually configures.
