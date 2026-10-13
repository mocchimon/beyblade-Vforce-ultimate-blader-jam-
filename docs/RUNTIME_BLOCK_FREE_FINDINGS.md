# Runtime block release (`0x08063004`)

The release routine is now represented in `src/runtime_block_free.c`. It walks
the descriptor's `+0x08` payload as `slot_count` child records with a `0xC4`
byte stride, calling the existing child cleanup routine at `0x080588CC` for
each. It then repairs the `+0x0C` previous / `+0x10` next links, adjusts the
manager globals along the observed branch paths, and clears the payload field
at `+0x08` to mark the descriptor reusable.

The last-block path calls `RuntimeMemory_Init` (`0x08062E94`), matching the
original call target. The high-water mark at `0x03005E64` is decremented by the
released slot count when the record has a previous node but no next node. The
ROM does not visibly update every apparent tail/cursor global in every branch;
the C follows the actual stores instead of normalizing the list to an assumed
conventional allocator design.

The instruction dump remains in `asm/runtime/runtime_block_helpers_62fcc_631d4.thumb.dis.txt`.
This C routine compiles but has not yet been run against real game state, so
branch-specific global behavior remains unvalidated in an emulator.
