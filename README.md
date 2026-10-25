# Beyblade V-Force: Ultimate Blader Jam — decompilation

This repository is a source-reconstruction project for the GBA version of
Beyblade V-Force: Ultimate Blader Jam.

The original ROM is intentionally **not included**. A local, legally obtained
copy is required for matching/verification.

## Current state

### Latest analysis pass — Pass 59

Pass 59 maps the five-way switch-like dispatch at `0x08045A08`: it reads a selector at context offset `+0x4B4`, bounds-checks values 0–4, then jumps through a ROM table. Cases 0–2 write values 1 or 4 to runtime-base offset `+0x6B4` and select contexts `0x19` or `0x0F`; cases 3–4 select contexts `0x0C` and `0x28`. The meaning of these numeric states remains unknown. See `docs/PASS59_DEVELOPMENT_2026-10-25.md`. No Easter egg is claimed.

### Latest analysis pass — Pass 58

Pass 58 traces writes to runtime-context offset `+0x6B4`. Setter `0x080517BC` stores its argument at `*(u32 *)(*(u32 *)0x03000F48 + 0x6B4)`. Verified direct call paths at `0x08045A4A` and `0x08045A5C` write values 1 and 4 respectively (the latter has two incoming value paths). Their semantic meaning remains unknown; no Easter egg is claimed. See `docs/PASS58_DEVELOPMENT_2026-10-25.md`.

### Latest analysis pass — Pass 55

Pass 55 resolves the initializer for the shared runtime-base slot. The routine
at `0x08051090` calls `Heap_AllocAlt(0xC6C)`, stores the returned descriptor's
payload address at `0x03000F48`, keeps the descriptor pointer at payload offset
`+0x6B0`, seeds several verified fields (`+0x6B4`, `+0x6E4`, `+0x6E6`,
`+0xC64`, `+0xC68`), and calls the follow-on initializer at `0x08051120`. The
field names remain unknown and the zero-allocation path is not shown to be safe.
See `docs/PASS55_DEVELOPMENT_2026-10-25.md` and
`docs/runtime_context_init_pass55.json`. No Easter egg or secret input sequence
has been identified.

### Latest analysis pass — Pass 54

Pass 54 adds a bounded local control-flow audit for `sub_08051090` at
`0x08051090`. It resolves two calls and a conditional branch surrounding the
store candidate at `0x080510AC`, confirming that the branch at `0x0805109E`
skips a fallback call when the first callee returns nonzero. The slot store is
real, but the zero-return path and the source pointer's provenance remain
unresolved. See `docs/PASS54_DEVELOPMENT_2026-10-25.md` and
`docs/sub_08051090_control_flow_pass54.json`. No Easter egg has been confirmed.


### Latest analysis pass — Pass 53

Pass 53 adds `tools/audit_runtime_base_slot_writes.py` to search for a Thumb
`LDR literal` of the runtime-base slot address `0x03000F48` followed by a nearby
`STR` using that register as its base. On the supplied ROM, this finds one
encoding-level candidate: the address load at `0x080510A8` and store at
`0x080510AC`. The instruction at `0x080510AA` loads `r1` from `[r4, #0]`, and
`0x080510AC` stores `r1` through the slot-address register. This is a promising
slot-write candidate, but not yet a proven initializer: reachability, function
semantics, and the path that establishes `r4` still require control-flow review.
See `docs/PASS53_DEVELOPMENT_2026-10-25.md` and
`docs/runtime_base_slot_write_candidates_pass53.json`. No Easter egg or secret
input sequence has been identified.


### Latest analysis pass — Pass 52

Pass 52 adds `tools/audit_runtime_base_pointer.py` and a reproducible inventory of
90 encoding-level Thumb literal-load candidates referencing the shared runtime-base
slot at `0x03000F48`. The report preserves each raw instruction window and clearly
separates candidate matches from confirmed reachable code. It does not yet locate
the slot initializer or prove the effective runtime base. See
`docs/PASS52_DEVELOPMENT_2026-10-25.md` and
`docs/runtime_base_pointer_xrefs_pass52.json`. No Easter egg or secret-input
sequence has been identified.

### Latest analysis pass — Pass 51

Pass 51 corrects the input-mask helper interpretation around `0x080517A4`.
The ROM's Thumb literal loads use a runtime-base pointer at `0x03000F48` and
an offset of `0x6B4`; the adjacent setter at `0x080517BC` writes to the same
computed field. The literal at `0x080517B8` is not evidence of an overlapping
function entry. The C reconstruction now preserves the observed indirection.
No Easter egg or secret-input sequence has been identified. See
[`docs/PASS51_DEVELOPMENT_2026-10-25.md`](docs/PASS51_DEVELOPMENT_2026-10-25.md).


