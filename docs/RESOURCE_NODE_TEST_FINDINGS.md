# Resource-node lifecycle host tests — Pass 24 (2026-10-11)

This pass adds `tests/test_resource_node.c`, executing the reconstructed
`ResourceNode_Unlink` (`0x08060AB8`) and `ResourceNode_UnlinkAuxiliary`
(`0x08060B5C`) from `src/resource_node.c` on a Linux host.

The harness maps 64 KiB of host memory at `0x03000000` to represent the GBA's
IWRAM address range. The original version stubbed range release and active-list
validation; Pass17 below replaces the validator stub with the recovered C
helper.

Verified scenarios:

1. Primary middle-node unlink: previous/next repair, range-release mask,
   free-list push, auxiliary head unlink, counter and validator call.
2. Primary head-node unlink: new head and back-link, flag-gated suppression of
   range release, auxiliary state-byte suppression.
3. Auxiliary tail unlink: previous link repair and free-list push.
4. Primary tail unlink: last-node repair, free-list push, no release for a
   negative token.

Command: `make test-resource-node` or `make test-all`.

Constraints: this test requires Linux `mmap(MAP_FIXED_NOREPLACE)` support and
an available `0x03000000` virtual address range; it is a host behavior test,
not a GBA emulator run or byte-matching ROM build. It does not validate the
unresolved external range-release implementation.

All 36 reconstructed C translation units compile for ARM7TDMI and all current
host tests pass. No increase to the **51%** engineering estimate is claimed
for this verification-only pass. Matching-ROM build remains **0%**.

## Pass17 extension — active-list validator recovery

`ResourceNode_ValidateActiveList` at `0x080604F8` is now implemented from its
ROM listing in `src/resource_node.c`. The host harness invokes this C
implementation and records calls to the already-recovered return-only
diagnostic sink. Two added scenarios cover a non-null head predecessor and a
broken back-link on a later node. See
`asm/runtime/resource_node_validate_604f8.thumb.dis.txt`.
