# Pass 6 findings

Target: `BEYP70` Rev.00, 8 MiB.

This pass tightens the resource/runtime allocation cluster and records exact
literal/global relationships instead of carrying forward speculative fields.

## `0x08062490` — RuntimeObjectTable_Init (provisional)

Recovered facts:

- calls `0x08062370` before argument normalization;
- caps the second argument at `0x10`;
- caps the first argument at literal `0x0000ABEA`;
- descriptor base is `0x03005E40`;
- descriptor fields at `+0`, `+4`, `+8` are written as `base`, `1`, `0`;
- allocates a variable-sized block through `0x080661E4` using a value derived from
  the descriptor count and the supplied count;
- stores the returned block at `0x03005E2C` and errors with literal
  `0x08755DB4` on failure;
- reads the first word of that block into `0x03005E1C`;
- allocates exactly `0x440` bytes through `0x0805A444`, stores the result at
  `0x03005E30`, and errors with `0x08755DE8` on failure;
- reads the first word of the second block into `0x03005E28`;
- establishes pointers around `0x03005E50`, `0x03000D98`, and the byte at
  `0x03005E04`;
- calls `0x080623CC` to populate the 0x80-entry table;
- writes `0x80` to `0x03000DA0`.

The exact semantic identity of the allocated objects is still unknown.

## `0x08062E94` — RuntimeMemory_Init (tightened)

Exact recovered behavior:

```c
*(u32*)0x03005E64 = 0;
*(u32*)0x03005E5C = 0;
*(u32*)0x03005E60 = 0;
large = Heap_AllocAlt(0xC400);
small = Heap_AllocAlt(0x1400);
if (!large) FatalError(0x08755E48);
if (!small) FatalError(0x08755E78);
*(u32*)0x03005E68 = *(u32*)large;
*(u32*)0x03005E54 = *(u32*)small;
*(u32*)0x03005E58 = 0;
*(u32*)0x040000D4 = 0;
*(u32*)0x040000D8 = *(u32*)small;
*(u32*)0x040000DC = 0x85000500;
```

The previous source had incorrectly assigned additional inferred fields. Those
assignments were removed; the assembly remains authoritative.

## `0x0805A6DC` — ControlQueue_Service

The queue service is now understood more precisely as a pair of 16-bit streams:

- selector at `0x03005CA4` gates the first stream when equal to `2`;
- read pointer is advanced by two bytes and remaining count decremented;
- a second stream is serviced when the selector is not `2`, with an inverted
  key mask involved;
- the resulting mask is mirrored into a separate control halfword before the
  indexed record scan begins.

This is still intentionally not called a keyboard/gameplay routine.

## `0x08062814` — FrameEvent_Service

The table walk is now confirmed as 0x28-byte records. The routine computes a
signed delta between two timing/cursor values, then repeatedly calls
`0x080627CC` with a record pointer and a cursor-derived value. The post-loop
path adjusts the global cursor using the same delta and invokes `0x08065C44`.

This is strong evidence for scheduled/timed record processing, but not enough
to assign a gameplay-specific meaning to those records.
