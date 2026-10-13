#include <stdint.h>

typedef struct RuntimeBlockRecord {
    uint32_t start_index;
    uint32_t slot_count;
    uint32_t payload;
    struct RuntimeBlockRecord *previous;
    struct RuntimeBlockRecord *next;
} RuntimeBlockRecord;

extern RuntimeBlockRecord *RuntimeBlock_FindFree(void);
extern int32_t RuntimeBlock_Insert(uint32_t slot_count,
                                   RuntimeBlockRecord *record);

#define RAM32(address) (*(volatile uint32_t *)(uintptr_t)(address))

/* 0x08062F20: allocate a run of 0xC4-byte slots and return its descriptor. */
RuntimeBlockRecord *RuntimeBlock_Allocate(uint32_t slot_count)
{
    RuntimeBlockRecord *record;
    RuntimeBlockRecord *tail;
    uint32_t high_water;
    uint32_t end;
    uint32_t start_index;
    int used_gap = 0;

    if (RAM32(0x03005E60u) == 0) {
        RAM32(0x03005E60u) = RAM32(0x03005E54u);
        RAM32(0x03005E64u) = 0;
        RAM32(0x03005E5Cu) = 0;
    }

    if ((int32_t)RAM32(0x03005E5Cu) > 0xFF)
        return 0;

    record = RuntimeBlock_FindFree();
    if (record == 0)
        return 0;

    high_water = RAM32(0x03005E64u);
    end = high_water + slot_count;
    if ((int32_t)end <= 0x100) {
        /* Fast path: append to the high-water mark without searching gaps. */
        start_index = high_water;
        tail = (RuntimeBlockRecord *)(uintptr_t)RAM32(0x03005E58u);
        if (tail != 0) {
            tail->next = record;
            record->previous = tail;
        } else {
            record->previous = 0;
        }
        record->next = 0;
    } else {
        /* Slow path: insert into an available gap in the linked block list. */
        int32_t gap = RuntimeBlock_Insert(slot_count, record);
        if (gap < 0)
            return 0;
        start_index = (uint32_t)gap;
        used_gap = 1;
    }

    record->start_index = start_index;
    record->slot_count = slot_count;
    record->payload = RAM32(0x03005E68u) + start_index * 0xC4u;
    if (!used_gap) {
        RAM32(0x03005E58u) = (uint32_t)(uintptr_t)record;
        RAM32(0x03005E64u) = high_water + slot_count;
    }
    return record;
}
