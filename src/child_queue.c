#include <stdint.h>
#include "runtime.h"

/*
 * A per-child four-slot command/event queue.
 *
 * The ROM allocates exactly 0x40 bytes when the queue is first used.  Each
 * slot is 0x10 bytes.  The child stores the allocation at +0x7c, the slot
 * array at +0x78, and the number of appended slots at +0x74.
 *
 * The semantic meaning of the four words is not yet established, so the
 * fields remain neutral here.
 */
typedef struct ChildQueueEntry {
    uint32_t value0;
    uint32_t value1;
    uint32_t value2;
    uint32_t value3;
} ChildQueueEntry;

typedef struct ChildQueueState {
    int32_t count;                 /* +0x74 */
    ChildQueueEntry *entries;      /* +0x78 */
    void *allocation;              /* +0x7c */
} ChildQueueState;

/* 0x080587B8 */
void ChildQueue_Append(void *child, uint32_t value0, uint32_t value2,
                       uint32_t value3, uint32_t value1)
{
    ChildQueueState *q = (ChildQueueState *)((uint8_t *)child + 0x74);

    if (q->count == -1) {
        q->count = 0;
        q->allocation = Heap_AllocAlt(0x40);
        if (q->allocation == 0)
            return; /* original calls the runtime fatal handler */
        q->entries = (ChildQueueEntry *)(uintptr_t)
            *(uint32_t *)q->allocation;
    }

    uint32_t slot = 0;
    if (q->count <= 3) {
        slot = (uint32_t)q->count;
    } else {
        int32_t first_empty = -1;
        uint32_t empty_count = 0;
        for (uint32_t i = 0; i < 4; ++i) {
            if (q->entries[i].value0 == 0 && first_empty < 0)
                first_empty = (int32_t)i;
            if (q->entries[i].value0 == 0)
                ++empty_count;
        }
        if (first_empty >= 0)
            slot = (uint32_t)first_empty;
        else {
            q->count = 0;
            slot = 0;
        }
        (void)empty_count;
    }

    ChildQueueEntry *entry = &q->entries[slot];
    entry->value0 = value3;
    entry->value1 = value1;
    entry->value2 = value0;
    entry->value3 = value2;
    ++q->count;
}

/* 0x08058900 */
void ChildQueue_Clear(void *child)
{
    ChildQueueState *q = (ChildQueueState *)((uint8_t *)child + 0x74);
    if (q->count == -1)
        return;

    for (int32_t i = 0; i < q->count; ++i)
        q->entries[i].value0 = 0;

    q->count = 0;
}