The boot/relocation path and high-level Thumb entry are mapped, and the project
now contains recovered source-oriented reconstructions for the GBA startup,
input/control, heap, runtime-entry/resource, object, child-record, timing and
frame-state layers. The object/runtime work has reached the 0xC4-byte child
records and their four-entry command/event queue.

The source names are semantic reconstruction names, not claims about the
original developers' symbol names. Unresolved behavior remains represented by
neutral names and raw Thumb slices under `asm/` rather than invented gameplay
semantics. The resource-data pass has now recovered the `0x08075640` resource
directory as pointer-table ranges and mapped 108 large resource blobs by ROM
address, payload size, and bank/index without copying ROM bytes into the repo.
See `docs/RESOURCE_DATA_FINDINGS.md` and `data/resource_blob_manifest.inc`.

The current validation path compiles all 62 C source files to ARM7TDMI object
files with Clang and runs the project's regression tests. This is compile/test
validation only; the source tree is not yet a linkable, matching-ROM build and
the original section layout/toolchain details remain unresolved.

Current rough overall decompilation estimate: **approximately 54%**. This is
an unchanged engineering estimate without a defined denominator, not measured
function, byte, or semantic coverage. A matching ROM build has not been
achieved (**0%**).

### Latest analysis pass — Pass 41

Pass 41 adds a ROM-backed range audit for the known `0xD24`-byte ARM runtime
image at `0x080641B8`. Under the still-unproven base hypothesis `0x030061B8`,
the renderer targets `0x0300646C` and `0x0300682C` fit inside the image, but the
background operation at `0x03006FAC` and runtime-copy callback at `0x03007034`
fall beyond its end by `0xD0` and `0x158` bytes. This rules out that particular
image/base explanation for the latter targets, not other loaders or images.
See [`docs/PASS41_DEVELOPMENT_2026-10-20.md`](docs/PASS41_DEVELOPMENT_2026-10-20.md).
Run `make audit-runtime-image-bounds ROM=/path/to/original.gba` and
`make test-runtime-image-bounds` to reproduce the analysis. No candidate ROM has
been produced; matching progress remains 0%.

### Latest source recovery — Pass 40

The shared callback slot at `0x0807D998` is now confirmed to contain the ARM
IWRAM target `0x03007034`. Two independent callers (`0x08063210` and
`0x0805B95C`) prepare the same `(source, destination, byte_count)` register
contract and dispatch through the `BX r3` trampoline at `0x08065C44`. This
supports a generic copy-like operation, but its installed implementation and
installer remain unresolved. `make verify-runtime-copy-callback ROM=...` checks
both call paths and the slot; see `docs/PASS40_DEVELOPMENT_2026-10-20.md`.

The 61 C units compile and the relocatable integration link succeeds, but no
candidate ROM has been built. The matching-ROM plan now records the exact
baseline and blockers: fixed section placement, original toolchain/codegen,
unrecovered code/data/assets, and ROM container fields. See
`docs/MATCHING_ROM_PLAN.md`.

### Latest source recovery — Pass 38

`0x0805B8E8` now builds the spline pointer cache inside a collision-data
record. It resolves three source-relative offsets, caps the signed source
count at 64 after the ROM's return-only diagnostic, fills the pointer list by
walking packed entries, and clears the observed state fields. Its lookup
helper at `0x0805DBA4` follows the per-entry byte stride. Whole-ROM aligned
Thumb-BL scanning found nine call sites to each recovered entry; their call
targets are preserved in the Pass 38 listing and checked against the supplied
ROM. The immediately following allocator/copy routine and its installed
callback at `0x0807D998` remain unresolved. See
`docs/PASS38_DEVELOPMENT_2026-10-17.md`.

### Source recovery — Pass 37

`0x0805B824` is now source-defined as `RuntimeDisplay_ProcessByteStream`,
which batches ordinary bytes into spans for `RuntimeDisplay_DrawGlyphSequence`
at `0x0805B440`. The ROM handles `0xFB` as a record `+0x0D` update, `0xFC` as
a flush followed by a record `+0x0C` update, line feed as a flush plus X reset
and Y step, and `0xFF` or a later NUL as a final flush and return. Bytes
`0xFD` and `0xFE` remain ordinary span bytes. The entry has no direct Thumb
`BL` caller, direct branch, or stored Thumb function pointer in the ROM scan;
its incoming dispatch is still unresolved. No language-specific names are
assigned to the two mutable record bytes. Pass 37's ROM check is recorded in
`docs/PASS37_DEVELOPMENT_2026-10-17.md`.

