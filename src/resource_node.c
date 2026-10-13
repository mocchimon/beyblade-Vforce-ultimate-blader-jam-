#include <stddef.h>
#include <stdint.h>
#include "gba.h"

#define RESOURCE_ACTIVE_HEAD (*(volatile uint32_t *)(uintptr_t)0x03005DE4u)
#define RESOURCE_FREE_HEAD   (*(volatile uint32_t *)(uintptr_t)0x03005DECu)
#define RESOURCE_NODE_COUNT  (*(volatile uint32_t *)(uintptr_t)0x03005DF4u)
#define AUX_ACTIVE_HEAD      (*(volatile uint32_t *)(uintptr_t)0x03005DF8u)
#define AUX_FREE_HEAD        (*(volatile uint32_t *)(uintptr_t)0x03005DE8u)

typedef struct ResourceNodeView {
    uint32_t prev;                 /* +0x00: active-list previous */
    uint32_t next;                 /* +0x04: active-list next/free-list next */
    uint8_t reserved08[0x0C];      /* +0x08..+0x13 */
    uint16_t type;                 /* +0x14 (not used by unlink) */
    uint16_t range_class;          /* +0x16 */
    uint8_t reserved18[0x08];      /* +0x18..+0x1F */
    uint16_t flags;                /* +0x20 */
    uint16_t reserved22;           /* +0x22 */
    int32_t range_token;           /* +0x24 */
    uint8_t reserved28[0x08];      /* +0x28..+0x2F */
    uint32_t auxiliary;            /* +0x30 */
} ResourceNodeView;

_Static_assert(offsetof(ResourceNodeView, range_class) == 0x16,
               "resource-node range class offset mismatch");
_Static_assert(offsetof(ResourceNodeView, flags) == 0x20,
               "resource-node flags offset mismatch");
_Static_assert(offsetof(ResourceNodeView, range_token) == 0x24,
               "resource-node range token offset mismatch");
_Static_assert(offsetof(ResourceNodeView, auxiliary) == 0x30,
               "resource-node auxiliary offset mismatch");

/* These are independently recovered routines; their precise domain names remain provisional. */
extern void RuntimeRange_Release(int32_t token, uint32_t mask); /* 0x0806082C */

extern void ResourceNode_ValidateActiveList(void *head);       /* 0x080604F8 */

/*
 * 0x08060B5C: detach an auxiliary node unless its +0x19 state byte is set,
 * then push it onto the auxiliary free chain. The links at +0/+4 are shared
 * with the active/free list phases, but this routine uses a separate pair of
 * global heads from ResourceNode_Unlink.
 */
void ResourceNode_UnlinkAuxiliary(void *opaque_node)
{
    uint8_t *node = (uint8_t *)opaque_node;
    uint32_t previous;
    uint32_t next;

    if (node == 0 || node[0x19] != 0u)
        return;

    previous = *(volatile uint32_t *)(void *)(node + 0x00);
    next = *(volatile uint32_t *)(void *)(node + 0x04);

    if (previous != 0u)
        *(volatile uint32_t *)(uintptr_t)(previous + 4u) = next;
    else
        AUX_ACTIVE_HEAD = next;

    if (next != 0u)
        *(volatile uint32_t *)(uintptr_t)next = previous;

    *(volatile uint32_t *)(void *)(node + 0x04) = AUX_FREE_HEAD;
    AUX_FREE_HEAD = (uint32_t)(uintptr_t)node;
}

/* 0x08060AB8: unlink an active resource node and return it to the free list. */
void ResourceNode_Unlink(void *opaque_node)
{
    ResourceNodeView *node = (ResourceNodeView *)opaque_node;
    uint32_t previous;
    uint32_t next;

    if (node == 0)
        return;

    previous = node->prev;
    next = node->next;

    /* Release the associated range once unless the node's low flag bit suppresses it. */
    if (node->range_token >= 0) {
        if ((node->flags & 1u) == 0u) {
            uint32_t shift = (uint32_t)node->range_class - 5u;
            uint32_t mask = shift < 32u ? (1u << shift) : 0u;
            RuntimeRange_Release(node->range_token, mask);
        }
        node->range_token = -1;
    }

    if (previous != 0u) {
        *(volatile uint32_t *)(uintptr_t)(previous + 4u) = next;
    } else {
        RESOURCE_ACTIVE_HEAD = next;
    }
    if (next != 0u)
        *(volatile uint32_t *)(uintptr_t)next = previous;

    /* The free chain is singly linked through +0x04. */
    node->next = RESOURCE_FREE_HEAD;
    RESOURCE_FREE_HEAD = (uint32_t)(uintptr_t)node;

    if (node->auxiliary != 0u) {
        ResourceNode_UnlinkAuxiliary((void *)(uintptr_t)node->auxiliary);
        node->auxiliary = 0u;
    }

    RESOURCE_NODE_COUNT += 1u;
    ResourceNode_ValidateActiveList((void *)(uintptr_t)RESOURCE_ACTIVE_HEAD);
}
