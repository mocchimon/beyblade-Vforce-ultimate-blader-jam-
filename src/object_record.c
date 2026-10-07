#include <stdint.h>
#include "gba.h"
#include "runtime.h"

/*
 * 0x08050398 initializes a runtime record from a source descriptor.
 * The structure names are intentionally neutral until more call sites are
 * recovered.  The allocation size is (source->count * 0x1c).
 */
typedef struct RuntimeRecord {
    void *buffer;          /* +0x00 */
    const uint32_t *src;   /* +0x04 */
    uint32_t item_count;   /* +0x08 */
    uint16_t stride;       /* +0x0C */
    uint16_t requested;    /* +0x0E */
    uint32_t cursor;       /* +0x10 */
    uint32_t capacity;     /* +0x14 */
} RuntimeRecord;

void RuntimeRecord_Init(RuntimeRecord *dst, const uint32_t *src, uint32_t requested)
{
    uint32_t count = src[2];
    uint32_t bytes = count * 0x1Cu;

    dst->buffer = Heap_AllocAlt(bytes);
    if (dst->buffer == 0) {
        /* Original calls the common fatal/error routine here. */
        extern void Runtime_Fatal(uint32_t code, uint32_t a, uint32_t b);
        Runtime_Fatal(0, count, bytes);
        return;
    }

    dst->item_count = *(uint32_t *)dst->buffer;
    dst->stride = (uint16_t)count;
    dst->src = src;
    dst->cursor = 0;
    dst->capacity = 0x80;
    dst->requested = (uint16_t)requested;

    /* Each 0x1c-byte entry is initialized from the source descriptor. */
    uint8_t *entry = (uint8_t *)dst->buffer;
    for (uint32_t i = 0; i < count; ++i) {
        *(uint32_t *)(entry + 0x00) = src[2];
        *(uint32_t *)(entry + 0x04) = src[3];
        *(uint32_t *)(entry + 0x08) = 0;
        *(uint32_t *)(entry + 0x0C) = 0;
        *(uint32_t *)(entry + 0x10) = 0;
        *(uint32_t *)(entry + 0x14) = 0;
        entry += 0x1C;
    }
}
