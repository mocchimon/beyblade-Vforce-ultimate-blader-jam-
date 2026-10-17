# Development pass 24 — 2026-10-17

## Selection finalizer and resource chains

Recovered the ROM routine at `0x080614E0` as
`RuntimeObjectSelection_Finalize`. The dispatcher and its caller now expose
the second argument as a zero-terminated code-stream pointer. The finalizer
counts ordinary codes, grows the embedded resource chain, initializes each
ordinary entry using the ROM code map, applies the control nibble and packed
state bits, and carries code 32 as a cursor-reset marker. It then calls the
still-unresolved layout/context helper at `0x08061260`.

Also source-defined `ResourceNode_AllocateChain` (`0x08060C40`),
`ResourceNode_ResizeChain` (`0x08060DBC`), and
`RuntimeObjectSelection_CountEntries` (`0x08064F5C`). The allocator removes a
contiguous batch from the free list and inserts it into the ordered active
list; the resizer preserves, extends, or recreates the segment according to
the requested count.

Inspecting the linked release path corrected two Pass 23 source assumptions.
ROM `0x08060D00` writes zero to the chain count at `+0x08` together with head
and tail, and it leaves the context word at `+0x2C` unchanged. The C source,
resource-node harness, and Pass 23 report now reflect those stores.

## Verification

- **61 Python tests passed** with the supplied original ROM path configured;
  this includes ROM-backed metadata checks and mutation tests for the new
  verifier.
- The chain-operation verifier matched **228 Thumb halfwords**, **10 direct
  call targets**, and four ranges. The finalizer verifier matched **210
  halfwords**, **seven calls**, and **three literals**. The release-chain
  verifier matched **94 halfwords** and **five calls**. The related selection,
  dispatch, and resource-node verifiers also passed.
- Libclang parsed all **46 C source units** and **two changed C harnesses** for
  the ARM7TDMI target with zero diagnostics. This checks syntax only; it does
  not establish generated Thumb code or interworking behavior.

No C/ARM compiler, linker, or `make` is available on this host. No objects,
partial link, unresolved-object inventory, or candidate ROM were produced, and
the original GBA linker layout is still missing.

The project's historical overall completion estimate remains **approximately
54%**. That number has no defined denominator and is **not measured coverage**;
the measured ROM match remains **0%**. The halfword, call, and test counts above
describe only these checks and do not convert into an overall completion
percentage.
