# Runtime block helper routines (`0x08062FCC–0x080631D4`)

Three small helpers in the 0xC4-stride runtime block manager now have C
reconstructions in `src/runtime_block_helpers.c`.

- `RuntimeBlock_FindFree` (`0x08062FCC`) scans at most 256 descriptors of
  0x14 bytes from the pool pointer at `0x03005E54`. The first descriptor whose
  payload field at `+0x08` is zero is returned. If none is free, the ROM calls
  the fatal/report routine with message pointer `0x08755EB0` and returns zero.
- `RuntimeBlock_FindTail` (`0x0806307C`) follows the `+0x10` links beginning at
  `0x03005E60` until the final descriptor is reached.
- `RuntimeBlock_Get` (`0x080631B4`) uses a signed comparison to reject indices greater than or equal to the
  descriptor's `+0x04` count; it does not explicitly reject negative indices. Otherwise it returns the
  payload base at `0x03005E68` plus `0xC4 * (descriptor.start_index + index)`.

The 0x14-byte descriptor layout is supported by the instruction-level field
accesses: start index at `+0x00`, count at `+0x04`, payload pointer at `+0x08`,
previous link at `+0x0C`, and next link at `+0x10`. The insertion path is now reconstructed separately in `src/runtime_block_insert.c`
and tested for gap placement and link consistency. The release path is still
retained as disassembly because its full list/high-water-mark interaction needs
additional behavioral validation.
