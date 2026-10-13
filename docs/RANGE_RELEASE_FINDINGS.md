# Runtime free-range release (0x0806082C)

The ROM's Thumb routine takes `r0=token/start` and `r1=length`, traverses the sorted linked list rooted at IWRAM `0x03005DC8`, and merges with a range whose start matches the returned interval's end or whose end matches the returned interval's start. If the returned interval precedes an existing node without touching it, it removes a spare node from `0x03005DD8`, inserts it before the current node, and initializes the 8-byte record (`u16 start; u16 length; u32 next`). It then traverses the active chain, merging contiguous neighbors and returning absorbed nodes to the spare list.

The spare-exhaustion path invokes the shared diagnostic dispatcher at `0x08057C5C` with a ROM text pointer; the C reconstruction currently models only the return, not the diagnostic side effect. The ROM assumes an initialized, nonempty active list before its final coalescing walk. The C reconstruction adds a null guard for safety and is therefore behavioral rather than matching assembly. Range start/length truncate to 16 bits as in the ROM. No ROM matching is claimed.

## Host-side verification (2026-10-11)

`tests/test_runtime_range.c` maps simulated IWRAM at `0x03000000` and directly
executes `RuntimeRange_Release` in seven scenarios: backward extension, forward
extension, disjoint insertion using the spare pool, bridging two adjacent
intervals, multi-node coalescing with spare recycling, spare exhaustion, and
empty-list guard. All seven assertions passed on the host. The test confirms
internal consistency of the C reconstruction, **not** equivalence to original
ROM execution. Unresolved: append-after-tail semantics, diagnostic dispatcher,
invalid/overlapping inputs, and range-descriptor initialization.
