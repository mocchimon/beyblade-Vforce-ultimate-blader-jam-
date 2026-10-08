# Recovered runtime cluster

This document records the next consolidated reverse-engineering layer.  The
assembly under `asm/runtime/` is authoritative; the C is a semantic
reconstruction and is not yet claimed to be byte-identical.

## Runtime entries

The pool at `0x03005E24` contains `0x28`-byte entries.  The count is read from
`0x03005E04`, and a serial counter is stored at `0x03005E9C`.

Recovered fields:

| Offset | Evidence |
|---|---|
| +0x00 | source/value pointer |
| +0x04 | source + 0x10 |
| +0x08 | value selected from `0x03000D98` |
| +0x0C | cleared/linked field |
| +0x10 | 16-bit limit, initialized to `0x100` |
| +0x14 | cleared halfword |
| +0x16 | status byte: 0, 1, 2 observed |
| +0x17 | cleared byte |
| +0x18 | serial/handle |
| +0x1C | auxiliary source/table pointer |
| +0x20 | auxiliary pointer |
| +0x24 | initialized to 1 by the indexed initializer |

`0x08062A74` searches active entries by the serial at `+0x18`.
`0x08062AB4`, `0x08062AC8`, `0x08062ADC`, `0x08062AF8`, and `0x08062B18`
operate on that entry.

## Resource table

`0x08075640` is an array of 8-byte pairs.  The first seven pairs point to
large ROM data structures; entries 7 onward repeatedly use two tiny shared
structures at `0x08074DCC`/`0x08074DD0` and `0x08074DD4`/`0x08074DD8`.
The first seven pairs are:

```text
0: 08074DDC, 08074E1C
1: 08074E7C, 08074EC8
2: 08074F3C, 08074F88
3: 08074FD4, 08075008
4: 08075044, 080750C4
5: 08075178, 08075198
6: 080751FC, 08075204
```

The table is therefore not a flat asset blob: the runtime code treats the
pair as a source structure plus a secondary indexed structure.

## Runtime allocator/manager

The `0x08062F20` cluster creates and links records using a `0xC4`-byte stride
pool.  `0x08062FCC` searches for an unused slot. `0x08063004` tears down a
manager record and walks its `0xC4`-byte children. `0x08063090` inserts a
record into a size-ordered linked list. The exact subsystem identity remains
unresolved, so these routines are deliberately kept neutral.

`0x080631D4` is a generic descriptor/buffer constructor: it aligns two size
arguments down to even values, allocates `2 * even_width * count` bytes, and
stores the resulting buffer plus dimensions/stride metadata.

`0x08063210` copies a selected row/plane from such a descriptor into another
buffer through the GBA copy helper at `0x08065C44`.

`0x08063244` is a larger transformation routine. It consumes descriptor
metadata and repacks six 5-bit channels from each 32-bit word, applying the
runtime factor in `r12`. Its final packed value is written through the
supplied output pointer. It is preserved as assembly pending identification
of the data format.

## Higher-level object manager

Callers at `0x08055118`/`0x080550DC` use the `0x080631D4` descriptor
constructor and the `0x08062F20` `0xC4`-stride block manager. The cluster at
`0x08064FC0–0x08065222` initializes and services a larger object containing
those child records. The object has recovered fields at `+0x04`, `+0x06`,
`+0x08`, `+0x0C`, `+0x10`, `+0x14`, `+0x18`, `+0x20`, `+0x24`, `+0x26`,
`+0x28`, and `+0x2C`; its child array begins at `+0x08` and uses the same
`0xC4` stride. The update path dispatches on flag bits in the halfword at
`+0x06`. This is a strong candidate for a reusable graphics/animation
object rather than a one-off gameplay structure, but the exact identity is
not yet proven.
