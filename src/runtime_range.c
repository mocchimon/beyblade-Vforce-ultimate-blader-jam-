#include <stdint.h>

/* 0x0806082C: return a 16-bit interval to the sorted free-range chain.
 * ROM stores free-range nodes as {u16 start, u16 length, u32 next}.
 * The node pool is preallocated elsewhere; this routine never mallocs.
 */
typedef struct RuntimeRangeNode {
    uint16_t start;
    uint16_t length;
    uint32_t next;
} RuntimeRangeNode;

#define RANGE_ACTIVE (*(volatile uint32_t *)(uintptr_t)0x03005DC8u)
#define RANGE_SPARE  (*(volatile uint32_t *)(uintptr_t)0x03005DD8u)

/* Original diagnostic path passes a ROM string through the shared dispatcher.
 * Preserve the recoverable state behavior, but do not emulate diagnostic text. */
void RuntimeRange_Release(int32_t token, uint32_t amount)
{
    uint32_t node_addr = RANGE_ACTIVE;
    uint32_t spare_addr = RANGE_SPARE;
    uint32_t previous = 0;
    uint32_t end = (uint32_t)token + amount;
    RuntimeRangeNode *node;

    while (node_addr != 0u) {
        node = (RuntimeRangeNode *)(uintptr_t)node_addr;
        if (end == node->start) {
            node->start = (uint16_t)token;
            node->length = (uint16_t)(node->length + amount);
            break;
        }
        if ((uint32_t)node->start + node->length == (uint32_t)token) {
            node->length = (uint16_t)(node->length + amount);
            break;
        }
        if ((uint32_t)node->start > (uint32_t)token) {
            if (spare_addr == 0u)
                return; /* Original branches to diagnostic/return. */
            RuntimeRangeNode *spare = (RuntimeRangeNode *)(uintptr_t)spare_addr;
            RANGE_SPARE = spare->next;
            if (previous != 0u)
                ((RuntimeRangeNode *)(uintptr_t)previous)->next = spare_addr;
            else
                RANGE_ACTIVE = spare_addr;
            spare->next = node_addr;
            spare->start = (uint16_t)token;
            spare->length = (uint16_t)amount;
            break;
        }
        previous = node_addr;
        node_addr = node->next;
    }

    /* The original assumes the active list is nonempty at this point.
     * Coalesce any immediately adjacent successors, returning them to spare. */
    node_addr = RANGE_ACTIVE;
    if (node_addr == 0u)
        return;
    node = (RuntimeRangeNode *)(uintptr_t)node_addr;
    while (node->next != 0u) {
        uint32_t successor_addr = node->next;
        RuntimeRangeNode *successor = (RuntimeRangeNode *)(uintptr_t)successor_addr;
        if ((uint32_t)node->start + node->length == successor->start) {
            node->length = (uint16_t)(node->length + successor->length);
            node->next = successor->next;
            successor->next = RANGE_SPARE;
            RANGE_SPARE = successor_addr;
        } else {
            node = successor;
        }
    }
}
