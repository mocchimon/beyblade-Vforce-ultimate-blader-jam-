# Pass 55 — runtime-base initializer recovered from ROM evidence

## Objective

Resolve the source of the shared runtime-base pointer at `0x03000F48`, which is
used by the input helpers examined in Passes 51–54.

## Result

The routine beginning at `0x08051090` is now identified as a runtime-context
allocation and initialization routine, provisionally named
`RuntimeContext_AllocateAndSeed`. It calls the existing alternate-heap entry
`Heap_AllocAlt` at `0x0805A444` with a requested size of `0xC6C` bytes.

On the successful-allocation path, the allocator returns a descriptor pointer
in `r0`. The routine reads the descriptor's first word (the payload base) and
stores that payload address in the global slot `0x03000F48`. This proves the
slot's normal-path initializer; it is not merely a candidate store pattern.

## Verified stores relative to the allocated payload base

| Payload offset | Operation | Evidence |
|---:|---|---|
| `+0x000` | clear one byte | `STRB r4, [r1]`, with `r4 = 0` |
| `+0x002` | clear one byte | `STRB r4, [r2, #2]` |
| `+0x6AC` | clear halfword | `STRH r4, [r0]`, with `r4 = 0` |
| `+0x6AE` | clear halfword | second adjacent `STRH` after adding 2 |
| `+0x6B0` | store allocator descriptor pointer | `STR r4, [payload + 0x6B0]` |
| `+0x6B4` | write word `1` | `STR r0, [payload + 0x6B4]` |
| `+0x6E4` | write halfword `0x00FF` | literal offset plus `MOVS r0, #0xFF` |
| `+0x6E6` | write halfword `0x0080` | literal offset plus `MOVS r0, #0x80` |
| `+0xC64` | clear word | `STR r4, [payload + 0xC64]` |
| `+0xC68` | clear word | `STR r4, [payload + 0xC68]` |

The allocation size `0xC6C` includes the final word at `+0xC68`. The offset
`+0x6B0` holds the descriptor pointer, while `0x03000F48` holds the payload
base; those are distinct pointers and must not be conflated.

After these writes, the routine calls `0x08051120`, a larger follow-on
initializer. This pass does not claim to have recovered that whole function or
the semantic names of the context fields.

## Failure-path correction

The branch at `0x0805109E` skips a diagnostic call when the allocation result is
nonzero. If it is zero, the routine calls `0x08057C5C` with a diagnostic literal
and the requested size, then proceeds to dereference `r4` at `0x080510AA`.
The stub at `0x08057C5C` is encoded as `PUSH {r0-r3}; ADD SP, #0x10; BX LR`,
which returns without terminating. Therefore the zero-allocation path is not
shown to be safely handled; do not describe the diagnostic as a fatal abort.

## Reproducibility

- `asm/runtime/runtime_context_init_51090_pass55.thumb.s` preserves the bounded Thumb capture and verified literal pool.
- `tools/audit_runtime_context_init_pass55.py` checks 50 instruction halfwords
  and nine literal words against the supplied ROM.
- `docs/runtime_context_init_pass55.json` records the ROM SHA-256 and findings.
- `tests/test_runtime_context_init_pass55.py` covers literal reads, the
  expected evidence counts, mismatch detection, invalid ROM length, and bounds.
- Run `make audit-runtime-context-init-pass55 ROM=/path/to/original.gba` to
  regenerate the ROM-backed report.

The supplied ROM is 8 MiB and matches the known reference SHA-256. This is a
bounded instruction/literal audit, not proof of a byte-matching build. No Easter
egg or secret input sequence is identified by this pass.
