#include <stddef.h>
#include <stdint.h>
#include "recovered_runtime.h"

typedef struct RuntimeBlockRecord {
    uint32_t start_index; /* +0x00: first 0xC4-byte payload slot */
    uint32_t slot_count;  /* +0x04 */
    uint32_t payload;     /* +0x08: zero marks a free descriptor */
    struct RuntimeBlockRecord *previous; /* +0x0C */
    struct RuntimeBlockRecord *next;     /* +0x10 */
} RuntimeBlockRecord;

_Static_assert(sizeof(RuntimeBlockRecord) == 0x14,
               "runtime block descriptor stride mismatch");
_Static_assert(offsetof(RuntimeBlockRecord, payload) == 0x08,
               "runtime block payload offset mismatch");
_Static_assert(offsetof(RuntimeBlockRecord, previous) == 0x0C,
               "runtime block previous offset mismatch");
_Static_assert(offsetof(RuntimeBlockRecord, next) == 0x10,
               "runtime block next offset mismatch");

#define RAM32(address) (*(volatile uint32_t *)(uintptr_t)(address))


/* 0x08062FCC: find an unused descriptor in the 256-entry 0x1400-byte pool. */
RuntimeBlockRecord *RuntimeBlock_FindFree(void)
{
    RuntimeBlockRecord *record =
        (RuntimeBlockRecord *)(uintptr_t)RAM32(0x03005E54u);
    unsigned i;

    for (i = 0; i < 256; ++i, ++record) {
        if (record->payload == 0)
            return record;
    }

    sub_08057B60((const void *)(uintptr_t)0x08755EB0u);
    return 0;
}

/* 0x0806307C: walk the +0x10 link chain and return its final record. */
RuntimeBlockRecord *RuntimeBlock_FindTail(void)
{
    RuntimeBlockRecord *record =
        (RuntimeBlockRecord *)(uintptr_t)RAM32(0x03005E60u);

    while (record != 0 && record->next != 0)
        record = record->next;
    return record;
}

/* 0x080631B4: resolve a relative child index to its 0xC4-byte record. */
void *RuntimeBlock_Get(const RuntimeBlockRecord *block, int32_t index)
{
    uint32_t base_index;
    uint32_t payload_base;

    /* The original uses a signed >= comparison only; negative indices are not
       explicitly rejected before 32-bit address arithmetic. */
    if (index >= (int32_t)block->slot_count)
        return 0;

    base_index = block->start_index + (uint32_t)index;
    payload_base = RAM32(0x03005E68u);
    return (void *)(uintptr_t)(payload_base + base_index * 0xC4u);
}
