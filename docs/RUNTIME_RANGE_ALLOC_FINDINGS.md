# Runtime range allocator — ROM 0x080607B4

Recovered from the Thumb instructions at ROM offsets 0x607B4–0x60827. This routine accepts a requested unsigned size in r0 and returns a signed 32-bit range start or -1 on failure.

- Active list head: `0x03005DC8`; spare descriptor list head: `0x03005DD8`.
- Node layout: `u16 start`, `u16 length`, `u32 next` (8 bytes).
- Uses first-fit over the active free intervals, skipping insufficient nodes.
- Allocates from the start of the chosen interval, increasing its start and reducing its length with 16-bit stores.
- When the interval is exhausted, removes/recycles the descriptor **except** when it is the only active descriptor. The last exhausted descriptor remains active with zero length.
- Failure invokes a diagnostic helper then returns -1. The reconstructed C preserves the return but omits the diagnostic side effect.

Implementation: `src/runtime_range_alloc.c`. Disassembly: `asm/runtime/runtime_range_alloc_607b4.thumb.dis.txt`.

Seven host tests cover first-fit, skipping small intervals, head/middle descriptor recycling, sole-node exhaustion, empty-list failure, and allocation followed by release. They validate the C model, **not** byte-matching or emulator equivalence.
