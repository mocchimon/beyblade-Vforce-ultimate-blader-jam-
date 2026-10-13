# Runtime block allocator (`0x08062F20`)

The allocator is now reconstructed in `src/runtime_block_allocate.c`. It
returns a 0x14-byte descriptor, not the payload pointer. The descriptor's
payload field is calculated as `0x03005E68 + start_index * 0xC4`.

The routine first initializes the manager's list cursor and high-water state if
`0x03005E60` is null, checks the guard value at `0x03005E5C`, and obtains an
unused descriptor from `RuntimeBlock_FindFree`. If `high_water + slot_count`
fits within 0x100 slots, it appends the allocation and updates the tail at
`0x03005E58` and high-water mark at `0x03005E64`. Otherwise it delegates to
`RuntimeBlock_Insert` (`0x08063090`) to find and link a gap; a negative result
means allocation failure.

This reconstruction relies on the independently disassembled `RuntimeBlock_Insert`
for the gap path. The exact wider meaning of the guard at `0x03005E5C` remains
unclear; its original signed comparison against `0xFF` is preserved rather than
renamed as a definitive descriptor count.
