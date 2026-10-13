# Runtime-entry status query (`0x08062E74`)

The function at `0x08062E74` calls `RuntimeEntry_Find` using the supplied serial.
It returns zero when no matching active entry is found or when the matched
entry's status byte at `+0x16` is zero; otherwise it returns one. This is a
boolean status query, not a test for one particular nonzero state value.
The instruction sequence is preserved at the beginning of
`asm/runtime/runtime_entry_service_627cc_62814.dis.txt` and the surrounding
runtime-entry disassembly.
