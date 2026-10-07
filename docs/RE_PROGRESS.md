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
`0x08050398`, including its `0x1C`-byte record stride and heap allocation.
