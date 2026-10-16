# Three small Thumb routines recovered (BEYP revision 0)

Instruction-byte verified against the user's 8 MiB original ROM:

| Thumb entry | Opcode sequence | Reconstructed behavior |
| --- | --- | --- |
| `0x08057B54` | `6001 6042 4770` | Write `r1` and `r2` as two consecutive 32-bit words to address `r0`; return |
| `0x08057C64` | `4801 6800 4770` | Read the 32-bit value at IWRAM `0x03000E30` (literal at `0x08057C6C`) |
| `0x08057C70` | `4801 8800 4770` | Read the 16-bit VCOUNT register at `0x04000006` (literal at `0x08057C78`) |

C semantics are verified on host using mapped surrogate IWRAM/IO pages. These functions are independently recovered; this does **not** establish how the unresolved IWRAM callbacks are installed. C compilation is not a byte-matching ROM build.
