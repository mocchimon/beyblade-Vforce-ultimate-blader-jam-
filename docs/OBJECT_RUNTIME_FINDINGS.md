# Object/runtime findings

## Runtime record manager at 0x08050388-0x080504E6

The initializer at `0x08050398` allocates `count * 0x18` bytes through the
alternate heap. The returned `0x10`-byte heap descriptor is stored at manager
`+0x00`; its payload address is loaded from descriptor `+0x00` and stored at
manager `+0x08`. The source descriptor is stored at `+0x04`.

The manager fields are:

- `+0x00`: alternate-heap allocation descriptor
- `+0x04`: source descriptor
- `+0x08`: allocated record payload pointer
- `+0x0C`: signed 16-bit record count copied from `[source + 0x08]`
- `+0x0E`: caller-provided 16-bit flags
- `+0x10`: boundary, initialized to zero
- `+0x14`: bounce scale, initialized to `0x80`

Each 0x18-byte record stores two positions at `+0x00/+0x04`, velocities at
`+0x08/+0x0C`, and accelerations at `+0x10/+0x14`. Initialization follows the
linked-list head at `[source + 0x00]`, copying each node's `+0x08/+0x0C` pair
and zeroing velocity and acceleration.

If the computed allocation size is zero, the routine calls `0x08057C5C` with
message `0x087270A4` and returns without changing the manager. If allocation
fails, it stores the null descriptor at manager `+0x00`, calls the same
return-only service with message `0x087270DC`, byte count, and source count,
then returns without writing the other fields. This explains why
`sub_08057C5C` needs a variadic C declaration: this call site uses one argument
on the zero-size path and three on allocation failure; the ROM entry saves
`r0-r3`, restores the stack pointer, and returns without inspecting them.

`0x08050420` integrates position and velocity and mirrors integrated positions
to the linked source nodes before optional boundary handling. Flag bit 0
selects the x axis (otherwise y); either bit in `flags & 3` enables the
boundary check. Flag bit 2 enables a velocity reversal scaled by manager
`+0x14` with an arithmetic shift by eight. Exact gameplay semantics remain
provisional.

## Object record at 0x08064FC0

The object initializer establishes a child array whose elements have a stride
of `0xC4`. Confirmed fields include:

- `+0x00`: child-array pointer
- `+0x04`: child count
- `+0x05`: mode/format byte
- `+0x06`: flags
- `+0x08`, `+0x0C`: cursor/limit-like values
- `+0x10`: mode/state pointer/value
- `+0x14`, `+0x18`: parameters
- `+0x24`, `+0x26`: dimensions initialized to `0x100`
- `+0x28`: callback/data pointer
- `+0x2C`: active/timing field

Each child has a confirmed activity field at `+0x70`.
`0x0806512C` counts children where this field is nonzero.

The object update routine at `0x08065164` dispatches based on bits in the
object flags and calls lower-level child-processing routines. Its exact
semantic role remains intentionally unnamed.

## Newly traced child processing

- `0x080656DC`: scans child mode bytes, marks selected children inactive, and
  clears the remaining child activity fields.
- `0x08065730`: processes all `0xC4` children through a common transform/copy
  helper while accumulating a returned quantity.
- `0x08065784`: bounded version of the same child-processing loop.
- `0x080657E8`: runs a common per-child service routine for every child.

These are kept neutral because the helper at `0x080587B8` still needs to be
resolved before assigning graphics/animation/gameplay semantics.

## Child queue confirmation

The child initializer at `0x08057C7C` explicitly establishes the queue state:
`+0x74 = -1`, `+0x78 = 0`, `+0x7C = 0`. This confirms that the sentinel is not
an inferred convention; it is written by the original initializer. On first
append, `0x080587B8` allocates `0x40` bytes and uses it as four `0x10`-byte
entries. `0x08058900` clears entry word 0 and resets `+0x74` without freeing the
allocation.
