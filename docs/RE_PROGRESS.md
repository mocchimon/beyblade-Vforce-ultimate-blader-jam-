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


## IWRAM target interpretation correction

Instruction-level review corrected a prior misconception: `0x0300646C` and `0x0300682C` are direct IWRAM branch targets supplied by ROM words at `0x0807D968` and `0x0807D96C`, not RAM variables containing function pointers. `0x0805921C` loads `0x0807D968`, reads `0x0300646C` from the ROM table, then dispatches through `bx r4`; the clipping path similarly routes through `bx r9`. The code-install source for these IWRAM addresses remains unresolved. See `docs/IWRAM_TARGET_INSTALL_FINDINGS.md`.

## Copy-site audit follow-up

Audited the full ROM's Thumb disassembly for direct calls to the known LZ77 wrapper `0x080578F4`: only `0x08055CA8` and `0x080572F8` call it directly, and both callers pass allocator-returned destinations for resource data. The only direct call to `System_CpuSet` at `0x080578E4` is `0x0805070A`, with zero source/destination and control `0x40000000`, consistent with a clear/fill operation rather than ROM-to-IWRAM code installation. This does not find the writer for `0x0300646C` / `0x0300682C`; custom copy loops and descriptor-driven DMA remain open. See `docs/IWRAM_COPY_SITE_AUDIT.md`.

## 2026-10-09 — Follow-up DMA destination audit

Expanded the DMA3-site audit beyond literal-address scans. The setup sequence at `0x0805EFF8` uses a runtime descriptor for destination and length while sourcing from a ROM address loaded into `r6`, making it a stronger candidate for a data-driven copy than routines whose destinations are clearly VRAM or hardware state. This candidate remains unproven: the descriptor producer and destination range have not yet been traced. The sequence at `0x08062ED0` uses a stack source and control value `0x05000000`, so it is currently classified as a fill/state-transfer path, not code installation. Added these distinctions to `docs/IWRAM_COPY_SITE_AUDIT.md` and kept both IWRAM render targets unresolved.

## 2026-10-09 — DMA candidate caller trace

Traced the DMA setup site at `0x0805EFF8` back to its containing routine (`0x0805EFC0`) and startup caller (`0x08050644`). The caller passes `*(0x03000FB0) + 0xBA0` and zero, before the frame loop. The routine allocates a `0xD24`-byte context-associated block, configures DMA3 from runtime fields, and builds pointer-like fields by adding offsets from a ROM table. This supports classifying it as startup context/table setup, but does not prove it installs executable code into the unresolved IWRAM targets. The target-source question remains open.


## 2026-10-09 — ARM-mode runtime image identified

Re-disassembly of `0x0805EFC0` and inspection of the source region established an ARM-state image at `0x080641B8` with length `0xD24`, ending exactly at `0x08064EDC`. The bytes at `0x08064EDC` form an offset/relocation table; the loader copies the image using the allocated block descriptor's address and size, then rebases selected internal offsets into runtime context fields. This is strong evidence for a relocatable ARM-mode runtime module.

A potentially important address correspondence emerged: if the image were based at `0x030061B8`, the renderer's IWRAM targets `0x0300646C` and `0x0300682C` would map to ROM offsets `0x0806446C` and `0x0806482C` (offsets `0x2B4` and `0x674`). Both are inside the ARM-mode image and decode as ARM instructions. However, the currently traced loader uses a heap block descriptor and its actual destination has not been proven to equal `0x030061B8`. The correspondence is therefore recorded as a high-value hypothesis, not a confirmed alias. See `docs/ARM_RUNTIME_IMAGE_FINDINGS.md` and `asm/runtime/arm_runtime_image_641b8.s`.

## 2026-10-09 — checked the ARM-image/IWRAM offset hypothesis

Re-disassembled heap initialization at `0x0805A374`. It initializes the primary heap arena from `0x02000000` (EWRAM), with adjacent boundaries around `0x02000200` and `0x02000400`. The loader at `0x0805EFC0` allocates `0xD24` bytes through that allocator and copies the ARM-state image at `0x080641B8` into the allocated block. This means the tempting correspondence between image offsets `0x2B4` / `0x674` and IWRAM targets `0x0300646C` / `0x0300682C` is not established by this loader and is now explicitly downgraded as a likely false lead. See `docs/IWRAM_IMAGE_HYPOTHESIS_CHECK.md`.

