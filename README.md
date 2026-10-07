# Beyblade V-Force: Ultimate Blader Jam — decompilation

This repository is a source-reconstruction project for the GBA version of
Beyblade V-Force: Ultimate Blader Jam.

The original ROM is intentionally **not included**. A local, legally obtained
copy is required for matching/verification.

## Current state

The boot/relocation path and high-level Thumb entry have been mapped. The
current pass is recovering the game's low-level runtime systems, including its
EWRAM free-list allocator, runtime pools, controller state, and resource
initialization.

The source names are semantic reconstruction names, not claims about the
original developers' symbol names.

## Current state

Pass 4 adds the first recovered resource-table/runtime-memory structures and
keeps their semantics conservative until their callers/callees are resolved.
No original ROM is distributed by this project.


## Current state

Pass 5 extends the call graph into the persistent frame loop and deferred-control/event subsystem. See `docs/PASS5_FINDINGS.md` and `asm/pass5/`. The project contains no original ROM.
