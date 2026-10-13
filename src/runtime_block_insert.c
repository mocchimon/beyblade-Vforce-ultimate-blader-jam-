#include <stdint.h>

typedef struct RuntimeBlockRecord {
    uint32_t start_index;
    uint32_t slot_count;
    uint32_t payload;
    struct RuntimeBlockRecord *previous;
    struct RuntimeBlockRecord *next;
} RuntimeBlockRecord;

#define RAM32(address) (*(volatile uint32_t *)(uintptr_t)(address))

/*
 * Core list operation from 0x08063090, separated so its link behavior can be
 * tested independently. It searches interior gaps only; append space is
 * handled by RuntimeBlock_Allocate's high-water path.
 */
int32_t RuntimeBlock_InsertInList(uint32_t slot_count,
                                  RuntimeBlockRecord *head,
                                  RuntimeBlockRecord *record)
{
    RuntimeBlockRecord *current = head;

    if (current == 0 ||
        (int32_t)current->start_index >= (int32_t)slot_count)
        return -1;

    for (;;) {
        RuntimeBlockRecord *next = current->next;
        uint32_t gap_start;
        uint32_t gap_size;

        if (next == 0)
            return -1;

        gap_start = current->start_index + current->slot_count;
        gap_size = next->start_index - gap_start;
        if ((int32_t)gap_size >= (int32_t)slot_count) {
            record->previous = current;
            record->next = next;
            next->previous = record;
            current->next = record;
            return (int32_t)gap_start;
        }

        current = next;
    }
}

/* 0x08063090: find and link a descriptor into an existing interior gap. */
int32_t RuntimeBlock_Insert(uint32_t slot_count, RuntimeBlockRecord *record)
{
    RuntimeBlockRecord *head =
        (RuntimeBlockRecord *)(uintptr_t)RAM32(0x03005E60u);
    return RuntimeBlock_InsertInList(slot_count, head, record);
}