Next: find a separate writer/copy loop for the upper IWRAM region and continue the renderer target trace.

## Completion estimate

**Overall traditional decompilation: approximately 15% (rough engineering estimate, not a line-count metric).** Boot path and several runtime subsystems are mapped, but gameplay states, audio, much of the asset/data semantics, many function bodies, and build/matching-ROM work remain. A reproducible build that matches the original ROM is **0% complete**: the current project is a research/source-reconstruction scaffold, not yet a full buildable matching decompilation. Keep this estimate conservative and revise it when whole subsystems or a verified build milestone are completed.

## 2026-10-09 — ARM rasterizer image semantic recovery

Re-disassembled the complete ARM-state image `0x080641B8–0x08064EDB` using ARM decoding (rather than Thumb). Recovered a conservative routine map for sample generation at `+0x000`, packed byte-sample generation at `+0x060`, a three-record primitive/edge processor at `+0x1AC`, an alternate edge path at `+0x434`, span clamping at `+0x56C`, row stepping at `+0x698`, and compact vertex/attribute processing at `+0x85C`. The row routine advances output by `0x40` bytes per row; the sample routine packs four byte samples per word; the edge processor consumes records at `0x10`-byte stride and uses fixed-point slope/table operations. These findings establish that this is a software rasterization/primitive-processing subsystem. They do not establish that it supplies the separate IWRAM targets `0x0300646C` / `0x0300682C`.

Added `docs/ARM_RASTERIZER_FINDINGS.md` and `asm/runtime/arm_rasterizer_641b8_64edc.dis.txt`. Next: isolate the remaining entry points from the relocation table and trace descriptor producers/callers.

## Completion estimate update

Overall traditional decompilation estimate remains conservative at **17%**. The ARM rendering module is now semantically mapped beyond a generic relocatable image, but gameplay state logic, audio, broad data classification, a complete build system, and matching-ROM verification remain substantial unfinished work. Matching-ROM build milestone remains **0%**.

## 2026-10-09 — ARM rasterizer copy helper reconstructed in C

Isolated the function entry at `0x08064E54` (the preceding `0x08064E50` word is zero/padding) and translated its gather-copy behavior into `src/arm_rasterizer.c`. Each output block contains eight 8-byte slices gathered from source rows separated by `r1` stride; the routine advances through 8-column groups and applies a `stride * 8 - 64` correction after each eight chunks. This is consistent with tile/swizzle preparation, but the caller's data format is not yet established. Added `docs/ARM_RASTERIZER_COPY_HELPER.md`, corrected the function map, and updated the rasterizer notes.

## Completion estimate update

Overall traditional decompilation estimate: **18%**. This pass converted a previously documented ARM helper into a C source reconstruction and clarified its exact entry boundary. The build/matching-ROM milestone remains **0%**; the project is still not a complete matching decompilation.

## 2026-10-10 — ARM rasterizer list processing recovered

Translated three ARM entries into source: `0x08064C38` as
`ArmRaster_InsertBucketItem`, `0x08064C8C` as `ArmRaster_BuildEdgeBuckets`,
and `0x08064DE0` as `ArmRaster_ProcessEdgeBuckets`. The insertion routine
creates/appends four-byte linked-list nodes with a signed-halfword sentinel;
the builder handles selected/default primitive ranges, applies a signed
orientation test, derives a 32-level bucket from fixed-point attributes, and
inserts accepted record indices; the dispatcher follows bucket chains,
resolves primitive records, invokes primitive-edge processing, and conditionally
dispatches row drawing. Added `docs/ARM_RASTERIZER_LISTS.md` and updated the function map.

Added a compile-only Makefile that builds all C translation units for ARM7TDMI,
using ARM state for the rasterizer image source and Thumb state for the other
units. This is a reproducible source-compilation milestone, not a ROM link or
matching build. Remaining work includes validating the rasterizer builder against a reference
emulator or disassembly-level test, recovering the rasterizer's caller and
descriptors, and replacing many unresolved runtime/gameplay functions.

