#include <stdint.h>

typedef struct RuntimeBlockRecord {
    uint32_t start_index;
    uint32_t slot_count;
    uint32_t payload;
    struct RuntimeBlockRecord *previous;
    struct RuntimeBlockRecord *next;
} RuntimeBlockRecord;

#define RAM32(address) (*(volatile uint32_t *)(uintptr_t)(address))

extern void ObjectChild_Cleanup(void *child); /* ROM routine at 0x080588CC */
extern void RuntimeMemory_Init(void);          /* ROM routine at 0x08062E94 */

/* 0x08063004: clean child records, unlink the block, and mark its slot free. */
void RuntimeBlock_Free(RuntimeBlockRecord *record)
{
    uint32_t i;
    uint32_t count = record->slot_count;
    uint8_t *child = (uint8_t *)(uintptr_t)record->payload;
    RuntimeBlockRecord *previous = record->previous;
    RuntimeBlockRecord *next = record->next;

    for (i = 0; i < count; ++i, child += 0xC4u)
        ObjectChild_Cleanup(child);

    if ((RuntimeBlockRecord *)(uintptr_t)RAM32(0x03005E60u) == record)
        RAM32(0x03005E60u) = (uint32_t)(uintptr_t)previous;

    if (previous == 0) {
        if (next == 0) {
            RuntimeMemory_Init();
        } else {
            RAM32(0x03005E58u) = (uint32_t)(uintptr_t)next;
            next->previous = previous;
        }
    } else {
        previous->next = next;
        if (next != 0) {
            next->previous = previous;
        } else {
            /* Preserve the ROM's high-water-mark decrement on tail removal. */
            RAM32(0x03005E64u) -= count;
        }
    }

    record->payload = 0;
}
