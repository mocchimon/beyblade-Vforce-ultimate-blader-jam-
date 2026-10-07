# Pass 5 findings

Target: `BEYP70` Rev.00, 8 MiB.

This pass concentrates on the persistent loop and the runtime/event cluster. Names remain provisional unless the binary behavior supports a stronger interpretation.

## Startup loop correction

The Thumb entry at `0x080505A8` has the following relevant sequence:

```text
0805EFC0  call with (global_base + 0xBA0, 0)
08052538  call
08049268  call
08060544  Runtime_ResetPools(0x80, 0x20)
0804945C  call
080578FC  VBlank wait
08062814  call
0805A6DC  call
08060544  Runtime_ResetPools(0x80, 0x20)
08053398  call
0805193C  call
080578FC  VBlank wait
08062814  call
08053BB8  call
08053CD8  call
080517A4  Input_TestMask(2)
if zero -> 080512D0
repeat
```

The previous pass had simplified this section too aggressively. Pass 5 keeps the direct calls visible in `src/main.c` and records the actual second VBlank/event phase.

## `0x08049268`

This routine operates on a large state object pointed to by the global at `0x0300500C` (literal-loaded base). It:

- writes `0xFFFF` to an object field at offset `0x0C26`;
- clears fields at offsets `+4` and `+0xC`;
- calls `0x08049250(7)`, which stores `7` at offset `+0x10`;
- sets fields at `+0` and `+8` to `-1`;
- clears a byte at `+0x7C`;
- invokes `0x08050388` on the state object at offset `0x458`;
- clears several additional 16/32-bit fields in the same state area.

This is strongly consistent with a per-frame/state-context reset or preparation routine, but its game-level role is not yet proven. It is tracked as `GameState_FramePrepare` provisionally.

## `0x0804945C`

This routine is substantially more complex. It:

- calls `0x0804901C` and waits for VBlank;
- passes the state/context pointer to `0x0804A284`;
- invokes `0x08062814`;
- toggles byte flags in a global/state area;
- calls `0x0804916C` and `0x080490FC`;
- tests a pair of state words against `-1`;
- invokes `0x0805A6DC` and `0x08062814` again;
- performs additional state/event processing and calls `0x08065C38`;
- processes a non-null pointer at context offset `0xB4` and associated object data.

It is therefore tracked as `GameState_FrameDispatch` provisionally. It is not yet safe to call it a generic “game tick,” because it contains state-transition and object/event checks beyond a simple update loop.

## `0x080512D0`

The routine iterates indexed control/state records. Important recovered behavior:

- starts with index `0`;
- obtains two indexed record pointers through `0x08051744` and `0x08051734`;
- checks a bit (`0x2`) in a record halfword;
- checks a byte at offset `0x1C` and scans a range using a value at offset `0x24` against another record's `+8` value;
- when the condition is satisfied, ORs bit `0x2` into the record halfword and stores the current index into a global halfword;
- a second path checks bit `0x1` in another indexed record and can also set bit `0x2`.

This is a real control/event state machine, not merely a no-op fallback. Exact event semantics remain unresolved.

## `0x0805A6DC`

This routine consumes queued 16-bit values when a queue/state selector equals `2`, updates a read pointer by two bytes, decrements a remaining-count field, mirrors an input-derived mask, and then processes a second queued stream. This looks like an input/event queue service, but the exact producer/consumer relationship is not established yet.

## `0x08062B44`

This function is only a two-instruction global setter:

```c
*(uint32_t *)0x03005E14 = value;
```

It is safe to name this `Runtime_SetCallbackOrContext` provisionally, but the actual type of the stored value is still unknown. The startup call passes `0x08040CC4`.

## `0x08062814`

The first half is now better constrained. It reads:

- a pointer/global at `0x03005E24`;
- a byte state at `0x03005E04`;
- a pointer/descriptor at `0x03005E1C` and its `+4` field;
- a timing value at `0x03000401`/related display timing storage;

then aligns the current counter with `& ~1`, compares it with the previous counter, and dispatches records through `0x080627CC` in 0x28-byte strides. This supports the earlier neutral `FrameEvent_Service` name, but the records should not yet be called gameplay objects.

## `0x08062B50` / `0x08062B44` cluster

The cluster contains a table with 16 outer entries and 4 subentries per outer entry. Each subentry has an active byte at `+4` and a 32-bit value at `+8`. Active entries are passed to `0x08062AB4`, then marked inactive. This is a concrete deferred-work/event table.

`0x08062BCC` (exact address `0x08062BCC`) bounds-checks an index against the table's first word, retrieves an entry from an 8-byte stride, stores its two words into globals, clears two status globals, and sets another status flag. This is strong evidence for an event/deferred-work subsystem.

## New raw disassembly

`asm/pass5/` contains exact Thumb disassembly slices for the major newly traced functions. These are reference material until the corresponding C reconstruction can be made trustworthy.