## Completion estimate update — 2026-10-10

Overall traditional decompilation: **22%** (rough engineering estimate).
This pass adds source reconstructions for a linked-list primitive, its
primitive-bucket builder, and its bucket-chain dispatcher, plus a repeatable
ARM7TDMI compile-only target. The
matching-ROM build remains **0%**; compile-only object output must not be
mistaken for a linkable game or a byte-matching ROM.


## 2026-10-10 — relocatable ARM image loader recovered

Translated `0x0805EFC0` into `src/arm_rasterizer_loader.c`. The function either
allocates a `0xD24` heap descriptor and programs DMA3 to copy the ARM image, or
reuses an existing descriptor passed indirectly. It then rebases the specific
pointer fields selected by the table at `0x08064EDC`, leaving context offsets
`+0x40`, `+0x50`, and `+0x54` untouched. The loader's field-by-field map is
recorded in `docs/ARM_RASTERIZER_LOADER.md`, and startup now calls the recovered
working name rather than `sub_0805EFC0`.

The source compile target now covers 25 C translation units without compiler
warnings. This remains object compilation only; the heap allocator is still
incomplete, the project is not linkable as a game, and matching-ROM progress
remains 0%.

## Completion estimate update — 2026-10-10

Overall traditional decompilation: **24%** (rough engineering estimate). The
loader and three of its rasterizer support routines now have source-level
reconstructions, and all 25 current C units compile for ARM7TDMI. The matching-
ROM build remains **0%**.

## 2026-10-10 — dual-heap allocator reconstruction

Recovered both descriptor-backed allocator configurations from the `0x0805A3CC–0x0805A608` cluster. The main heap uses 32 descriptors from `0x02000000` and an IWRAM arena at `0x03001160` of size `0x4B20`; the alternate heap uses 32 descriptors from `0x02000200` and an EWRAM arena beginning at `0x02000400` with size `0x3FC00`. Reconstructed first-fit-by-address-gap insertion, descriptor-slot search, list unlink, and allocation counters.

A caller audit found an important representation error: both allocator front-ends return descriptor pointers, not payload pointers. Corrected `src/object_record.c` and `src/child_queue.c` to use descriptor `+0x00` for the payload while retaining the descriptor where the original structure expects it. See `docs/HEAP_FINDINGS.md` for addresses, layouts, and confidence boundaries.

Validation: clean ARM7TDMI object compilation of all 25 C source files, with no compiler warnings. This remains compile-only validation, not a matching-ROM build.

### Runtime-entry indexed initializer correction

Re-read `0x08062974` instruction-by-instruction. Its index is a signed halfword at `secondary_table + 0`, used to select a 32-bit value from `source_table`; the entry's `+0x08` field is loaded from the first word of the table rooted at `0x03000D98`. Corrected `RuntimeEntry_InitIndexed` accordingly. The previous C draft incorrectly treated the secondary-table pointer itself as an index into `0x03000D98`, which could select the wrong resource value.

## Pass 10 — object-table allocation correction (2026-10-10)

Rechecked `0x08062370` and `0x08062490` directly against Thumb instructions.
The helper at `0x080661E4` is an unsigned division routine, not an allocator.
The object-table initializer now computes the aligned quotient
`round_up(base / 0x28, 0x10)`, stores its positive and negative halfword forms,
and allocates `3*n + 40*count` bytes through `Heap_Alloc`. The auxiliary
`0x440`-byte block is allocated through `Heap_AllocAlt`. Both returned values
are heap descriptors; payload addresses are read from descriptor offset zero.

Also implemented the observed cleanup path at `0x08062370`: it stops the
associated hardware registers, frees the stored descriptors (not payload
pointers), and clears the corresponding runtime pointer globals. Full evidence
and remaining semantic uncertainty are in `docs/PASS10_OBJECT_TABLE_FIX.md`.

## Pass 11 — runtime record allocation recovered (2026-10-10)

