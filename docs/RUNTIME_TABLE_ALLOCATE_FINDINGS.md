# Indexed runtime-table allocation (`0x08062C20`)

`src/runtime_table_copy.c` reconstructs the short helper at `0x08062C20`. It
loads the descriptor pointer at `0x03005E14`, compares the requested table index
against the count at descriptor offset `+0x04` using an unsigned bound check, reads the pointer
table at descriptor offset `+0x0C`, and calls `RuntimeEntry_Alloc` with the
selected source pointer and the caller-supplied entry index. The allocator's
returned serial is not consumed by this wrapper.

The function name describes the observed operation, not the table's game-facing
meaning. Its original Thumb instructions are included in
`asm/runtime/runtime_script_62c48_62e74.thumb.dis.txt`.