### Source recovery — Pass 36

`0x0805B440` is now source-defined as
`RuntimeDisplay_DrawGlyphSequence`. It reserves palette-tagged map entries,
uses the existing generic background-operation dispatch when new tiles are
allocated, resolves indexed bitmap data through the descriptor helper at
`0x0805B814`, and draws the 8x8 blocks through the recovered tile compositor
at `0x0805B2A4`. The routine returns the updated X coordinate. Its ROM check
matches 333 Thumb halfwords, 11 direct calls, 20 conditional and 3
unconditional branch targets, and 4 literal words across 8 ranges. The five
observed callers and descriptor lookup are included. The installed tile
initialization backend and meanings of control bytes remain unresolved.

### Pass 35 metric helper

`0x0805B400` is now source-defined as
`RuntimeDisplay_ComputeSequenceMetric`. It scans a byte sequence, handles a
space with metric 5, and uses the ROM table at `0x0807D9A4` for optional
per-byte adjustments. The caller's alignment-related use is ROM-verified;
table semantics remain provisional. Its mode-2 alignment uses a logical
half-metric shift. Pass 35 matches 51 Thumb halfwords, one direct call, six
branch destinations, and one table-pointer literal. The ROM-enabled suite and
all ARM7TDMI frontend parsing results are in
`docs/PASS35_DEVELOPMENT_2026-10-17.md`.

## Latest render recovery

The current snapshot includes the recovered `0x08059520` DMA3-backed 16-bit
VRAM transfer backend and its raw disassembly artifact. See
`docs/RENDER_DMA_FINDINGS.md` and `asm/runtime/render_dma3_59520.dis.txt`.

### Latest reverse-engineering update

The runtime pointer/configuration region around ROM address `0x0807D920` is now
being traced from its code references. It contains mixed runtime addresses,
Thumb pointers, constants, and lookup bytes rather than a single homogeneous
callback table. See `docs/RUNTIME_POINTER_TABLE_FINDINGS.md` for the confirmed
cross-reference and the unresolved initialization questions.


Latest runtime-table follow-up: `docs/RUNTIME_CONFIG_CONSUMER_FINDINGS.md`
documents the first concrete consumer of `0x0807D920` and the indirect branch
through `0x08065C38`. The alternate renderer pointer's initialization remains
unproven; `0x08059428` is still provisional.

Latest reverse-engineering correction: `0x0300646C` and `0x0300682C` are used as direct IWRAM code targets, not RAM variables containing function pointers. ROM words at `0x0807D968` and `0x0807D96C` supply those executable addresses. The code-install/copy path that populates those IWRAM regions is still unresolved. See `docs/IWRAM_TARGET_INSTALL_FINDINGS.md`.


Latest correction: render-dispatch evidence was rechecked against the ROM's actual Thumb instructions. `0x08059428` is no longer asserted to be the alternate backend; the unresolved targets are runtime addresses `0x0300646C` and `0x0300682C`. See `docs/RENDER_ALT_BACKEND_FINDINGS.md`.


Latest startup analysis: `0x08057968` installs a 0x104-byte block from ROM `0x08000168` to IWRAM `0x03000FE0` via immediate DMA3. This is confirmed but separate from the unresolved render callback slots at `0x0300646C` and `0x0300682C`; see `docs/IWRAM_INSTALL_FINDINGS.md`.

Latest instruction-level correction: `0x0300646C` and `0x0300682C` are direct IWRAM executable targets obtained by dereferencing ROM table words at `0x0807D968` and `0x0807D96C`. They are not RAM pointer slots. See `docs/IWRAM_TARGET_INSTALL_FINDINGS.md` and `asm/runtime/iwram_target_trace.s` for the trace. Their installed code/source remains unresolved.

Latest tracing note: the DMA3 setup at `0x0805EFF8` is inside startup routine `0x0805EFC0`, called from `0x08050644` with the main runtime context plus `0xBA0`. It is currently classified as context/table initialization; no copy into the unresolved IWRAM renderer targets has been proven. See `docs/IWRAM_COPY_SITE_AUDIT.md`.


Latest runtime-image finding: ROM `0x080641B8–0x08064EDC` is a `0xD24`-byte ARM-state code image followed by an offset/relocation table. A possible offset match links renderer IWRAM targets `0x0300646C` and `0x0300682C` to ROM addresses `0x0806446C` and `0x0806482C` if the runtime base is `0x030061B8`; the destination is not yet proven, so this remains a hypothesis. See `docs/ARM_RUNTIME_IMAGE_FINDINGS.md`.

