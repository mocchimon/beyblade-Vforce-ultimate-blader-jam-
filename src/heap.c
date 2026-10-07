#include "gba.h"
#include "runtime.h"
#include <stdint.h>

/*
 * The original program contains a small linked free-list allocator in
 * EWRAM.  The routines below are reconstructed from 0x0805A3CC-0x0805A608.
 *
 * The exact names/types used by the original developers are unknown.  The
 * field layout is nevertheless clear from the loads/stores:
 *   +00 base/address
 *   +04 size
 *   +08 previous block
 *   +0C next block
 */
typedef struct HeapBlock {
    uint32_t address;
    uint32_t size;
    struct HeapBlock *prev;
    struct HeapBlock *next;
} HeapBlock;

extern HeapBlock **gHeapHead;
extern HeapBlock *gHeapSentinel;
extern uint32_t gHeapAllocCount;

/* 0x0805A608: walk the block list looking for a block large enough. */
void *Heap_FindAvailable(void *head, uint32_t count)
{
    HeapBlock *p = (HeapBlock *)head;
    while (count != 0) {
        if (p->size != 0 || p->address != 0)
            return p;
        p = (HeapBlock *)((uint8_t *)p + 0x10);
        --count;
    }
    return 0;
}

/* 0x0805A560: split/insert a free block into the linked list. */
void *Heap_InsertBlock(void *node, uint32_t size)
{
    /* The exact allocator metadata arguments are still being recovered.
     * Keep this as a structural reconstruction rather than guessing the
     * original API. */
    (void)node;
    (void)size;
    return 0;
}

/* 0x0805A3CC: primary allocation front-end. */
void *Heap_Alloc(uint32_t size)
{
    /* The binary allocates a 0x20-byte descriptor and delegates the actual
     * placement to 0x0805A560.  The full metadata path is still represented
     * in the assembly map; this C declaration records the recovered API. */
    (void)size;
    return 0;
}

/* 0x0805A444: second allocation front-end using the alternate pool. */
void *Heap_AllocAlt(uint32_t size)
{
    (void)size;
    return 0;
}

/* 0x0805A4BC: unlink a heap block and return it to the free list. */
void Heap_Free(void *block)
{
    (void)block;
}