Translated `0x0805AC4C` into `src/runtime_record.c`. The routine allocates a
0x10-byte alternate-heap record, dereferences the heap descriptor to get its
payload, then writes the four incoming values into fields at `+0x00`, `+0x04`,
`+0x08` (halfword), and `+0x0C`. Startup calls it with four zero arguments.
Also recovered the direct global setter at `0x0805AC80`, which stores a pointer
at `0x03005DC0`. Names remain neutral because the higher-level record purpose
is not yet proven. Evidence is in `docs/RUNTIME_RECORD_FINDINGS.md` and the
matching disassembly artifact.

Validation: source-level structure size is enforced with `_Static_assert`; a
clean ARM7TDMI object compilation is required before archiving. This pass adds
one compact but concrete runtime helper cluster. Matching-ROM build remains
0%.

## Completion estimate update

Overall traditional decompilation estimate: **31%**. This reflects one more
recovered runtime record allocator/setter and its exact field layout, not a
claim that 31% of ROM bytes are translated. Matching-ROM build remains **0%**.


## Pass 12 — surface/context constructor recovered (2026-10-10)

Replaced the `0x0805FEF4` interface stub with a field-by-field C reconstruction.
The routine allocates `0x44 + 2*width*height + 2*height` bytes from the alternate
heap, installs the payload at `0x03005DC4`, stores the descriptor pointer at
payload `+0x0C`, initializes observed fields and region pointers through `+0x40`,
computes the `+0x10` interval value using the internal division helper, and
reproduces the halfword writes at `0x04000134` and `0x04000128`. Exact graphics
semantics and peripheral register roles remain open. Evidence: `docs/SURFACE_CONTEXT_FINDINGS.md`.

## Pass 12 validation and completion estimate — 2026-10-10

The surface/context constructor is now source-level rather than a declaration-only
stub. Its function-specific disassembly is retained separately, the C structure
has compile-time offset/size assertions, and the entire 26-unit source set passes
ARM7TDMI compile-only validation with `-Wall -Wextra` and no warnings.

Overall traditional decompilation estimate: **32%**. This pass recovers one
medium-sized constructor and its memory/register contract; it does not yet
provide a linkable game or matching ROM. Matching-ROM build remains **0%**.

## 2026-10-10 — runtime-entry service pass

Recovered the per-entry service path at `0x080627CC` into `src/runtime_entry_service.c`: status gating, resource-record boundary calculations, terminal-status clearing, and the cursor-delta helper call are represented explicitly. Also corrected `FrameEvent_Service` to use the actual gate globals at `0x03005E1C` and `0x03005E44`, iterate the 0x28-byte runtime-entry table rooted at `0x03005E24`, and preserve the still-unresolved timing/transfer tail behind a clearly named helper. Added the matching disassembly and `docs/RUNTIME_ENTRY_SERVICE_FINDINGS.md`.

The helper at `0x0806625C` and the final timing/transfer tail remain unresolved. This pass increases the source-recovered surface but does not yet establish a matching-ROM build.

Current rough engineering estimate after this pass: **33% traditional decompilation**. This is a judgment-based estimate of recovered source/behavior, not a byte-count. Matching-ROM build remains **0% complete**.

### Runtime modulo helper resolved

Followed the call from `0x080627CC` into `0x0806625C`. Its behavior is unsigned remainder, including a zero-divisor path that returns zero. Added `src/math_runtime.c` with an equivalent shift/subtract implementation and replaced the provisional cursor-delta helper with `Math_ModuloUnsigned`. The relevant instructions are preserved in `asm/runtime/math_modulo_6625c.dis.txt`.

Current rough engineering estimate after the modulo-helper recovery: **34% traditional decompilation**. Matching-ROM build remains **0% complete**.

## Pass 13 — timer-window service and indirect callback ABI (2026-10-10)

Reconstructed the previously isolated tail of `0x08062814`. The routine samples
Timer0 at `0x04000100`, rounds its value to an even count, handles the wrap
sentinel, computes one or two elapsed segments, services the `0x28`-byte entry
pool, and dispatches segment callbacks through the pointer at `0x03000D8C`.
The second segment begins at `cursor - interval`; the final cursor is normalized
when it equals `context + interval`. The callback is kept neutral because its
higher-level role is not established.

