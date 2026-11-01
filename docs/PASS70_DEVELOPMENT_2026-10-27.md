# Pass 70 — shared-state caller and display helper cross-reference

## New verified code paths

- At `0x080498FC`, the function passes `0x03000BE0` to `0x080508C8`, then reads a pointer at a **negative offset** from that base (literal `0xFFFFFB24`, i.e. `0x03000704`). This is distinct from the `0x03000BEC` flag pointer. It reads a word through that pointer, calculates a record stride of **132 bytes** (`(index*32+index)*4`), and reads a word at `0x0806A84C+0x78+index*132`. If nonzero it calls `0x08057A68`. A second lookup at `+0x7C` conditionally calls `0x08057A84`. These appear to be indexed callback or resource dispatch slots; their meanings are not confirmed.
- At `0x080508C8`, the helper copies two bytes from state base offsets `0` and `1` to IWRAM addresses `0x03000DE0` and `0x03000E3C` (literal values), combines halfwords at state offsets `+6` and `+8` into a halfword written to `0x04000000` (GBA DISPCNT), and clears the halfword at state offset `+4`.
- This shows the state base `0x03000BE0` also contains **video/display-control fields**. It does **not** identify the object at `[0x03000BEC]` or the setter of its `+0xEC` bit.

## Limits and next steps

This pass **did not locate** a writer of bit 0 at the object halfword `+0xEC`. The indexed dispatch through `0x0806A84C` and callers of the display helper merit separate investigation. No Easter egg confirmed.
