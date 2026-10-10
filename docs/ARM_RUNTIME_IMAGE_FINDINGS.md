# ARM-mode runtime image at ROM `0x080641B8`

## Confirmed ROM layout

The routine beginning at Thumb address `0x0805EFC0` computes the image length by subtracting `0x080641B8` from `0x08064EDC`:

- image source: `0x080641B8`
- image end / relocation-table start: `0x08064EDC`
- image size: `0xD24` bytes
- relocation/offset table begins immediately after the image at `0x08064EDC`

The first words at `0x080641B8` decode as ARM-state instructions, not Thumb instructions. The bytes therefore represent an ARM-mode code image (with any embedded data interspersed), and the routine's subsequent field construction is consistent with rebasing internal offsets relative to a loaded image.

The routine obtains a heap allocation descriptor and programs DMA3 using:

- source = `0x080641B8`
- destination = descriptor word `+0x00`
- transfer size = descriptor word `+0x04`
- control = `(size >> 2) | 0x84000000` (immediate DMA3, 32-bit units)

The allocator's block descriptor layout is already independently recovered as `{ address, size, prev, next }`; therefore this DMA sequence copies the image into the address/size represented by the allocated block descriptor. The actual destination value at runtime is not statically fixed by this call site alone.

## Relocation table evidence

The first entries at `0x08064EDC` are offsets such as `0x1AC`, `0x60`, `0x0A80`, `0x0AD4`, `0x0C98`, and `0x0C9C`, all within or at the boundary of the `0xD24` image. The loader adds the image base to selected table offsets and stores the resulting pointers into a runtime context. This is strong evidence for a relocatable ARM-mode runtime image rather than an ordinary resource blob.

## Connection to the unresolved IWRAM branch targets

The renderer's unresolved IWRAM targets have a striking offset relationship to this image:

| IWRAM target | If image base were `0x030061B8`, offset | Corresponding ROM address |
|---|---:|---|
| `0x0300646C` | `0x2B4` | `0x0806446C` |
| `0x0300682C` | `0x674` | `0x0806482C` |

Both corresponding ROM addresses fall inside the ARM-mode image. Disassembly at these addresses shows ARM instructions and they appear to be interior entry points rather than obvious function prologues. This is a valuable match hypothesis, but **the image's runtime destination has not yet been proven to be `0x030061B8`**. The routine traced at `0x0805EFC0` uses an allocator descriptor, so it must not be claimed as the IWRAM installer unless the descriptor destination is shown to equal that base.

## Next verification

1. Identify all callers/initializers that supply an image destination descriptor.
2. Search for another loader that copies the same `0xD24` source image directly to IWRAM base `0x030061B8` or an equivalent destination.
3. Confirm whether the two IWRAM entry addresses are reached at the same offsets after copying.
4. Only then name `0x0300646C` / `0x0300682C` as relocated entries into this image.

## Confidence

- **High:** ROM image range and exact size; ARM-state instruction encoding at the image start; relocation/offset table immediately follows; `0x0805EFC0` uses a block descriptor's address and size for DMA3.
- **Medium:** image is a relocatable runtime code module based on the offset rebasing behavior.
- **Unproven:** the image is copied to `0x030061B8` and directly supplies the two renderer targets.

## Follow-up: allocator-region check (2026-10-09)

The heap initializer at `0x0805A374` was re-disassembled. Its literal stores initialize the allocator's primary arena from `0x02000000` and nearby descriptor/arena boundaries at `0x02000200` and `0x02000400`. This supports the project's existing characterization of `Heap_Alloc` as an EWRAM allocator.

Consequently, the allocation made by `0x0805EFC0` for the `0xD24`-byte image is an EWRAM allocation under the normal initialized heap path. The image's bytes at ROM `0x0806446C` and `0x0806482C` therefore **must not be identified as the code installed at IWRAM `0x0300646C` / `0x0300682C` based only on the matching offsets**. That base-address hypothesis is currently disfavored, not confirmed. The module is still useful to reverse engineer on its own; its relocation behavior indicates a position-adjusted ARM-state runtime module, but its exact role remains to be named conservatively.

The unresolved IWRAM branch targets likely have a separate installation path or are established by a different runtime mechanism. Continue auditing writers/copy loops that can target the `0x03006xxx` and `0x03007xxx` range. Do not infer that the D24 image supplies those entries unless a separate copy or matching runtime bytes prove it.


## 2026-10-10 — loader translated to C

The complete entry at `0x0805EFC0` is now reconstructed in
`src/arm_rasterizer_loader.c` as `ArmRaster_LoadModule`. It either allocates a
`0xD24` heap block descriptor and DMA-copies the ARM image into the descriptor's
address, or reuses a descriptor pointer supplied indirectly by its second
argument. It then adds the loaded image base to selected entries from the
`0x08064EDC` offset table and stores the results into context offsets
`+0x04` through `+0x80`, preserving the three skipped relocation/context slots.
See `docs/ARM_RASTERIZER_LOADER.md` for the exact field map.

This translation improves the loader's source-level recovery but does not
resolve the separate IWRAM render targets, and it does not make the loader
runnable yet because the underlying heap allocator remains a partial stub.