A caller/callee ABI audit also corrected `RuntimeEntry_ServiceOne` at
`0x080627CC`: its caller passes `(entry, elapsed_window, threshold)` in `r0-r2`,
and the routine branches through the function pointer stored at ROM address
`0x0807D988` (currently `0x03006C60`). The previous source incorrectly treated
the ROM slot address as a context argument and used a four-argument helper.
The callback's IWRAM installation/source remains unresolved.

Added `docs/RUNTIME_ENTRY_TIMING_FINDINGS.md` and
`asm/runtime/runtime_entry_timing_627cc_62934.thumb.dis.txt`. Added host-side
exhaustive small-range and edge tests for `Math_ModuloUnsigned`; they pass.
The full 28-unit ARM7TDMI compile check also passes with no warnings.

Current rough engineering estimate: **35% traditional decompilation**. This is
an estimate of recovered source and behavior, not ROM-byte coverage. A linked
or matching-ROM build remains **0% complete**.

## Pass 14 — runtime script interpreter recovered (2026-10-10)

Translated the command loop at `0x08062C48` into `RuntimeScript_Service` in `src/runtime_script.c`.
Recovered its countdown pacing, 16-bit fixed-point delay commands, the `0x8`
entry-removal family, the `0x9` entry-creation family, `0xB0` saved-cursor jump,
`0xB1` skip, `0xB2` big-endian step update, `0xB3` error path, `0xC` source-record
selection, and `0xD` skip family. The script's 16 records are 0x24 bytes each;
each contains four 8-byte runtime-entry slots. The code uses existing entry
allocation/status/limit helpers rather than duplicating them.

Added `docs/RUNTIME_SCRIPT_FINDINGS.md` and the complete original instruction
region in `asm/runtime/runtime_script_62c48_62e74.thumb.dis.txt`. The C code
compiles cleanly, but the bytecode interpreter has not yet been exercised in a
GBA emulator, so runtime equivalence remains unverified.

Current rough engineering estimate: **38% traditional decompilation**. This is
an engineering estimate of recovered source and connected behavior, not a ROM
byte percentage. Matching-ROM build remains **0% complete**.

### Runtime script lifecycle controls

Continued through the adjacent routines at `0x08062B44`, `0x08062B50`, and
`0x08062BCC`. Added descriptor installation, stop/cleanup, and indexed start to
`src/runtime_script.c`. Start validates the index against descriptor offset
`+0`, loads two cursor words from its `+8` table, clears countdown/step state,
and enables the interpreter. Stop deactivates occupied script-owned entries
across the 16-record table before clearing the interpreter state. Original
instructions are retained in `asm/runtime/runtime_script_control_62b44_62c48.thumb.dis.txt`.

Updated estimate: **40% traditional decompilation**. The runtime script cluster
is now represented from descriptor setup and lifecycle through command
execution and per-frame timing integration. Emulator execution and matching-ROM
verification remain outstanding.

## Pass 15 — runtime buffer descriptor and row-copy path (2026-10-10)

Recovered `0x080631D4` and `0x08063210` into the new `src/runtime_buffer_descriptor.c`.
The constructor aligns its two dimension arguments down to even values, allocates
`2 * aligned_stride * row_count` bytes through the game's descriptor-returning
heap API, and stores both the heap descriptor and its payload address. The row
routine bounds-checks a signed row index, computes the source row using a
halfword stride, offsets the destination in halfword units, and dispatches the
copy through the callback slot at `0x0807D998` via the shared `bx r3` trampoline
at `0x08065C44`.

Added `docs/RUNTIME_BUFFER_DESCRIPTOR_FINDINGS.md` and preserved the exact
Thumb instructions in `asm/runtime/runtime_buffer_descriptor_631d4_63244.thumb.dis.txt`.
The concrete callback backend and broader semantic role of the descriptor are
still unknown; the source does not assign either one a guessed identity.

Validation: all 30 C translation units compile for ARM7TDMI without warnings;
`make test-all` passes the existing modulo and runtime-script host tests. These
checks do not establish emulator equivalence or a matching-ROM build.

