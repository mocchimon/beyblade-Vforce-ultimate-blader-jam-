# Frame dispatcher host integration verification

`tests/test_frame_dispatch.c` executes the reconstructed `FrameEvent_Service` at ROM address `0x08062814` using simulated GBA IWRAM and timer register pages. The test is built with a non-PIE host executable so the 32-bit GBA callback slot can hold the test callback's address.

Verified cases:
- Disabled gate: no script, entry, or transfer callbacks.
- Normal Timer0 advance: two 0x28-byte entries serviced, one transfer callback, cursor advanced.
- Timer0 rollover: transfer divided into two segments, second segment starts at the ring base after interval subtraction, cursor and elapsed window updated.

The script and per-entry routines are test doubles here. The test validates the recovered dispatcher and its callback contract; it does **not** prove matching original instructions, correct hardware behavior, or complete script-to-frame integration.

Run: `make test-frame-dispatch` or `make test-all`. The test requires Linux `mmap` with `MAP_FIXED_NOREPLACE` and a non-PIE host executable. It is not intended to run on GBA hardware.
