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

## Runtime pointer/configuration table pass

Started the next pass by following the literal-pool reference to `0x0807D920`.
The region is structured mixed data: runtime-global addresses, Thumb code
pointers, scalar configuration values, and compact lookup-table bytes coexist
near one another. A PC-relative load in the `0x080602xx` region references the
block; the literal is at `0x080602C0`, with a load site at `0x0806027E`.

The `0x0300646C` word appears at `0x0807D968`, while code reads that global at
`0x08059254` and `0x080593FC`. This supports the function-pointer-slot
interpretation but does not yet prove the store/initializer or final target.
Details and explicit confidence boundaries are in
`docs/RUNTIME_POINTER_TABLE_FINDINGS.md`.


## Runtime configuration consumer follow-up

Disassembly around `0x0806027E` now establishes a concrete use of the mixed
block: the routine loads `0x0807D920`, dereferences its first word (`0x0300717C`),
and branches indirectly through the `0x08065C38` trampoline (`bx r0`). This
means at least some entries may point into IWRAM runtime code; they should not
all be described as ordinary global-variable addresses. The block's exact
record layout and the write to `0x0300646C` remain unresolved. Evidence is
recorded in `docs/RUNTIME_CONFIG_CONSUMER_FINDINGS.md` and
`asm/runtime/runtime_config_consumer_60170.s`.

### 2026-10-09 — renderer-slot literal scan

- Reconstructed the consumer sequence at `0x0805921C`: it loads the address of `0x0300646C`, dereferences the mutable slot, and invokes the resulting target via `0x08065C48` (`bx r4`).
- Scanned the complete ROM for the aligned word `0x0300646C`: its sole occurrence is the mixed-data word at `0x0807D968`; no direct Thumb literal-load reference to that word was found. This suggests indirect/base-relative or data-driven initialization, but does not prove the writer is absent.
- Added a table of known words from `0x0807D920` to the runtime config findings document, preserving uncertainty around record boundaries and semantics.
- Next: reconstruct the setup/copy routine(s) for the `0x03006xxx` runtime region and search for stores through base/index addressing; keep `0x08059428` as a candidate backend until the slot value is proven.


## Render dispatch re-check

Re-read the raw Thumb instructions around `0x08059334–0x08059428` and corrected an earlier overconfident backend association. `0x08059520` is directly selected when child `+0x64` bit 0 is set. Other branches use IWRAM targets `0x0300646C` and `0x0300682C`; their installation/source has not yet been found. `0x08059428` is now neutrally named `sub_08059428` until a byte-copy or assignment relationship is demonstrated.


## Startup IWRAM install correction

Re-disassembly of `0x08057968` corrected a misleading legacy name/comment: the function programs DMA3 to copy `0x104` bytes from ROM `0x08000168` into IWRAM `0x03000FE0`, then records the destination at `0x03007FFC`. The destination range ends at `0x030010E4`, so it does not explain the unresolved renderer targets at `0x0300646C` and `0x0300682C`. Source and function-map labels were updated to `System_InstallIwramBlock`; details are in `docs/IWRAM_INSTALL_FINDINGS.md`.
