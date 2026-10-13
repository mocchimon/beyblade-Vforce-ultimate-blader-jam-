# Range arena reset (ROM 0x08060958)

Reconstructed in `src/runtime_range_init.c`. The function first iterates a resource-object chain at `0x03005DE4`, skips objects with flags bit 0 set (`+0x20`), and releases nonnegative range tokens at `+0x24` with length `1 << (u16(+0x16)-5)` before setting token to -1. The input is truncated to a 16-bit reserved offset and stored at `0x03005E6C`.

If the preallocated descriptor buffer pointer `0x03005DCC` is nonzero, it writes the active head to `0x03005DC8`, the spare head to `0x03005DD8`, and creates one free interval `[reserved,0x400)`. It then chains 31 additional 8-byte spare nodes at offsets +8 through +0xF8. The loop writes 30 next pointers, and the final write terminates the 31st spare node.

Evidence: `asm/runtime/range_reset_60958.dis.txt`. Host test `tests/test_runtime_range_init.c` verifies object-token release, head fields, interval bounds, and all 31 spare links. The test uses a stub for `RuntimeRange_Release`; integration with original ROM execution remains unverified.
