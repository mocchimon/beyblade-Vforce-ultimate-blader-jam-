#include <stdint.h>
#include "gba.h"
#include "runtime.h"

/*
 * Recovered from 0x08050388/0x08050398.
 *
 * The manager owns an array of 0x18-byte records.  The previous draft
 * incorrectly called these 0x1c-byte records; the ROM's allocation is
 * source->count * 0x18 and the initialization loop advances by 0x18.
 */
typedef struct RuntimeSubRecord {
    uint32_t value0;       /* +0x00 */
    uint32_t value1;       /* +0x04 */
    uint32_t value2;       /* +0x08 */
    uint32_t value3;       /* +0x0C */
    uint32_t step0;        /* +0x10 */
    uint32_t step1;        /* +0x14 */
} RuntimeSubRecord;

typedef struct RuntimeRecordManager {
    RuntimeSubRecord *records; /* +0x00 */
    const uint32_t *source;    /* +0x04 */
    uint32_t source_value;     /* +0x08 */
    int16_t count;             /* +0x0C */
    uint16_t requested;        /* +0x0E */
    uint32_t cursor;           /* +0x10 */
    uint32_t capacity;         /* +0x14 */
} RuntimeRecordManager;

void RuntimeRecord_Clear(RuntimeRecordManager *m)
{
    m->source_value = 0;
    m->count = 0;
    m->requested = 0;
    m->capacity = 0;
    m->cursor = 0;
    m->records = 0;
}

void RuntimeRecord_Init(RuntimeRecordManager *m,
                        const uint32_t *src, uint16_t requested)
{
    uint32_t count = src[2];
    uint32_t bytes = count * sizeof(RuntimeSubRecord);
    RuntimeSubRecord *records;

    m->source = src;
    m->requested = requested;

    if (bytes == 0) {
        records = 0;
    } else {
        void *allocation = Heap_AllocAlt(bytes);
        records = allocation != 0
            ? (RuntimeSubRecord *)(uintptr_t)*(uint32_t *)allocation
            : 0;
    }

    m->records = records;
    if (records == 0 && bytes != 0) {
        extern void Runtime_Fatal(uint32_t code, uint32_t a, uint32_t b);
        Runtime_Fatal(0, count, bytes);
        return;
    }

    m->source_value = records ? records->value0 : 0;
    m->count = (int16_t)count;
    m->cursor = 0;
    m->capacity = 0x80;

    for (uint32_t i = 0; i < count; ++i) {
        records[i].value0 = src[2];
        records[i].value1 = src[3];
        records[i].value2 = 0;
        records[i].value3 = 0;
        records[i].step0 = 0;
        records[i].step1 = 0;
    }
}

/*
 * 0x08050420 advances each 0x18-byte record.  It consumes the source's
 * 0x0e flag field and updates the two fixed-point coordinate pairs in each
 * sub-record.  The full higher-level meaning is still unresolved, so the
 * public name remains neutral.
 */
void RuntimeRecord_Update(RuntimeRecordManager *m)
{
    RuntimeSubRecord *r = m->records;
    const uint16_t flags = m->requested;
    const uint32_t count = (uint16_t)m->count;

    if (!r)
        return;

    for (uint32_t i = 0; i < count; ++i, ++r) {
        uint32_t x = r->value0 + r->value2;
        uint32_t y = r->value1 + r->value3;
        r->value0 = x;
        r->value1 = y;

        if (flags & 1) {
            /* Direction/axis selection is encoded in the low flag bits. */
            r->value0 += r->step0;
            r->value1 += r->step1;
        }
    }
}
