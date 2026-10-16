# Directory descriptor storage audit (2026-10-14)

The runtime-entry initializer at ROM `0x08062974` reads a **signed halfword**
from the directory's second pointer and indexes the resource pointer table
from its first pointer. An audit of all 32 directory entries in the supplied
BEYP revision-0 ROM establishes:

- All 32 second pointers refer to **ROM addresses** (0x08xxxxxx), not writable
  IWRAM/EWRAM index variables.
- There are **nine distinct descriptor addresses**: seven unique descriptors
  for slots 0–6, and two shared descriptors for slots 7–31.
- The two shared descriptors are `0x08074DD0` (13 odd slots) and
  `0x08074DD8` (12 even slots).
- All 32 signed halfword initial indices are zero.

**Implication:** It is inaccurate to describe these 32 ROM-backed descriptor
bytes as mutable counters. If resource selection changes during gameplay, the
mechanism must be investigated in runtime entry state, other table pointers,
RAM copies, or later calls. A RAM copy of the descriptor remains possible, but
has not been established. This audit does not prove the original code never
changes its resource selection; it only establishes the original storage class.

Run `make audit-directory-descriptors ROM=/path/to/game.gba` and
`make test-directory-descriptors ROM=/path/to/game.gba`.
