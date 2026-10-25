# Pass 57: runtime helper geometry and callback indirection

Verified against the original 8 MiB ROM SHA-256 `a8c64df585e2ed0da969b47af3369227f10ad08987cd91ba54cf7f9186fcb2ce`.

- `0x08051744`: returns `*(u32*)0x03000F48 + 4 + 24 * index`. This locates the 56 records initialized in Pass 56; object stride `0x18`.
- `0x08051704`: returns `*(u32*)0x03000F48 + 0x544 + 8 * index`. This locates the ten entries initialized in Pass 56; entry stride `8`.
- `0x08065C44`: a single `BX R3` instruction, a register-indirect branch trampoline. The call sites load `r3` from the word at ROM address `0x0807D994`, whose value is the RAM address `0x03006FAC`. Hence the callback target is *dynamically stored* at `0x03006FAC`, and the ROM literal is not itself the callback.
- `0x080517A4`: computes bitwise AND of its argument with the runtime-context word at `+0x6B4`. The Pass 56 follow-on initializer clears that word to zero; later updates remain to be traced.

The exact object types, dynamic callback target, and any hidden gameplay conditions remain unknown. Next: find writers to `0x03006FAC`, and find setters of `runtime_base + 0x6B4`.
