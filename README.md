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

Latest reverse-engineering note: the alternate renderer slot at `0x0300646C` is read through a mutable runtime global and dispatched via `bx r4`. A full aligned-word scan finds its address literal only in the mixed configuration block at `0x0807D968`, so the writer is likely reached through indirect/base-relative initialization rather than a direct literal load. See `docs/RUNTIME_CONFIG_CONSUMER_FINDINGS.md`.


Latest correction: render-dispatch evidence was rechecked against the ROM's actual Thumb instructions. `0x08059428` is no longer asserted to be the alternate backend; the unresolved targets are runtime addresses `0x0300646C` and `0x0300682C`. See `docs/RENDER_ALT_BACKEND_FINDINGS.md`.


Latest startup analysis: `0x08057968` installs a 0x104-byte block from ROM `0x08000168` to IWRAM `0x03000FE0` via immediate DMA3. This is confirmed but separate from the unresolved render callback slots at `0x0300646C` and `0x0300682C`; see `docs/IWRAM_INSTALL_FINDINGS.md`.