Updated rough engineering estimate: **41% traditional decompilation**. The
matching-ROM build remains **0% complete**.

## Pass 16 — runtime block lookup helpers (2026-10-10)

Recovered three more routines from the 0xC4-stride runtime block manager into
`src/runtime_block_helpers.c`: the 256-slot free-descriptor scan at `0x08062FCC`,
the next-link tail walk at `0x0806307C`, and the bounds-checked payload-record
resolver at `0x080631B4`. Added field-layout assertions, an instruction dump, and
`docs/RUNTIME_BLOCK_HELPERS_FINDINGS.md`. The more complex insertion/release
routines remain evidence-backed disassembly rather than guessed C.

Validation: 31 C translation units compile for ARM7TDMI; existing host-side
modulo and script tests pass. The estimate is now **42% traditional
decompilation**; matching-ROM build remains **0% complete**.

## Pass 17 — runtime block allocator (`0x08062F20`)

Recovered the block-allocation front end into `src/runtime_block_allocate.c`.
It reserves an unused descriptor, appends allocations when the 0x100-slot
high-water limit permits, and delegates overflow/gap placement to the observed
`RuntimeBlock_Insert` routine. It records the payload address as the 0xC4-stride
pool base plus the selected slot offset and returns the descriptor, consistent
with the game's descriptor-based heap APIs. Added an instruction-level note in
`docs/RUNTIME_BLOCK_ALLOCATE_FINDINGS.md`.

Validation: all 32 C translation units compile for ARM7TDMI without warnings;
`make test-all` continues to pass. The gap insertion routine is still an
assembly-backed dependency, so full allocator runtime behavior is not yet
claimed as tested. Updated estimate: **43% traditional decompilation**; matching-
ROM build remains **0% complete**.


## Pass 18 — runtime block gap insertion (`0x08063090`)

Translated the linked-list insertion routine into `src/runtime_block_insert.c`.
It searches between adjacent occupied 0xC4-slot ranges, inserts a descriptor
when an interior gap is large enough, repairs both neighbor links, and returns
the first slot of the gap. It intentionally does not allocate at the head or tail;
those cases are handled (or rejected) by the original allocator's surrounding
logic. Added host tests for interior-gap placement, list-link updates, too-small
gaps, and the no-tail-gap behavior.

Validation: 33 C translation units compile for ARM7TDMI; `make test-all` passes
modulo, script-interpreter, and block-list tests. The release/destructor path is
still unresolved, and no ROM link/match has been achieved. Updated estimate: **45%
traditional decompilation**; matching-ROM build remains **0% complete**.

## Pass 19 — runtime block release (`0x08063004`)

Translated the release path into `src/runtime_block_free.c`. It calls the
existing child cleanup routine for each 0xC4-byte child, unlinks the block
record, preserves the observed high-water decrement and reset calls, and clears
only the payload field used by the free-descriptor scan. Added a findings note
that explicitly records the unusual global-update paths rather than silently
correcting them to a conventional linked-list allocator.

Validation: all 34 C translation units compile for ARM7TDMI without warnings;
`make test-all` passes. The block free path has compile validation only, not
emulator execution. Updated estimate: **46% traditional decompilation**; matching-
ROM build remains **0% complete**.

## Pass 20 — indexed table allocator and entry-status query (2026-10-10)

Recovered `0x08062C20` into `src/runtime_table_copy.c`: it checks the indexed
entry against the descriptor count, resolves the source pointer through the
`+0x0C` pointer table, and invokes the existing runtime-entry allocator. Also
added `RuntimeEntry_IsActive` for `0x08062E74`, preserving the behavior that any
nonzero status counts as active. Added separate findings notes and corrected the
function map to describe allocation rather than a generic copy operation.

Validation: all 35 C translation units compile for ARM7TDMI without warnings;
`make test-all` passes all current host tests. Updated estimate: **48% traditional
decompilation**; matching-ROM build remains **0% complete**.

## Pass 21 — child record cleanup (`0x080588CC`)

