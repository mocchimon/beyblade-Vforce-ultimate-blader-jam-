# Child cleanup (`0x080588CC`)

The cleanup routine is reconstructed in `src/child_queue.c` as
`ObjectChild_Cleanup`. It releases the resource-node handle stored at child
`+0xB8` through `0x08060AB8`, clears that handle, frees the queue's heap block
descriptor at `+0x7C`, then resets the queue fields at `+0x74`, `+0x78`, and
`+0x7C` to `-1`, zero, and zero respectively. The queue allocation is passed as
a heap descriptor, not as its payload address.

The implementation of `0x08060AB8` is still treated as an external subsystem
boundary; the child cleanup does not invent its resource-list semantics.