### Latest reverse-engineering correction (2026-10-09)

The ARM-state image at `0x080641B8` is copied through the normal heap allocation path. The heap initializer points its primary arena into EWRAM (`0x02000000`), so the apparent offset match with IWRAM renderer targets is not proof of a shared image. The project records this as a rejected/unproven hypothesis in `docs/IWRAM_IMAGE_HYPOTHESIS_CHECK.md`; the actual IWRAM installer remains an open target.

### ARM rasterizer recovery

The ARM-state runtime image at `0x080641B8` is now mapped as a software rasterization/primitive-processing subsystem: fixed-point sample generation, packed byte output, three-record edge processing, span clamping, 64-byte row stepping, and vertex/attribute updates. See `docs/ARM_RASTERIZER_FINDINGS.md`; raw ARM disassembly is preserved in `asm/runtime/arm_rasterizer_641b8_64edc.dis.txt`. This is separate from the unresolved IWRAM render dispatch targets.

Historical estimate at this stage: **17%**. A build matching the original ROM
had not been achieved.

### Latest recovery: ARM rasterizer copy helper

The ARM image's helper at `0x08064E54` has now been reconstructed in C as
`ArmRaster_CopyEightRowSlices` (`src/arm_rasterizer.c`). It gathers eight
8-byte slices from source rows using a caller-supplied stride and emits each
64-byte block contiguously. Its precise graphics format remains under
investigation. See `docs/ARM_RASTERIZER_COPY_HELPER.md`.

Historical estimate at this stage: **18% overall decompilation**; a build
matching the original ROM remained **0% complete**.

### Compile recovered sources

Run `make check` with Clang installed to compile each current C translation
unit to ARM7TDMI object files. The rasterizer source is compiled in ARM state;
other units are compiled in Thumb state. This is deliberately a compile-only
target: unresolved original functions and the original linker/memory layout
mean it does **not** create a runnable or matching ROM. Rasterizer bucket-list
and edge-dispatch reconstructions are documented in
`docs/ARM_RASTERIZER_LISTS.md`.

Historical estimate at this stage: **24% overall decompilation**. A build
matching the original ROM remained **0% complete**.

The ARM image loader and relocation map are documented in `docs/ARM_RASTERIZER_LOADER.md`.

### Latest recovery: dual-heap allocator

The allocator cluster is now represented in C with both the IWRAM small-object heap and EWRAM large-buffer heap, including descriptor-pool search, address-sorted gap insertion, unlink/free, and allocation counters. Callers were audited and corrected to distinguish allocation descriptors from payload addresses. See [`docs/HEAP_FINDINGS.md`](docs/HEAP_FINDINGS.md). `make clean && make check` compiles all 29 C translation units for ARM7TDMI without warnings; it is not yet a linked or byte-matching ROM build.

Latest reverse-engineering correction: `docs/PASS10_OBJECT_TABLE_FIX.md`
records the instruction-checked object-table cleanup and allocation-size fix
for `0x08062370` / `0x08062490`.

### Latest recovery pass (2026-10-10)

`src/runtime_record.c` reconstructs the record allocation helper at
`0x0805AC4C` and the pointer setter at `0x0805AC80`. See
`docs/RUNTIME_RECORD_FINDINGS.md` and `asm/runtime/runtime_record_5ab68_5acac.dis.txt`.


### Latest recovery pass

`ResourceDescriptor_Init` at `0x0805FEF4` is no longer a stub: its alternate-heap
allocation, payload field writes, region pointers, division-derived value, and
peripheral register writes have been reconstructed. See
`docs/SURFACE_CONTEXT_FINDINGS.md` and `asm/runtime/surface_context_init_5fef4.thumb.dis.txt`.

### Runtime-entry service recovery (2026-10-10)

The per-entry service at `0x080627CC` is now represented in
`src/runtime_entry_service.c`, including the active-status gate, resource
boundary checks, terminal status clearing, and cursor-delta helper call. The
`0x08062814` service now uses its instruction-verified globals and iterates the
`0x28`-byte entry pool. Its timing-window and final transfer tail remain
unresolved; see `docs/RUNTIME_ENTRY_SERVICE_FINDINGS.md` and the preserved
Thumb disassembly in `asm/runtime/runtime_entry_service_627cc_62814.dis.txt`.

Current rough engineering estimate: **33% traditional decompilation**.
Matching-ROM build remains **0% complete**; `make check` is compile-only.

The cursor helper used by that path is now identified as unsigned modulo
(`0x0806625C`) and reconstructed in `src/math_runtime.c`; see
`docs/RUNTIME_ENTRY_SERVICE_FINDINGS.md` and
`asm/runtime/math_modulo_6625c.dis.txt`.

