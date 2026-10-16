#include <stddef.h>
#include <stdint.h>
#include "gba.h"
#include "recovered_runtime.h"
#include "resource_node.h"

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

/* 0x080604F8: checks the doubly-linked active list and emits ROM diagnostics. */
void ResourceNode_ValidateActiveList(void *opaque_head)
{
    uint8_t *current = (uint8_t *)opaque_head;
    uint8_t *previous;

    if (current == 0)
        return;

    previous = (uint8_t *)(uintptr_t)
        *(volatile uint32_t *)(void *)(current + 0x00);
    if (previous != 0)
        sub_08057C5C((const void *)(uintptr_t)0x0875591Cu, 0);

    do {
        if (previous != 0 &&
            *(volatile uint32_t *)(void *)(previous + 0x04) !=
                (uint32_t)(uintptr_t)current) {
            sub_08057C5C((const void *)(uintptr_t)0x08755938u, 0);
        }

        if (*(volatile uint32_t *)(void *)(current + 0x00) !=
            (uint32_t)(uintptr_t)previous) {
            sub_08057C5C((const void *)(uintptr_t)0x08755954u, 0);
        }

        previous = current;
        current = (uint8_t *)(uintptr_t)
            *(volatile uint32_t *)(void *)(current + 0x04);
    } while (current != 0);
}

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

typedef struct ResourceNodeAcquireView {
    uint32_t previous;            /* +0x00 */
    uint32_t next;                /* +0x04 */
    uint8_t reserved08[0x1A];
    uint16_t insertion_class;     /* +0x22 */
} ResourceNodeAcquireView;

typedef struct ResourceNodeSelectionEntryView {
    uint8_t links_and_reserved[0x08];
    uint32_t position_x;          /* +0x08 */
    uint32_t value_0c;             /* +0x0C */
    uint32_t packed_10;            /* +0x10 */
    uint16_t packed_14;            /* +0x14 */
    uint16_t value_16;             /* +0x16 */
    uint16_t value_18;             /* +0x18 */
    uint16_t sentinel_1a;          /* +0x1A */
    uint16_t value_1c;             /* +0x1C */
    uint16_t zero_1e;              /* +0x1E */
    uint16_t zero_20;              /* +0x20 */
    uint16_t insertion_class;      /* +0x22, set by acquire */
    int32_t token_24;              /* +0x24 */
    uint32_t payload_28;           /* +0x28 */
    uint32_t metadata_2c;          /* +0x2C */
} ResourceNodeSelectionEntryView;

typedef struct ResourceNodeSelectionMetadataView {
    uint8_t reserved00[6];
    uint8_t value_06;
    int8_t signed_value_07;
    uint8_t reserved08[4];
    uint8_t value_0c;
    uint8_t reserved0d[3];
    uint32_t offset_10;
    uint32_t reserved_14;
    uint32_t reserved_18;
    uint32_t offset_1c;
} ResourceNodeSelectionMetadataView;

_Static_assert(offsetof(ResourceNodeAcquireView, insertion_class) == 0x22,
               "resource insertion class must be at +0x22");
_Static_assert(sizeof(ResourceNodeAcquireView) == 0x24,
               "resource acquire prefix must end after +0x22");
_Static_assert(offsetof(ResourceNodeSelectionEntryView, packed_10) == 0x10,
               "selection entry packed word must be at +0x10");
_Static_assert(offsetof(ResourceNodeSelectionEntryView, token_24) == 0x24,
               "selection entry token must be at +0x24");
_Static_assert(offsetof(ResourceNodeSelectionEntryView, payload_28) == 0x28,
               "selection entry payload must be at +0x28");
_Static_assert(offsetof(ResourceNodeSelectionEntryView, metadata_2c) == 0x2C,
               "selection entry metadata must be at +0x2C");
_Static_assert(sizeof(ResourceNodeSelectionEntryView) == 0x30,
               "selection entry view must be 0x30 bytes");
_Static_assert(offsetof(ResourceNodeSelectionMetadataView, value_0c) == 0x0C,
               "selection metadata byte must be at +0x0C");
_Static_assert(offsetof(ResourceNodeSelectionMetadataView, offset_10) == 0x10,
               "selection metadata offset must be at +0x10");
_Static_assert(offsetof(ResourceNodeSelectionMetadataView, offset_1c) == 0x1C,
               "selection metadata offset must be at +0x1C");

/* ROM 0x080609E8. Return the first node whose +0x22 class is at least the
 * requested class, or the last node if all classes are smaller. */
