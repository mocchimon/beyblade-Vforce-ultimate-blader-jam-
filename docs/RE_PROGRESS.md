# Reverse-engineering progress

## Pass 1 — boot and entry

`08000000` → `087FE7B4` relocation stub → `020000C0` relocated startup → `080505A9` Thumb entry.

## Pass 2 — high-level entry

The high-level startup at `0x080505A8` is mapped through its first persistent loop. It initializes platform state, control state, several runtime/resource subsystems, then enters a VBlank-driven polling loop.

## Pass 3 — recovered low-level systems

### Input mapping

- `08063A74` — clears 0x15-byte mapping table at `0x03005E80`.
- `08063A8C` — writes a mapping byte when index <= 0x14.
- `08063AA0` — stores a 32-bit input state at `0x03005E98`.
- `080517A4` — tests a mask against that state.

### Control state

`0805A890` is now treated as `ControlState_Init`, not merely `Input_Init`. It reads `KEYINPUT`, mirrors the inverted state into control globals, clears queue/counter fields, and initializes ten 0x18-byte records at `0x03005CB0`.

### Heap allocator

The cluster `0805A3CC`–`0805A608` is a linked free-list allocator. Recovered operations include allocation front-ends, block splitting/insertion, free/unlink, and free-block search. Exact original type names remain unknown.

### Runtime pools

`08060544` caps two counts at `0x80` and `0x20`, allocates backing storage with the game's heap, and is called at startup and repeatedly from the frame loop. This strongly suggests per-frame/runtime pool setup rather than one-time hardware initialization.

### Resource descriptor

`0805FEF4` is called from startup as `(2, 0x10, 3)` and constructs a descriptor containing derived pointers and dimensions. Its exact subsystem ownership is still unresolved, so the source uses the neutral `ResourceDescriptor` name.

## Pass 4 — current targets

1. Resolve `08062370` / `08062490` and the `0x03005Exx` resource table.
2. Resolve `08062E94` and its two heap allocations (`0xC400` and `0x1400`).
3. Trace `0805EFC0` and `08052538` from the first persistent-loop iteration.
4. Resolve `08062814`, including its 0x28-byte record/ring-buffer behavior.
5. Continue outward through the call graph until the game-state machine is identified.

## Pass 4 — resource/runtime structures

### Resource table (`080623CC`)

The routine beginning at `0x080623CC` iterates exactly `0x80` entries. It
loads a table base from `0x03000D98`, calls a helper chain to derive a value,
and stores one 32-bit result per entry. After the loop it updates the timing/
resource globals at `0x03000D90`, `0x03000D94`, `0x03000DA0`, and `0x03000DA2`.
The semantic identity of the generated values is intentionally unresolved.

### Runtime memory initialization (`08062E94`)

The first routine in the `0x08062E94` cluster clears three globals and obtains
backing storage of `0xC400` and `0x1400` bytes from the game's allocator. The
pointers are then installed into the runtime descriptor globals. This is now
separated from the later 0x28-byte object-table initializer.

### Frame/event service (`08062814`)

The entry performs two global-state checks before entering its timing/event
logic. The routine contains a state-dependent dispatch and is not yet named as
an ordinary gameplay tick. Further reconstruction is required before assigning
it to a specific game subsystem.

### Important correction

The earlier pass described `08062370` and `08062490` too broadly as a single
resource initializer. The new pass separates the routines by their actual
entry points and records the observed 0x80-entry table construction and the
0x28-byte object allocation path independently.

## Pass 5 — persistent-loop/event tracing

Resolved several previously opaque direct call targets from the startup loop:

- `08049268` — large state-context preparation/reset routine.
- `0804945C` — state/context dispatch routine with VBlank and event/object checks.
- `080512D0` — indexed control/event state scan.
- `0805A6DC` — queued 16-bit control/event stream consumer.
- `08062B44` — one-word runtime context setter.
- `08062BCC` — deferred-event table lookup/start routine.

Also corrected `src/main.c` so the second VBlank/`08062814` phase and direct `08049268`/`0804945C` calls are represented instead of being hidden behind comments.

## Pass 7

Recovered the `0x0804901C–0x0804945C` state/context cluster: context history, pending-index handling, signed fixed-point scaling, main state initialization, and a five-way indirect state dispatcher. See `docs/PASS7_FINDINGS.md` and `src/game_state.c`.

## Pass 8

Refined the state dispatcher after checking its target addresses directly. The
five entries at `0x08049348` are shared-tail continuations, not independent C
handlers. Also traced `0x0804A284` and recovered the structural behavior of
`0x08050398`, including its `0x18`-byte record stride and heap allocation.

## Pass 9

Recovered the resource/handle lifecycle around `0x0804AF08` and
`0x0804AF60`, including the selector field at `0x03000FB0 + 0xC26`, handle
field at `+0xC2C`, ROM resource table at `0x08075640`, and the 0x28-byte
runtime-entry search/status helpers around `0x08062A74`.

## Continued object/render runtime recovery

Direct disassembly of the child initializer at `0x08057C7C` confirms that the
`0xC4`-byte child record initializes a command/event queue at `+0x74`:

- `+0x6C` is cleared.
- `+0x70` receives the caller-supplied initial activity/timing value.
- `+0x74` is initialized to `-1` (queue uninitialized).
- `+0x78` and `+0x7C` are cleared and later hold the 0x40-byte queue pointer
  and its allocation respectively.
- `+0x80` is initialized to zero, `+0x84` to `-1`, and several nearby control
  bytes/words are cleared.
- `+0xA0`..`+0xA5` are initialized by the child setup path.
- `+0xA8`..`+0xAE` receive four halfword transform/control values through
  `0x0805861C`.
- `+0xB8` is cleared, `+0xBC` is cleared as a halfword, and `+0xC0` is cleared.

`0x080587B8` is now characterized as a four-slot queue append routine. It
allocates exactly `0x40` bytes on first use, treats that allocation as four
`0x10`-byte entries, searches for an empty entry once the queue reaches four
entries, and wraps to slot zero if all four are occupied. The four entry words
are populated from the routine's four value arguments; their semantic meaning
is still intentionally unresolved.

`0x08058900` clears the first word of each active queue entry and resets the
queue count to zero. It does not free the 0x40-byte allocation.

`0x08058400` reads a referenced resource/descriptor and copies its small
metadata fields into the child record, while `0x080584DC` advances the child's
three fixed-point position/step accumulators and handles its activity timer.
These routines are strong evidence that the child structure is part of a
render/animation-oriented runtime object, but no game-specific name is being
assigned yet.

## Verification cleanup

The cumulative C source tree now passes an ARMv4T/Thumb freestanding syntax
check with clang. Remaining diagnostics are qualifier/narrowing warnings in
older provisional files, not syntax failures. `runtime_entries.c` also had an
incorrect placeholder assignment in `RuntimeEntry_InitIndexed`; it has been
corrected to store the source-table pointer at entry `+0x1C`, matching the ROM.

## Continued render/runtime recovery

The cluster `0x08058948..0x08058D68` was disassembled directly from the ROM.
Two small table helpers at `0x08058948`/`0x08058960` were recovered, and the
larger initializer family at `0x0805898C`, `0x08058A4C`, `0x08058ACC`, and
`0x08058C98` was mapped. `0x08058ACC` is now represented by a conservative
field-level source reconstruction in `src/child_resource_init.c`; unresolved
helper semantics remain explicit rather than guessed.
