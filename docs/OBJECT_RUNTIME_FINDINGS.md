# Object/runtime findings

## Correction: 0x08050398 uses 0x18-byte records

The earlier reconstruction of `0x08050398` as a 0x1C-byte record allocator was
incorrect. Direct disassembly shows:

- source count = `[src + 0x08]`
- allocation size = `count * 0x18`
- destination record stride = `0x18`
- manager fields:
  - `+0x00` allocated record array
  - `+0x04` source descriptor
  - `+0x08` first word from allocated storage
  - `+0x0C` signed record count
  - `+0x0E` caller/requested value
  - `+0x10` cursor/state
  - `+0x14` capacity, initialized to `0x80`

Each 0x18-byte record is initialized from `src + 0x08`, `src + 0x0C`, and
zeroed state/step fields.

`0x08050420` then updates these records using the source flag field at `+0x0E`.
It maintains two coordinate-like pairs and advances each record by 0x18 bytes.
The exact game-level meaning is still unresolved.

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
