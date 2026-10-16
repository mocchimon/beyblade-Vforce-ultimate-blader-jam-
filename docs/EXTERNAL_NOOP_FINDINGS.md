# Return-only external routines (2026-10-15)

Two previously unresolved runtime imports are now represented by
address-named C functions in `src/runtime_noop.c`.

- `0x08057B60` contains a Thumb `BX LR` at entry, with padding after it. The
  passed message pointer is not accessed.
- `0x08057C5C` saves `r0-r3` in temporary stack space, restores the stack
  pointer by the same amount, and returns without reading the values or
  producing caller-visible outputs.

The neutral address names preserve the limited evidence. The callers' message
strings do not establish that these entries log, report, or stop execution.
Their return-only behavior is verified from the user-supplied ROM; it is not a
silent behavior guess made to force a link. The C is behavior-level recovery,
not byte-matched assembly.

## Pass 17 call-site integration

The former `FatalError` source imports were not one consistent ROM routine:
allocation-failure paths in `RuntimeMemory_Init` and `RuntimeBlock_FindFree`
call `0x08057B60` with a message pointer, while `RuntimeObjectTable_Init` calls
`0x08057C5C` with a message pointer and allocation size. The active-list
validator also calls `0x08057C5C`; its second argument is not set at that call
site, but the callee does not inspect it. Source calls now bind to these exact
return-only entries instead of assuming logging or fatal termination.

## Pass 18 variable call shape

The record-manager initializer calls `0x08057C5C` with one argument for a
zero-size request and with three arguments after alternate-heap allocation
failure. The entry bytes are `push {r0-r3}; add sp, #0x10; bx lr`, so the C
prototype is now `void sub_08057C5C(const void *message, ...)`. This matches
the one-, two-, and three-argument source call sites while preserving only
what the ROM sequence proves: it does not inspect the arguments and returns.
