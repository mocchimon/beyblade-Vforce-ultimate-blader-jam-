# Pass 56 — follow-on runtime-context initializer (2026-10-25)

## Scope and verification

Added `tools/audit_runtime_context_followup_pass56.py`, a bounded ROM-backed audit for `0x08051120`, plus five regression tests, an instruction capture, and `docs/runtime_context_followup_pass56.json`. The audit checks the original 8 MiB ROM fingerprint (`a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`) and selected instruction halfwords/literal words. It is not a full disassembly or a matching-build claim.

## Important cross-pass correction

Pass 55 observed `0x080510C2` writing `1` to the runtime payload at offset `+0x6B4`. The follow-on initializer at `0x0805114A` then stores zero to that same offset. Thus the value is temporarily seeded to one by the first routine but is cleared during the follow-on initialization; the final value after this write is zero. This is an instruction-order fact, not a semantic identification of the field.

Other directly supported writes in this prefix:

- byte `+0x0` cleared; halfword `+0x6E8` cleared;
- byte `+0x6AB` set to `1`;
- word `+0x6C0` cleared;
- halfword `+0x6EA` set to `0xFFFF`.

## Table-backed initialization

The first loop uses indices 0 through 55 (56 iterations). Each iteration calls `0x08051744`, addresses a record at `0x08075B70 + index * 0xD0`, copies its `+4` and `+8` words to returned-object offsets `+4` and `+8`, and stores the record pointer at `+0xC`. The object's leading halfword is set to `6` for index zero and `4` for the remaining entries. Two calls to dispatcher `0x08065C44` are made with object-relative pointers at `+0x10` and `+0x14`, using an indirect callback loaded from `0x0807D994`.

A second loop initializes indices 0 through 9 (10 iterations). It calls `0x08051704`, stores `0x08075850 + index * 0x50` at returned-object `+4`, and clears the byte at `+0` and halfword at `+2`.

The table entries and callback semantics are not named because the current evidence only establishes their layout and dispatch pattern. This routine does not establish an Easter egg or secret-input trigger. Next useful step: trace helpers `0x08051744`, `0x08051704`, and the indirect callback/table usage without assuming they are gameplay secrets.