Current rough engineering estimate after the modulo-helper recovery: **34%**
traditional decompilation; matching-ROM build remains **0%** complete.

### Timer-window and callback recovery

The timer-window path at `0x08062814` is now reconstructed through Timer0
sampling, wrap handling, per-entry dispatch, split-segment callbacks, and ring
cursor normalization. The callback ABI at `0x080627CC` was corrected to use
three incoming arguments and the IWRAM callback pointer stored at `0x0807D988`.
See `docs/RUNTIME_ENTRY_TIMING_FINDINGS.md`. The IWRAM callback implementation
and matching-ROM build remain open.

Run `make test-math` for host-side tests of the unsigned modulo helper in
addition to `make check` for ARM7TDMI compile-only validation.

### Runtime bytecode interpreter

The service at `0x08062C48` is now represented in `src/runtime_script.c`, with
countdown pacing and several command families mapped to their observed memory
operations. See `docs/RUNTIME_SCRIPT_FINDINGS.md` and the preserved original
Thumb disassembly. It compiles, but has not yet been validated by replaying real
scripts under a GBA emulator.

The script cluster also includes descriptor installation, indexed start, and
stop/cleanup (`RuntimeScript_SetDescriptor`, `RuntimeScript_Start`, and
`RuntimeScript_Stop`), with source and instruction evidence in the runtime
script findings document.

Run `make test-all` to execute the host-side modulo and runtime-script behavior
tests. The script test uses a mapped RAM region and stubbed entry-manager calls;
it does not emulate the whole game or validate timing against the original ROM.

### Runtime buffer descriptor and row-copy path

`src/runtime_buffer_descriptor.c` reconstructs the descriptor constructor at
`0x080631D4` and the bounded row-copy dispatcher at `0x08063210`. The concrete
copy target is selected through the original callback slot at `0x0807D998`, so
this recovery intentionally leaves the backend unnamed. See
`docs/RUNTIME_BUFFER_DESCRIPTOR_FINDINGS.md` and the matching instruction dump.

### Runtime block helper routines

`src/runtime_block_helpers.c` now models the free-descriptor scan, linked-list
tail walk, and bounds-checked `0xC4`-stride child resolver used by the runtime
block manager. The insertion and release routines remain under analysis. See
`docs/RUNTIME_BLOCK_HELPERS_FINDINGS.md` for exact addresses and confidence
boundaries.

### Runtime block allocator

`src/runtime_block_allocate.c` reconstructs the allocation front end at
`0x08062F20`, including the high-water append path and delegation to the still
assembly-backed gap insertion routine. It returns the runtime block descriptor,
not its payload. See `docs/RUNTIME_BLOCK_ALLOCATE_FINDINGS.md`.

Run `make test-block` (also included in `make test-all`) to exercise the
reconstructed runtime block gap insertion on host-side linked records.

`src/runtime_block_free.c` reconstructs block release and child cleanup at
`0x08063004`; its branch-specific manager-global updates are documented in
`docs/RUNTIME_BLOCK_FREE_FINDINGS.md` and still need emulator validation.

The runtime-entry layer now also includes the indexed-table allocator wrapper
(`RuntimeTable_AllocateIndexed`) and boolean status query (`RuntimeEntry_IsActive`);
see `docs/RUNTIME_TABLE_ALLOCATE_FINDINGS.md` and
`docs/RUNTIME_ENTRY_STATUS_QUERY.md`.

`ObjectChild_Cleanup` now reconstructs the child teardown at `0x080588CC` and is
used by runtime block release. The nested resource-node unlink at `0x08060AB8`
remains an explicit unresolved boundary; see `docs/CHILD_CLEANUP_FINDINGS.md`.


### Resource-node lifecycle update

`ResourceNode_Unlink` at `0x08060AB8` is now reconstructed in `src/resource_node.c`, including active/free-list transitions, range-token handling, auxiliary-node cleanup, and list validation. See `docs/RESOURCE_NODE_FINDINGS.md`. Overall traditional decompilation estimate: 50%; no matching-ROM build has been achieved.

The auxiliary resource-node list helper at `0x08060B5C` is also reconstructed; see `docs/RESOURCE_NODE_AUX_FINDINGS.md`.

### Resource-node host validation (Linux)

`make test-resource-node` runs four lifecycle scenarios against the recovered
resource-node C using simulated GBA IWRAM mapped at `0x03000000`. The test
requires Linux `MAP_FIXED_NOREPLACE`; see
`docs/RESOURCE_NODE_TEST_FINDINGS.md`. `make test-all` includes it.

