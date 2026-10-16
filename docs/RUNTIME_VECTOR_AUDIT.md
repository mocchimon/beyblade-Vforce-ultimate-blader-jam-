# Runtime vector at `0x0807D950` — ROM-verified inventory

The contiguous 80-byte region `0x0807D950–0x0807D99F` contains 20
32-bit address values. In this BEYP revision 0 ROM, **11** values are in
IWRAM (`0x03000000–0x03007FFF`) and **9** are odd Thumb ROM pointers.
The IWRAM values are all word-aligned, unlike the ROM Thumb pointers.

The 11 IWRAM targets in ascending order are:

`0x0300616C`, `0x0300646C`, `0x0300682C`, `0x03006940`,
`0x03006A20`, `0x03006B84`, `0x03006C60`, `0x03006F10`,
`0x03006FAC`, `0x03007034`, `0x030070B8`.

These are **addresses embedded in a ROM table**, not proof that 11
separate routines exist, that every address is executable, or that this
region contains an installation manifest. Known consumers of some
entries do use indirect branches, but each target needs its own
instruction-level evidence. The next pointer in the surrounding block,
`0x0300711C` at `0x0807D9A0`, is **outside** this 20-word audited
region; the boundary is an audit scope, not a proven structure boundary.

The table repeats the ROM Thumb pointer `0x08057C5D` four times and
`0x08057B65` twice. That makes it a useful starting point for tracing
shared handlers, but it does not establish the provenance of the IWRAM
code bytes. In particular, the missing IWRAM loader is still unknown.

Repeatable checks:

```
make audit-runtime-vector ROM=/path/to/original.gba
make test-runtime-vector ROM=/path/to/original.gba
```

The audit validates the exact 20 words and rejects wrong ROM identity,
wrong ROM length, and corrupted table values. No ROM bytes are packaged.
