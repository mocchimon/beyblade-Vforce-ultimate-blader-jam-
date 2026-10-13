#include <stdint.h>

/* ROM 0x080607B4: first-fit allocation from the sorted range free list.
 * Nodes: {u16 start, u16 length, u32 next}.
 * Returns the allocated 16-bit start, or -1 on failure.
 * An exhausted node is retained if it is the sole active node.
 */
typedef struct RuntimeRangeNode {
    uint16_t start;
    uint16_t length;
    uint32_t next;
} RuntimeRangeNode;

#define RANGE_ACTIVE (*(volatile uint32_t *)(uintptr_t)0x03005DC8u)
#define RANGE_SPARE  (*(volatile uint32_t *)(uintptr_t)0x03005DD8u)

int32_t RuntimeRange_Alloc(uint32_t requested)
{
    uint32_t current_addr = RANGE_ACTIVE;
    uint32_t previous_addr = 0;

    while (current_addr != 0u) {
        RuntimeRangeNode *current = (RuntimeRangeNode *)(uintptr_t)current_addr;
        if ((uint32_t)current->length >= requested) {
            uint32_t start = current->start;
            current->start = (uint16_t)(start + requested);
            current->length = (uint16_t)((uint32_t)current->length - requested);

            if (current->length == 0u &&
                !(RANGE_ACTIVE == current_addr && current->next == 0u)) {
                if (previous_addr != 0u)
                    ((RuntimeRangeNode *)(uintptr_t)previous_addr)->next = current->next;
                else
                    RANGE_ACTIVE = current->next;
                current->next = RANGE_SPARE;
                RANGE_SPARE = current_addr;
            }
            return (int32_t)start;
        }
        previous_addr = current_addr;
        current_addr = current->next;
    }

    /* ROM calls its diagnostic dispatcher before returning -1. */
    return -1;
}