Range allocator at 0x080607B4 recovered in src/runtime_range_alloc.c; see docs/RUNTIME_RANGE_ALLOC_FINDINGS.md.

### Resource alias verification

With your original ROM locally available, run `make verify-alias-resources ROM=/path/to/game.gba` and `make test-alias-resources ROM=/path/to/game.gba`. These check the 25 repeated directory entries and the two large shared records without copying ROM data into the project. See `docs/RESOURCE_ALIAS_FINDINGS.md`.

### 2026-10-12 resource directory consumer

The direct ROM reference at 0x0804AF50 is now traced to the Thumb function at 0x0804AF08. See `docs/RESOURCE_DIRECTORY_CONSUMER.md` and `src/resource_directory_dispatch.c`. A separate public matching-decompilation project is identified there for future cross-checking; this project remains compile-only and does not claim matching output.

### CFG tracer follow-up (2026-10-15)

The bounded candidate CFG tracer now retains the not-taken path of conditional ARM
returns and conditional BX transfers. It stops conservatively at ARM LDR-to-PC,
ARM SWI, and Thumb high-register MOV-to-PC transfers rather than walking through
unknown jump destinations. Five synthetic regression cases cover these behaviors.
These are static-analysis safety improvements, **not** newly recovered gameplay
functions or ROM-matching evidence; estimated recovery remains 54%.

### Development pass 11 (2026-10-15)

The signed and unsigned division routines at `0x080660A8` and `0x080661E4` are
now represented in C, and the duplicate resource-directory selection entry
delegates to the full recovered runtime selector. `System_VBlankWait` now has
its direct BIOS wrapper. Two return-only external entries are documented and
implemented from their Thumb instructions. See `docs/MATH_DIVISION_FINDINGS.md`,
`docs/EXTERNAL_NOOP_FINDINGS.md`, and `docs/PASS11_DEVELOPMENT_2026-10-15.md`.

The historical 54% figure remains an estimate, not measured source or byte
coverage. The last measured linkage inventory is from the prior object build;
this pass could not regenerate ARM objects because no ARM C compiler or linker
is available in this environment. No candidate ROM was produced, and the
original ROM is not included in this archive.

### Development pass 16 (2026-10-16)

Corrected `0x08049268` to use the disassembly-confirmed context at
`0x03000650`, separate from the object pointer stored at `0x03000FB0`, and
renamed its source binding to `GameState_FramePrepare`. All 23 explicit stores
and the runtime-record clear call now match the saved Thumb listing. All 42 C
translation units parse with zero frontend errors and 34 Python regressions
pass. This is source-level recovery only; the rough overall estimate remains
~54%, and no object audit or ROM build was produced. Details:
`docs/PASS16_DEVELOPMENT_2026-10-16.md`.

### Development pass 17 (2026-10-16)

Recovered `ResourceNode_ValidateActiveList` at `0x080604F8`, including its
three ROM diagnostic pointers and forward/back-link checks, and removed its
external declaration. Added direct Thumb evidence and expanded the Linux host
harness with two malformed-list scenarios. Python recovery checks and the
ARM7TDMI frontend parse pass; the Linux-only C harness was not executed in this
Windows environment. This pass also replaced stale `FatalError` imports with
the observed return-only entries and preserved their one- or two-argument
ABIs. All 37 Python tests pass; the ROM verifier matches the validator's 32
halfwords, three diagnostic pointers, and three call targets. The ~54%
completion figure remains a rough, unchanged estimate, not measured coverage.
Run `make verify-resource-node-validator ROM=/path/to/game.gba` to repeat the
validator ROM check. See `docs/PASS17_DEVELOPMENT_2026-10-16.md`.

### Development pass 20 (2026-10-16)

Recovered `RuntimeObject_InitializeEntryTable` at `0x08050AA0` and the small
byte lookup helper at `0x08063AC4`. The ROM verifier matched 216 halfwords and
decoded 20 direct Thumb calls, including 12 callers of the new entry. All 44
Python tests passed and all 44 C translation units passed libclang syntax
parsing. The overall completion estimate remains roughly 54%; it is
unmeasured, not a coverage percentage. No partial link or ROM build was
produced: this host lacks `make` and ARM compiler/linker tools, and a GBA
linker layout has not been recovered. See
`docs/PASS20_DEVELOPMENT_2026-10-16.md`.

### Development pass 21 (2026-10-16)

