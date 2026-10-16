# IWRAM callback literal audit

A full-ROM little-endian literal search on the user's 8 MiB `BEYP` revision 0
image yields the following unique occurrences:

| IWRAM address | ROM literal site | Known role |
| --- | --- | --- |
| `0x03006C60` | `0x0807D988` | runtime-entry refresh dispatch |
| `0x0300646C` | `0x0807D968` | render callback A |
| `0x0300682C` | `0x0807D96C` | render callback B |
| `0x0300717C` | `0x0807D920` | runtime configuration pointer (not established as code) |

This is **not** proof that these functions are absent from the ROM. Their code
may be stored as relocatable or compressed bytes, or synthesized/copied into
IWRAM by a loader that never embeds the final address as a literal. A raw
literal scan cannot identify that loader. The existing DMA copy at
`0x08057968` targets `0x03000FE0` and is not evidence for installing the
`0x03006xxx` callbacks. The ARM rasterizer module loaded into a heap buffer
must also not be conflated with these direct IWRAM targets.

To repeat the audit, supply your own original ROM:

```
python3 tools/audit_iwram_callbacks.py /path/to/original.gba
python3 tests/test_iwram_callbacks.py
```

The audit deliberately emits no copyrighted ROM bytes. Next investigation:
identify code/data relocation or decompression writers that can populate
`0x0300646C–0x03006C60`, using instruction-level analysis of loader routines,
not inferred address coincidences.
