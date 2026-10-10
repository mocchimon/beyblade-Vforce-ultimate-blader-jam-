# ARM rasterizer module loader (`0x0805EFC0`)

## Recovered source

The entry at `0x0805EFC0` is reconstructed in `src/arm_rasterizer_loader.c` as
`ArmRaster_LoadModule`. The name reflects the contents of its image, whose
major routines perform fixed-point sample generation and primitive/row
rasterization; it is a working name rather than an original symbol.

The loader takes a runtime context and an optional pointer to an existing heap
block descriptor. When the second argument is null, it requests a `0xD24`-byte
block from the game's allocator and uses DMA3 to copy bytes from ROM
`0x080641B8` to the descriptor's `address` field, using the descriptor's `size`
field for the DMA transfer length. If the second argument is non-null, it reads
the descriptor pointer from that argument and skips the copy. In either case,
the descriptor pointer is stored at context offset `+0x00`.

## Pointer rebasing map

The routine then reads the 32-bit offset table beginning at `0x08064EDC` and
adds the allocated image base (`descriptor->address`) to selected entries. The
rebased addresses are written into the context at these offsets:

| Relocation-table byte offset | Context byte offset |
|---:|---:|
| `0x00`–`0x38`, step `0x04` | `0x04`–`0x3C`, step `0x04` |
| `0x40` | `0x44` |
| `0x44` | `0x48` |
| `0x48` | `0x4C` |
| `0x54`–`0x7C`, step `0x04` | `0x58`–`0x80`, step `0x04` |

The loader skips table bytes `0x3C`, `0x4C`, and `0x50`; correspondingly,
context offsets `0x40`, `0x50`, and `0x54` are not written by this loop. Some
relocation-table entries contain zero, and those are still rebased to the image
base rather than treated as null pointers. This detail is preserved by the C
implementation.

## Confidence and limitations

- **High confidence:** image base/size, DMA3 source/destination/length fields,
  the allocation-descriptor indirection, the table base, and the individual
  rebasing writes.
- **Medium confidence:** `ArmRaster_LoadModule` is a good semantic name based
  on the recovered image contents; original symbol names are unknown.
- **Unresolved:** the full allocator behavior is still incomplete in `heap.c`,
  so this source reconstruction cannot currently load the module in a running
  build. The compile-only Makefile verifies syntax/object generation, not game
  execution or matching-ROM output.
