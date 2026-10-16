# ROM-confirmed shared handler recovery (BEYP revision 0)

The runtime vector at `0x0807D950` contains the Thumb-state address
`0x08057B65`, whose underlying function at `0x08057B64` is exactly
`70 47` (`bx lr`). It returns immediately without touching state.

The vector at `0x0807D954` contains `0x08057C5D`. Its underlying
function at `0x08057C5C` has exactly `0F B4 04 B0 70 47`:

```
push {r0, r1, r2, r3}
add sp, #16
bx lr
```

These instructions leave no persistent side effects; the push/discard
sequence only consumes and restores stack space. The function is
referenced by `heap.c`, `resource_descriptor.c`, and `runtime_script.c`
for diagnostic messages, but **this ROM revision does not output them**.
Both recovered functions are implemented as no-ops in
`src/runtime_diagnostics.c`. They are behaviorally equivalent, not
instruction-identical C output. The two vector entries are **not**
evidence of IWRAM installation; these particular targets reside in ROM.

Run `make test-runtime-diagnostics ROM=/path/to/original.gba` to verify
exact instruction bytes, pointers and the C test. The ROM is not bundled.