Recovered `ObjectChild_Cleanup` in `src/child_queue.c`, connecting the runtime
block release path to its actual per-child cleanup. It releases the resource
handle at `+0xB8` through the existing `0x08060AB8` boundary, frees the queue's
heap descriptor, and resets the queue state at `+0x74/+0x78/+0x7C`. Added
`docs/CHILD_CLEANUP_FINDINGS.md`; the resource-node unlink implementation itself
remains unresolved and is not guessed.

Validation: all 35 C translation units compile for ARM7TDMI without warnings;
all host tests pass. Updated estimate: **49% traditional decompilation**;
matching-ROM build remains **0% complete**.

## Pass 22 — resource-node unlink/recycle (`0x08060AB8`)

Recovered the previously external `ResourceNode_Unlink` boundary in
`src/resource_node.c`. The implementation now reproduces active-list unlinking,
free-list insertion, range-token release gating, auxiliary-node cleanup, the
recycle counter increment, and the post-operation active-list validation call.
Added field-offset assertions, `docs/RESOURCE_NODE_FINDINGS.md`, and an exact
Thumb disassembly artifact. Range-release and auxiliary-unlink helpers remain
explicit unresolved boundaries rather than guessed implementations.

Validation: all 36 C translation units compile for ARM7TDMI without warnings;
all existing host tests pass. The unlink routine is compile-validated but not
emulator-executed. Updated estimate: **50% traditional decompilation**;
matching-ROM build remains **0% complete**.

## Pass 23 — auxiliary resource-node unlink (`0x08060B5C`)

Recovered the auxiliary-node unlink/recycle helper as
`ResourceNode_UnlinkAuxiliary` in `src/resource_node.c`. It honors the state
byte at `+0x19`, repairs the active doubly linked list headed at `0x03005DF8`,
and pushes eligible nodes onto the free chain at `0x03005DE8`. This closes the
second list-management call made by `ResourceNode_Unlink`; auxiliary node
semantics remain intentionally neutral. Added a dedicated disassembly artifact
and findings note.

Validation: all 36 C translation units compile for ARM7TDMI; all current host
tests pass. Updated estimate: **51% traditional decompilation**; matching-ROM
build remains **0% complete**.

## Pass 24 — resource-node lifecycle execution tests (2026-10-11)

Added Linux simulated-IWRAM tests exercising the recovered primary and
auxiliary node unlink routines with original global RAM addresses. Four
scenarios pass: middle-node unlink with range release and auxiliary recycling,
head unlink with gated release, auxiliary tail unlink, and primary tail unlink.
The host harness stubs the two unresolved external dependencies. All 36 C
translation units still compile for ARM7TDMI and `make test-all` passes.
Completion estimate remains **51%** because this is validation, not additional
source coverage. Matching-ROM build remains **0%**.

## Range manager recovery — 2026-10-11

Reconstructed `0x0806082C` as `RuntimeRange_Release` in `src/runtime_range.c`. Confirmed IWRAM list roots at `0x03005DC8` and `0x03005DD8`, 8-byte nodes with two halfwords and next pointer, adjacent-range extension, sorted spare-node insertion, and second-pass coalescing/recycling. Preserved raw Thumb disassembly and documented remaining diagnostic-path caveat in `docs/RANGE_RELEASE_FINDINGS.md`. All 37 source files compile and existing host tests pass. Matching-ROM build still absent.

### 2026-10-11: Range-release behavioral tests
- Added `tests/test_runtime_range.c` (seven scenarios on mapped GBA IWRAM).
- Integrated `test-range` into `make test-all`.
- All five host-side test suites passed; 37 ARM7TDMI translation units compile.
- Estimate remains 52%; no matching-ROM build yet.

## 2026-10-11: range arena reset
Recovered ROM `0x08060958` into `src/runtime_range_init.c`, including object-token release, reserved range initialization, and 31-node spare chain. Added focused Thumb disassembly, findings, and a host test. 38 C translation units now compile and six host test suites pass. No matching ROM build yet.

## Range allocation recovery (2026-10-11)