Recovered the resource-node active-list insertion-point scan, free-node
acquisition, selection-entry field initialization, and the 0x30-byte
object-selection context initializer. At that time, three of the prior four
direct address-named callees had source definitions and `0x08061684` remained
unresolved. The ROM check matched 214 Thumb halfwords and seven direct calls,
47 Python unit cases passed, and all 44 C translation units passed libclang
syntax parsing. The historical **~54% completion figure remains a rough,
unmeasured estimate**. No partial link or candidate ROM was produced because
`make` and ARM code-generation tools are unavailable and the GBA link layout
has not been recovered. See `docs/PASS21_DEVELOPMENT_2026-10-16.md`.

### Development pass 22 (2026-10-16)

Recovered the `0x08061684` selection wrapper, its `0x0806124C` context reset,
and five packed-field helpers. The builder now calls the named wrapper. The
large finalizer at `0x080614E0` and embedded-subcontext release routine at
`0x08060D00` remain unresolved. ROM checks matched 60 Thumb halfwords across
seven ranges and decoded 10 direct calls. The added C source is configured for
Thumb state; no object-level ARM/Thumb linkage could be exercised because this
host has no compiler/linker or `make`. No candidate ROM was produced. The
full 52-test Python suite passed with the original ROM supplied, and libclang
parsed all 45 ARM7TDMI C units without diagnostics. The rough **~54%**
completion estimate is unchanged and is not measured coverage.
See `docs/PASS22_DEVELOPMENT_2026-10-16.md`.

### Development pass 23 (2026-10-17)

Recovered `ResourceNode_ReleaseChain` at `0x08060D00` and replaced the
selection reset's address-named import with the source function. The ROM check
matched 94 Thumb halfwords and five direct call targets. All 55 Python unit
tests passed with the local ROM supplied, along with five additional ROM-backed
checks. Libclang parsed all 45 source files and both updated C behavior
harnesses with zero diagnostics. The host has no C/ARM compiler, linker, or
`make`, so no ARM objects, link, or candidate ROM were produced. The remaining
selection gap is the finalizer at `0x080614E0`. The historical **~54%**
estimate remains unchanged and is not measured coverage; matching-ROM progress
remains **0%**. See `docs/PASS23_DEVELOPMENT_2026-10-17.md`.

### Development pass 24 (2026-10-17)

Recovered the resource-chain allocator/resizer, selection-stream counter, and
`RuntimeObjectSelection_Finalize` at `0x080614E0`. Corrected the earlier
resource-release implementation to clear its count, matching the ROM stores.
ROM checks matched 228 Thumb halfwords and 10 calls for chain operations, plus
210 halfwords, seven calls, and three literals for the finalizer. The release
routine clears its chain count but preserves context `+0x2C`. The ~54%
completion figure remains a rough, unmeasured estimate; matching-ROM progress
is 0%. See `docs/PASS24_DEVELOPMENT_2026-10-17.md`.

### Development pass 25 (2026-10-17)

Recovered the selection-chain layout routine at `0x08061260` and its flags
wrapper at `0x080614D4`. The pass also corrected the shared context field map:
flags are at `+0x08`, cursor at `+0x0A`, and extent at `+0x0C`, with both
fixed-point coordinate bases at `+0x00/+0x04`. ROM verification matched 320
halfwords and the wrapper's direct call. The rough ~54% estimate remains
unmeasured; matching-ROM progress is 0%. The host still cannot compile ARM
objects or link a candidate ROM. See
`docs/PASS25_DEVELOPMENT_2026-10-17.md`.


Pass 39 recovers the collision owned-segment initializer at `0x0805B95C`; see `docs/PASS39_DEVELOPMENT_2026-10-20.md`. Its instruction-level verifier is `make verify-collision-owned-segments ROM=/path/to/original.gba`, and its unit tests are available via `make test-collision-owned-segments`. The callback target installed at `0x0807D998` remains unresolved.

## Pass 42 update

Pass 42 adds a ROM-backed inventory for the mixed runtime pointer table around
`0x0807D920`, highlighting the cluster of IWRAM targets surrounding the shared
copy callback. Run `make audit-iwram-function-table ROM=/path/to/original.gba`
to emit a machine-readable report; run `make test-iwram-function-table` for the
focused regression tests. This is new linkage evidence, not a claimed callback
implementation or matching-ROM result.

## Pass 43 update

Pass 43 adds an evidence-preserving scan for Thumb literal-load references to
upper-IWRAM addresses and DMA3 registers. It does not claim to recover the
unresolved callback at `0x03007034`; see `docs/PASS43_DEVELOPMENT_2026-10-20.md`.

## Pass 44 — copy/decompression path inventory

