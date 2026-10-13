# Auxiliary resource-node unlink (`0x08060B5C`)

Recovered as `ResourceNode_UnlinkAuxiliary` in `src/resource_node.c`.

The routine returns immediately if the node pointer is null or byte `+0x19` is
nonzero. Otherwise, it removes the node from a doubly linked list using `+0x00`
(previous) and `+0x04` (next), repairing either the previous node or the active
head at `0x03005DF8`, and the next node's previous pointer. It then pushes the
node onto the free chain headed by `0x03005DE8`, reusing `+0x04` as the free
link. This helper is called by `ResourceNode_Unlink` when the parent node's
`+0x30` field is nonzero; the caller clears that field after return.

The list mechanics and gate byte are directly visible in the Thumb instructions.
The broader meaning of the auxiliary node remains unresolved.
