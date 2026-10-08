# Resource/data recovery — continued

## `0x08075640` is a pointer-table directory

The 32 entries at `0x08075640` are 8-byte `[begin, end)` descriptors over
ROM-resident **32-bit pointer tables**. They are not direct `(blob_begin,
blob_end)` resource pairs. The first seven ranges are the primary resource
indices:

| Bank | Pointer-table range | Pointer count |
|---:|---|---:|
| 0 | `0x08074DDC..0x08074E1C` | 16 |
| 1 | `0x08074E7C..0x08074EC8` | 19 |
| 2 | `0x08074F3C..0x08074F88` | 19 |
| 3 | `0x08074FD4..0x08075008` | 13 |
| 4 | `0x08075044..0x080750C4` | 32 |
| 5 | `0x08075178..0x08075198` | 8 |
| 6 | `0x080751FC..0x08075204` | 2 (last word is the final end sentinel) |

This yields **108 primary resource records**. The final pointer in bank 6
is `0x0821AAF4`, exactly the end of the preceding blob, so it is a sentinel
rather than a second blob.

Entries 7–31 of the directory repeatedly reference two 4-byte singleton
ranges at `0x08074DCC..0x08074DD0` and `0x08074DD4..0x08074DD8`. Those ranges
contain `0x0807DCA4` and `0x080BE234`, respectively. They are best treated as
index aliases until their callers establish the higher-level meaning.

## Resource record header

All primary resource records begin with the same observed 16-byte runtime header:

```text
+0x00  u32  field_00 (zero in all mapped records)
+0x04  u32  data_size (length of inline data after the header)
+0x08  u32  field_08 (zero in all mapped records)
+0x0C  u32  source offset (zero in all mapped records)
+0x10  u8[] inline resource data
```

`0x08058ACC` consumes `+0x04` as a length, forms the source as
`base + source_offset`, and reads the first 32-bit word of inline data at
`base + 0x10`. The first resource-specific fields consumed by the child
initializer are at `+0x14`, `+0x18/+0x19`, `+0x1C`, and `+0x1E`.

The pointer tables advance by the aligned physical record size, not by
`data_size` alone:

```text
next = base + align4(0x10 + data_size)
```

For example, `0x0810B9C4` has `data_size = 0x1100`, giving a physical span of
`0x1110` and the next record at `0x0810CAD4`. An odd-sized record such as
`0x081319AC` has `data_size = 0x73D5`; `align4(0x10 + 0x73D5) = 0x73E8`,
which exactly matches the next record address `0x08138D94`.

The render path rooted at `0x08059334` uses child `+0x70` as its source base and
uses the child `+0x5F/+0x60` bit counts to derive dimensions. The recovered
layout selector therefore has strong graphics evidence: 5/6 bits correspond to
32/64-pixel dimensions, and returned sizes `0x800/0x1000/0x2000` equal
32x32/64x32-or-32x64/64x64 surfaces at 16 bits per pixel. The exact placement
of the resource metadata versus the surface data is still being traced rather
than assumed.

Record sizes are highly structured. Examples include `0x1100`, `0x2200`,
`0x1980`, `0x23A4`, `0x3EA4`, `0x7D49`, and `0x1275`.

## Runtime acquisition connection

`0x0804AF08` selects a directory entry, passes its two pointer-table addresses
to `0x080629B4`, stores the returned runtime serial at `0x03000FB0+0xC2C`,
and then calls `0x08062AF8` to update the entry limit.

The runtime entry initializer/search cluster establishes that a 0x28-byte
entry stores the selected source-table range at `+0x18` and `+0x20`. Thus the
resource directory is now connected to the runtime-entry system without
assuming that the blobs are directly decompressed at acquisition time.

## Data manifest

`data/resource_blob_manifest.inc` records the 108 primary record addresses,
bank/index, inline-data sizes, and aligned physical storage spans. It contains
**addresses and metadata only**; no copyrighted ROM bytes are copied into the project.
Two additional records are reachable through the repeated singleton aliases:
`0x0807DCA4` (size `0x40580`) and `0x080BE234` (size `0x4D780`).

The next target is to reconstruct the resource-specific subheader at `+0x10..+0x1F` and the exact 16-bit surface layout consumed by the render path.