Pass 44 adds `tools/audit_runtime_copy_paths.py` and the
`make audit-runtime-copy-paths ROM=...` target. The scan finds seven direct
Thumb BL calls in the main code region to the known CpuSet, LZ77, startup-IWRAM,
and DMA3 transfer helpers. It records raw instruction windows and deliberately
does not infer runtime destinations from register setup alone. See
`docs/PASS44_DEVELOPMENT_2026-10-20.md` and `RECOVERY_BACKLOG.md` for findings
and limitations. The callback at `0x03007034` remains unresolved; no matching
ROM has been produced.

### Latest analysis pass — Pass 45

Pass 45 adds `tools/audit_arm_runtime_module.py` and
`make audit-arm-runtime-module ROM=...` to verify the exact `0xD24`-byte ARM
module at `0x080641B8`, the adjacent 32-word offset table, and the 29 slots used
by the loader. It corroborates 12 named entry offsets and explicitly treats
`0xD24` as a one-past-end pointer. This is structural validation of the known
heap-loaded ARM module, not evidence that it supplies the unresolved upper-IWRAM
callbacks. Four new regression tests pass, the existing copy-path tests pass,
and all 61 C files compile in the current validation environment. A matching
ROM has still not been built or byte-compared. See
`docs/PASS45_DEVELOPMENT_2026-10-20.md`.

### Latest analysis pass — Pass 46

Pass 46 adds `tools/audit_startup_iwram_installer.py` to verify the exact Thumb
instruction and literal fingerprint at `0x08057968`. The routine programs DMA3
to copy from `0x08000168` to `0x03000FE0` and publishes the base at `0x03007FFC`;
this is separate from the later callback table in upper IWRAM, so the missing
installer remains unresolved. Four regression tests cover instruction and
literal corruption plus input validation. Run
`make audit-startup-iwram-installer ROM=...` and
`make test-startup-iwram-installer`. No source-built ROM has been generated;
byte-match progress remains 0% verified. See
`docs/PASS46_DEVELOPMENT_2026-10-20.md`.

### Latest source recovery — Pass 47

Pass 47 adds `RuntimeDisplay_ApplyAttributeMask` at `0x08059620`. It updates a
rectangular VRAM tile-map region by preserving each halfword's low 12 bits and
replacing the upper nibble, unless child `+0x64` bit 0 suppresses the operation.
The ROM verifier checks 85 Thumb halfwords, the mask literal, and five branch
targets. No direct Thumb BL callers were found, so dispatch remains unresolved.
See `docs/PASS47_DEVELOPMENT_2026-10-20.md`. This is source recovery only; no
candidate ROM has been generated and byte-match progress remains 0% verified.


### Latest analysis pass — Pass 49

Pass 49 adds a ROM-backed verifier for `0x08065994`, a guarded DMA3 halfword
transfer routine with `(source, destination, halfword count)` in `r0-r2`. It
also corrects DMA-register names in the IWRAM installer candidate scan and
adds the missing `DMA3CNT_H` address at `0x040000DE`. The corrected scan finds
24 literal candidates: 8 IWRAM address literals and 16 DMA-register literals.
The callback at `0x03007034` is still unresolved, and this pass does not claim
the DMA helper installs it. See `docs/PASS49_DEVELOPMENT_2026-10-24.md`.

### Latest analysis pass — Pass 50

Pass 50 adds `tools/audit_input_mask_callers.py` to fingerprint the routine at
`0x080517A4` and inventory raw Thumb BL-shaped references. It exposed a
mismatch between that ROM instruction sequence and the current `Input_TestMask`
C reconstruction, so the function's semantics are now explicitly marked for
re-investigation rather than silently treated as verified. The scan reports 47
candidate references, not 47 proven executed calls. No Easter egg has been
identified; this is groundwork for tracing the platformer's input path. See
`docs/PASS50_DEVELOPMENT_2026-10-25.md`.

### Pass 56 follow-on initializer audit

`make audit-runtime-context-followup-pass56 ROM=/path/to/original.gba` checks a bounded instruction/literal fingerprint at `0x08051120`. The audit confirms the earlier `+0x6B4 = 1` seed is overwritten by a zero store during follow-on initialization, and records two table-backed loops (56 records at stride `0xD0`; 10 entries at stride `0x50`). Unknown field and callback semantics remain unnamed. See `docs/PASS56_DEVELOPMENT_2026-10-25.md`.

Pass 57: helper `0x08051744` indexes 56 objects at runtime +4 (stride 0x18); `0x08051704` indexes 10 entries at +0x544 (stride 8). Indirect trampoline `0x08065C44` branches to a callback dynamically stored in RAM `0x03006FAC`; see `docs/PASS57_DEVELOPMENT_2026-10-25.md`.