static ResourceNodeAcquireView *ResourceNode_FindInsertionPoint(
    uint32_t head, uint32_t resource_class)
{
    ResourceNodeAcquireView *node =
        (ResourceNodeAcquireView *)(uintptr_t)head;
    ResourceNodeAcquireView *last = 0;
    uint16_t requested = (uint16_t)resource_class;

    while (node != 0) {
        if (node->insertion_class >= requested)
            return node;
        last = node;
        node = (ResourceNodeAcquireView *)(uintptr_t)node->next;
    }

    return last;
}

/* ROM 0x08060A04. Reuses one node from the resource free chain, inserts it
 * into the active chain near the requested class, and validates that chain. */
void *ResourceNode_AcquireByClass(uint32_t resource_class,
                                  uint32_t ignored_selected_index)
{
    uint16_t requested = (uint16_t)resource_class;
    ResourceNodeAcquireView *node =
        (ResourceNodeAcquireView *)(uintptr_t)RESOURCE_FREE_HEAD;

    (void)ignored_selected_index;

    if (node != 0) {
        uint32_t active_head = RESOURCE_ACTIVE_HEAD;
        ResourceNodeAcquireView *insertion = ResourceNode_FindInsertionPoint(
            active_head, requested);
        ResourceNodeAcquireView *next;

        node->insertion_class = requested;
        RESOURCE_FREE_HEAD = node->next;

        if (insertion == 0) {
            next = (ResourceNodeAcquireView *)(uintptr_t)active_head;
            if (next != 0)
                next->previous = (uint32_t)(uintptr_t)node;
            node->next = active_head;
            node->previous = 0;
            RESOURCE_ACTIVE_HEAD = (uint32_t)(uintptr_t)node;
        } else {
            next = (ResourceNodeAcquireView *)(uintptr_t)insertion->next;
            if (next != 0)
                next->previous = (uint32_t)(uintptr_t)node;
            node->next = (uint32_t)(uintptr_t)next;
            node->previous = (uint32_t)(uintptr_t)insertion;
            insertion->next = (uint32_t)(uintptr_t)node;
        }

        RESOURCE_NODE_COUNT -= 1u;
    } else {
        sub_08057B60((const void *)(uintptr_t)0x08755AD8u);
    }

    ResourceNode_ValidateActiveList(
        (void *)(uintptr_t)RESOURCE_ACTIVE_HEAD);
    return node;
}

/* ROM 0x08060B8C. Initialize the recovered fields of a reused entry. The
 * incoming register y value is overwritten by stack argument seven in ROM. */
void ResourceNode_ConfigureSelectionEntry(
    void *opaque_entry, const void *opaque_metadata, uint32_t position_x,
    uint32_t ignored_position_y, uint32_t arg4, uint32_t arg5,
    uint32_t arg6, uint32_t arg7)
{
    ResourceNodeSelectionEntryView *entry =
        (ResourceNodeSelectionEntryView *)opaque_entry;
    const ResourceNodeSelectionMetadataView *metadata =
        (const ResourceNodeSelectionMetadataView *)opaque_metadata;
    uint32_t signed_byte = (uint32_t)(int32_t)metadata->signed_value_07;
    uint32_t low_byte = metadata->value_0c;
    uint32_t handle = (uint32_t)(uintptr_t)opaque_entry;
    uint32_t packed_10;
    uint32_t packed_14;
    uint32_t payload_offset;

    (void)ignored_position_y;

    entry->position_x = position_x;
    entry->value_0c = arg7;

    packed_10 = 0x00001000u |
                ((signed_byte & 0x03u) << 14) |
                (((~low_byte) & 1u) << 13) |
                ((arg4 & 0x03u) << 10) |
                ((signed_byte & 0x0Cu) << 28) |
                ((arg6 & 0x03u) << 28);
    entry->packed_10 = packed_10;

    packed_14 = (((low_byte >> 1) & 0x0Fu) << 12) |
                ((arg5 & 0x03u) << 10);
    entry->packed_14 = (uint16_t)packed_14;
    entry->value_16 = metadata->value_06;
    entry->value_18 = (uint16_t)handle;
    entry->sentinel_1a = 0xFFFFu;
    entry->value_1c = (uint8_t)arg6;
    entry->zero_20 = 0;
    entry->token_24 = -1;

    payload_offset = metadata->offset_1c != 0u ? 0u : metadata->offset_10;
    entry->payload_28 = (uint32_t)(uintptr_t)opaque_metadata + payload_offset;
    entry->metadata_2c = (uint32_t)(uintptr_t)opaque_metadata;
}
