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
5. Increment `0x03005DF4` and pass the active-list head to `0x080604F8`. `ResourceNode_ValidateActiveList` walks forward, checking that the head has no predecessor and that adjacent `+0x00`/`+0x04` links agree. On a mismatch it calls `0x08057C5C` with one of three ROM message pointers (`0x0875591C`, `0x08755938`, `0x08755954`); that recovered routine returns without observable effects, so traversal continues without repairing or terminating the list.

The C implementation reproduces the observed shift behavior for out-of-range shift counts (the mask becomes zero for counts >=32) rather than invoking undefined C shifts.

## Confidence / remaining work

The list-link updates, validation conditions, diagnostic pointers, fields, globals, call order, and counter update are directly supported by Thumb instructions. The higher-level domain meaning of range release and auxiliary unlink remains provisional, though both calls bind to recovered C implementations. The host harness includes valid-recycling and malformed-link cases, but those C runtime cases were not executed in this Windows environment and are not an emulator-level test.

## Counted chain allocation and resizing (`0x08060C40`, `0x08060DBC`)

`ResourceNode_AllocateChain` removes the requested contiguous batch from the
primary free chain, tags every node with the requested class, links the batch
into the class-ordered active list, and fills the context head, tail, and count.
Insufficient capacity reports the ROM diagnostic and returns null before list
mutation.

`ResourceNode_ResizeChain` returns the existing head for an equal count. It
allocates from an empty context, extends a nonempty segment immediately after
its old tail when growing, and releases/recreates the segment when shrinking.
An unsuccessful growth reports its diagnostic and leaves the active segment
unchanged. Class values on appended nodes are inherited from the existing
head; the class argument is used when the routine allocates a new segment.

The embedded context at `+0x00/+0x04/+0x08` holds head, tail, and count. ROM
`0x08060D00` clears all three after releasing a nonempty segment and leaves
`+0x2C` untouched. Pass 24 corrected the earlier C reconstruction and harness
after checking the stores at `0x08060D98–0x08060D9C`; preserving `+0x2C` matters
because the selection finalizer reads that context value after reset.
ROM verification and synthetic source checks are available through
`make verify-resource-node-chain-ops ROM=...` and
`make test-resource-node-chain-ops`.
