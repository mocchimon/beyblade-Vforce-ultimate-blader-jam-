# Resource-node unlink / recycle (`0x08060AB8`)

The child cleanup path calls `0x08060AB8` with the resource-node handle stored at
child offset `+0xB8`. The function is now reconstructed as `ResourceNode_Unlink`
in `src/resource_node.c`.

## Observed node fields

- `+0x00`: previous active-list node.
- `+0x04`: next active-list node; reused as the free-list next pointer after unlink.
- `+0x16`: range class used to derive a one-bit release mask (`class - 5`).
- `+0x20`: low flag bit suppresses the range-release call when set.
- `+0x24`: signed range token; nonnegative tokens are released then changed to `-1`.
- `+0x30`: optional auxiliary node/handle passed to `0x08060B5C`, then cleared.

## Global state

- `0x03005DE4`: active-list head.
- `0x03005DEC`: free-list head.
- `0x03005DF4`: counter incremented during recycling.

## Recovered sequence

1. If `+0x24` is nonnegative, call `0x0806082C` with the token and mask `1 << (+0x16 - 5)` unless flag bit zero is set; then store `-1` at `+0x24`.
2. Unlink from the doubly linked active list, repairing the predecessor or active head and the successor's previous pointer.
3. Push the node onto the free chain through `+0x04` and update the free-list head.
4. If `+0x30` is nonzero, call `0x08060B5C` and clear the field.
5. Increment `0x03005DF4` and pass the active-list head to `0x080604F8`, which traverses/checks list-link consistency and invokes the fatal handler on mismatch.

The C implementation reproduces the observed shift behavior for out-of-range shift counts (the mask becomes zero for counts >=32) rather than invoking undefined C shifts.

## Confidence / remaining work

The list-link updates, fields, globals, call order, and counter update are directly supported by Thumb instructions. The semantic names of the range-release and auxiliary unlink operations remain provisional; those are kept as explicit external boundaries. This routine has compile validation, but not yet an emulator-level execution test.
