#include <stdint.h>
#include "runtime.h"

/* Neutral reconstruction of the object record at 0x08064FC0. */
typedef struct ObjectChild {
    uint8_t bytes[0xC4];
} ObjectChild;

typedef struct ObjectRecord {
    ObjectChild *children; /* +0x00 */
    uint8_t count;         /* +0x04 */
    uint8_t mode_flags;    /* +0x05 */
    uint16_t flags;        /* +0x06 */
    uint32_t cursor;       /* +0x08 */
    uint32_t limit;        /* +0x0C */
    uint32_t child_data;   /* +0x10 */
    uint32_t param14;      /* +0x14 */
    uint32_t param18;      /* +0x18 */
    uint8_t unknown1[4];   /* +0x1C */
    uint32_t aux20;        /* +0x20 */
    uint16_t width;        /* +0x24 */
    uint16_t height;       /* +0x26 */
    uint32_t callback;     /* +0x28 */
    int32_t timer;         /* +0x2C */
    uint8_t unknown2[0x90];/* +0x30..BF */
} ObjectRecord;

/* Confirmed child queue state at +0x74/+0x78/+0x7c. */
typedef struct ChildQueueState {
    int32_t count;
    void *entries;
    void *allocation;
} ChildQueueState;

/* 0x0806512C: count children whose +0x70 field is nonzero. */
uint8_t Object_CountActiveChildren(const ObjectRecord *obj)
{
    uint32_t count = 0;
    for (uint32_t i = 0; i < obj->count; ++i) {
        const uint8_t *child = (const uint8_t *)obj->children + i * 0xC4;
        if (*(const uint32_t *)(child + 0x70) != 0)
            ++count;
    }
    return (uint8_t)count;
}

/* 0x08050388-style child reset used by the object subsystem. */
void Object_ClearChildren(ObjectRecord *obj)
{
    for (uint32_t i = 0; i < obj->count; ++i) {
        uint8_t *child = (uint8_t *)obj->children + i * 0xC4;
        *(uint32_t *)(child + 0x70) = 0;
    }
}

/* 0x080657E8: service every child through the common child routine. */
void Object_ServiceChildren(ObjectRecord *obj)
{
    for (uint32_t i = 0; i < obj->count; ++i) {
        uint8_t *child = (uint8_t *)obj->children + i * 0xC4;
        /* The ROM calls 0x08058900 here; keep the implementation neutral. */
        ChildQueueState *queue = (ChildQueueState *)(child + 0x74);
        if (queue->count >= 0)
            ChildQueue_Clear(child);
    }
}
