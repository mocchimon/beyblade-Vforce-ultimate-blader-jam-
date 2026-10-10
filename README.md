# Beyblade V-Force: Ultimate Blader Jam — decompilation

This repository is a source-reconstruction project for the GBA version of
Beyblade V-Force: Ultimate Blader Jam.

The original ROM is intentionally **not included**. A local, legally obtained
copy is required for matching/verification.

## Current state

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

The C sources are checked for ARMv4T/Thumb freestanding syntax with clang. A
fully matching ROM build is not yet claimed; the next stage is continued call-
graph/data recovery followed by progressively replacing provisional helpers
with verified implementations.

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

Current rough overall traditional-decompilation estimate: **17%**. A reproducible build matching the original ROM is not yet achieved.

### Latest recovery: ARM rasterizer copy helper

The ARM image's helper at `0x08064E54` has now been reconstructed in C as
`ArmRaster_CopyEightRowSlices` (`src/arm_rasterizer.c`). It gathers eight
8-byte slices from source rows using a caller-supplied stride and emits each
64-byte block contiguously. Its precise graphics format remains under
investigation. See `docs/ARM_RASTERIZER_COPY_HELPER.md`.

Current rough engineering estimate: **18% overall decompilation**; matching-ROM
build remains **0% complete**.

### Compile recovered sources

Run `make check` with Clang installed to compile each current C translation
unit to ARM7TDMI object files. The rasterizer source is compiled in ARM state;
other units are compiled in Thumb state. This is deliberately a compile-only
target: unresolved original functions and the original linker/memory layout
mean it does **not** create a runnable or matching ROM. Rasterizer bucket-list
and edge-dispatch reconstructions are documented in
`docs/ARM_RASTERIZER_LISTS.md`.

Current rough overall traditional-decompilation estimate: **24%**. Matching-ROM
build remains **0% complete**.

The ARM image loader and relocation map are documented in `docs/ARM_RASTERIZER_LOADER.md`.

### Latest recovery: dual-heap allocator

The allocator cluster is now represented in C with both the IWRAM small-object heap and EWRAM large-buffer heap, including descriptor-pool search, address-sorted gap insertion, unlink/free, and allocation counters. Callers were audited and corrected to distinguish allocation descriptors from payload addresses. See [`docs/HEAP_FINDINGS.md`](docs/HEAP_FINDINGS.md). `make clean && make -j2` compiles all 25 C units for ARM7TDMI without warnings; it is not yet a linked or byte-matching ROM build.

Latest reverse-engineering correction: `docs/PASS10_OBJECT_TABLE_FIX.md`
records the instruction-checked object-table cleanup and allocation-size fix
for `0x08062370` / `0x08062490`.

### Latest recovery pass (2026-10-10)

`src/runtime_record.c` reconstructs the record allocation helper at
`0x0805AC4C` and the pointer setter at `0x0805AC80`. See
`docs/RUNTIME_RECORD_FINDINGS.md` and `asm/runtime/runtime_record_5ab68_5acac.dis.txt`.
