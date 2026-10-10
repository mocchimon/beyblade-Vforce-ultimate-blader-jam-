# Runtime record helper findings

## `0x0805AC4C` — `RuntimeRecord_Create`

The original Thumb routine calls `Heap_AllocAlt(0x10)`, dereferences the
returned descriptor's first word to obtain the payload address, and writes a
16-byte record:

| Offset | Width | Value |
|---|---:|---|
| `+0x00` | 32-bit | incoming `r0` |
| `+0x04` | 32-bit | incoming `r2` |
| `+0x08` | 16-bit | low halfword of incoming `r3` |
| `+0x0A` | — | untouched padding |
| `+0x0C` | 32-bit | incoming `r1` |

The call site at `0x080506E4` supplies four zero arguments during startup,
then invokes the BIOS division/modulo wrappers and clears a large hardware
memory region. This supports treating the allocated record as a runtime
context/configuration record, but does not establish its game-specific role.
The source deliberately preserves neutral field names.

The allocation-failure path calls the fatal-message helper with ROM string
pointer `0x0875536C`. The C reconstruction checks both the descriptor and the
payload address defensively; the original assumes the fatal helper does not
return on allocation failure.

## `0x0805AC80` — `RuntimeRecord_SetCurrent`

Stores its input pointer at `0x03005DC0`. This is a direct global setter; its
callers and the semantic identity of the global remain to be mapped.

## Evidence and confidence

- Exact instruction dump: `asm/runtime/runtime_record_5ab68_5acac.dis.txt`.
- Record size and field writes: high confidence.
- Game-specific record purpose: unresolved.
- This is source reconstruction, not proof of matching machine code.
