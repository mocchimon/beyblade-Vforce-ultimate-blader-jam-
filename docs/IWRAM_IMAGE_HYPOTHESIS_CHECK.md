# IWRAM image hypothesis check — 2026-10-09

## Question
Does the ARM-state image at ROM `0x080641B8` provide the code reached through IWRAM addresses `0x0300646C` and `0x0300682C`?

## New evidence

1. Loader `0x0805EFC0` requests a `0xD24`-byte allocation from `Heap_Alloc` and copies the image from `0x080641B8` to the address returned in the allocation descriptor.
2. Heap initializer `0x0805A374` sets the primary heap arena beginning at `0x02000000`, with nearby boundaries/descriptors at `0x02000200` and `0x02000400`. This is EWRAM, not IWRAM.
3. The target offsets `0x2B4` and `0x674` happen to land on ARM instructions at ROM `0x0806446C` and `0x0806482C`, but the traced loader does not install the image at `0x030061B8`.

## Conclusion

The offset correspondence is not sufficient evidence and should be treated as a false lead unless a separate installation path is found. The `0xD24` image is a relocatable ARM-state module loaded through the EWRAM allocator; its exact high-level role remains unresolved. The executable code at `0x0300646C`, `0x0300682C`, and other targets from the ROM table still needs a separate source/installer trace.

## Next actions

- Audit all direct writers and block-copy loops that can write to IWRAM addresses above `0x03006000`.
- Trace initialization of IWRAM memory around `0x03006000–0x03007FFF` and look for copy source/length pairs that overlap the target addresses.
- Keep the renderer backend labels unresolved until the installed code is recovered.