Recovered ROM `0x080607B4` as `RuntimeRange_Alloc`, completing the currently identified range manager trio (reset, allocate, release) at source level. Added seven host-side scenarios and preserved Thumb disassembly. All 39 C translation units compile for ARM7TDMI and all seven host test suites pass. Matching-ROM build still unavailable. Overall recovery percentage remains a subjective estimate.

## 2026-10-11: resource-manifest original-ROM validation

Added `tools/verify_resource_manifest.py`, `tests/test_resource_manifest.py`, and `docs/RESOURCE_MANIFEST_VERIFICATION.md`. The tool checked 110 manifest records (108 primary + 2 alias-reachable) in the locally supplied original ROM, including table pointers, header sizes, aligned spans, and adjacent record boundaries. In-memory corruption tests for a size and pointer were detected. All 39 C units compiled and all existing host test suites passed. Completion estimate remains 54%: this is a verification improvement, not a newly recovered gameplay subsystem.

## 2026-10-11: full resource directory audit

- Verified all 32 directory slots, including repeated pointer-table aliases in slots 7–31.
- Confirmed all 110 manifested record headers use `{0, data_size, 0, 0}`.
- Identified unmanifested second pointer in slot 6 (`0x0821AAF4`), retained as an open question.
- Added `tools/audit_resource_directory.py` and corruption tests in `tests/test_resource_directory_audit.py`.
- This is a metadata/verification milestone, not new recovered gameplay C. Estimate remains 54%.

## 2026-10-11: alias-target record recovery

Confirmed the bank-6 second pointer at `0x0821AAF4` is a standard 16-byte-header record with 0x57 bytes of data; added it to the resource manifest. Identified both alias targets and their precise sizes: `0x0807DCA4` (0x40580 bytes) and `0x080BE234` (0x4D780 bytes), repeated through 25 directory slots. Added ROM-backed alias metadata validation and deliberate header-corruption tests. This is metadata recovery; 54% estimate unchanged.

## 2026-10-12: complete resource-pointer coverage

Cross-checked all 32 resource directory slots and all 134 pointer entries
against the 111 distinct records in the manifest. Fixed stale bank-6 sentinel
comments and unique-record counts in the C metadata and earlier findings.
Added `tools/check_resource_coverage.py` and mutation-based regression tests.
All 39 ARM7TDMI translation units compile and all existing host tests pass.
Source-recovery estimate remains 54%; matching-ROM build still unresolved.

## 2026-10-12: Resource reference trace

Added `tools/trace_resource_references.py` and three regression tests. Confirmed the sole aligned direct directory reference at `0x0804AF50`, recovered the two distinct alias-table addresses and their links to large resource records, and identified the bank-6 record reference at `0x08075200`. See `docs/RESOURCE_REFERENCE_TRACE.md`. No gameplay function has yet been reconstructed from this trace, so the source-recovery estimate remains 54%.

2026-10-12: Reconstructed ROM 0x0804AF08 resource directory selection in src/resource_directory_dispatch.c, preserving the literal-pool reference to 0x08075640 and tracing the two arguments to 0x080629B4. Saved exact disassembly and notes in docs/RESOURCE_DIRECTORY_CONSUMER.md. Source compilation verified; matching ROM not established. Discovered independent public matching-decomp project for cross-checking.

2026-10-12: Traced 0x0804AF08 -> 0x080629B4 -> 0x08062974. Corrected directory pair interpretation to (pointer-table base, signed-index descriptor), verified all 32 initial selections, added ROM-backed corruption tests and trace tool.

## 2026-10-12: Independent upstream fingerprint compatibility

Confirmed independent matching decomp uses US/EU/debug ROM hashes that do not
match the supplied 8 MiB ROM. Added reproducible SHA-1 checker and tests.
Do not claim byte-match equivalence or transplant upstream addresses without
ROM-level comparison. Source recovery estimate unchanged (54%).

2026-10-12: Added host-executable simulated-IWRAM regression tests for the
0x08062974/0x080629B4 runtime-entry indexed-selection path and entry lifecycle.
Verified selector resolution, field layout, serial handling, pool exhaustion,
status transitions and slot reuse. Fixed two host-compiler pointer conversions
via uintptr_t. All 40 ARM7TDMI units and full host suite pass; no matching ROM.
