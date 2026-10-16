# IWRAM counter helpers recovered (BEYP revision 0)

Two Thumb routines operate on a shared two-word structure at IWRAM address `0x03000EE0`:

- `0x08057B78`: `ldr r1, =0x03000EE0; movs r0, #0; str r0, [r1,#4]; str r0, [r1]; bx lr`. Both 32-bit words are cleared (second first).
- `0x08057B88`: `ldr r1, =0x03000EE0; ldr r0, [r1]; adds r0,#1; str r0,[r1]; bx lr`. The first word increments with 32-bit wrapping; the second is unchanged.

Both literal-pool words independently encode `0x03000EE0` at `0x08057B84` and `0x08057B94`.

`src/runtime_counter.c` is a functional C reconstruction. `tests/test_runtime_counter.py` verifies instruction halfwords and literal addresses against the original ROM; `tests/test_runtime_counter.c` verifies reset, increment, wrap and preservation of the second word in mapped simulated IWRAM.

These functions' callers and higher-level meaning remain to be identified. The host test does not establish a byte-matching ARM build.
