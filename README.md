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
