# Heap allocator reconstruction

## Confidence and boundaries

The routines at `0x0805A3CC`, `0x0805A444`, `0x0805A4BC`, `0x0805A560`, and `0x0805A608` form two descriptor-backed, address-sorted allocators. This pass recovers the observed descriptor layout, arena bounds, descriptor pools, free-list insertion/search/unlink logic, and the return convention. Names are reconstructed; the original symbol names are unknown.

## Descriptor layout

Each descriptor is 0x10 bytes:

| Offset | Meaning |
|---:|---|
| `+0x00` | allocated range start address |
| `+0x04` | allocated range size |
| `+0x08` | previous descriptor in address order |
| `+0x0C` | next descriptor in address order |

Both allocation front-ends return the descriptor pointer, not the payload address. Callers that need the allocated bytes must load descriptor `+0x00`.

## Main heap — `0x0805A3CC`

- Descriptor-pool base is loaded from global `0x03005C80`, initialized to `0x02000000`.
- Pool capacity passed to the descriptor search is `0x20` entries.
- Allocatable arena begins at `0x03001160` and has size `0x4B20`, ending at `0x03005C80`.
- Sorted-list head pointer is at `0x03005C84`.
- Allocation counter is at `0x03005C88`.
- Descriptor allocation failures report message pointer `0x08755278`; inability to fit the requested range reports `0x087551E4` plus the requested size.

## Alternate heap — `0x0805A444`

- Descriptor-pool base is loaded from global `0x03005C90`, initialized to `0x02000200`.
- Pool capacity is also `0x20` entries.
- Allocatable arena base is the value stored at `0x03001154`, initialized to `0x02000400`.
- Arena size is `0x3FC00`, ending at `0x02040000`.
- Sorted-list head pointer is at `0x03001150`.
- Allocation counter is at `0x0300115C`.
- Insertion failure reports message pointer `0x0875521C` plus the requested size.

## Algorithms

`Heap_FindAvailable` walks the descriptor pool in 0x10-byte increments and returns the first descriptor whose address and size are both zero. If no such descriptor exists, it reports `0x08755278` and returns null.

`Heap_InsertBlock` keeps descriptors sorted by payload address. It first tries the gap before the current head; then gaps between each block and its successor; finally the tail gap before the arena end. The routine inserts a descriptor only if the requested size fits entirely inside one gap. It updates both neighboring links and the head pointer where needed.

`Heap_Free` unlinks the descriptor, updates the appropriate heap head when freeing the first node, decrements the matching heap's allocation counter, and clears all four descriptor fields. The address threshold `0x0203FFFF` distinguishes the EWRAM alternate heap from the IWRAM main heap.

## Caller corrections made in this pass

- `src/object_record.c`: `Heap_AllocAlt` result is treated as a descriptor; record storage is based on its `+0x00` payload address.
- `src/child_queue.c`: the descriptor remains stored in the child's allocation field, while the queue-entry pointer is derived from descriptor `+0x00`.
- `src/runtime_memory.c` already reads `+0x00` from returned descriptors when installing the large/small buffer addresses.
- `src/arm_rasterizer_loader.c` already uses the descriptor's address and size fields for the DMA copy.

## Validation

The project Makefile compiles all 25 C source files for ARM7TDMI in their selected ARM/Thumb states. This is compile validation only; it does not imply a linkable or byte-matching ROM build.

## Follow-up caller audit

A subsequent audit also corrected `RuntimeEntry_InitIndexed` in `src/runtime_entries.c`: the ROM uses the signed halfword stored at `secondary_table[0]` to index `source_table`, but always reads the alternate initializer's table value from `TABLE_0D98[0]`. The prior source draft mistakenly used the pointer value as a table index.
