#include <stdint.h>
#include "gba.h"
#include "runtime.h"
#include "runtime_record.h"

/*
 * Recovered from 0x08050388-0x080504E6.  The manager keeps the alternate
 * heap descriptor at +0x00 and its payload address at +0x08.
 */
typedef struct RuntimeSourceNode RuntimeSourceNode;
struct RuntimeSourceNode {
    uint32_t unknown0;             /* +0x00 */
    RuntimeSourceNode *next;       /* +0x04 */
    uint32_t position_x;           /* +0x08 */
    uint32_t position_y;           /* +0x0C */
};

typedef struct RuntimeAllocationDescriptor {
    uint32_t address;              /* +0x00 */
    uint32_t size;                 /* +0x04 */
    uint32_t previous;             /* +0x08 */
    uint32_t next;                 /* +0x0C */
} RuntimeAllocationDescriptor;

typedef struct RuntimeSubRecord {
    uint32_t position_x;           /* +0x00 */
    uint32_t position_y;           /* +0x04 */
    uint32_t velocity_x;           /* +0x08 */
    uint32_t velocity_y;           /* +0x0C */
    uint32_t acceleration_x;       /* +0x10 */
    uint32_t acceleration_y;       /* +0x14 */
} RuntimeSubRecord;

struct RuntimeRecordManager {
    RuntimeAllocationDescriptor *allocation; /* +0x00 */
    const uint32_t *source;                   /* +0x04 */
    RuntimeSubRecord *records;                /* +0x08 */
    int16_t count;                            /* +0x0C */
    uint16_t flags;                           /* +0x0E */
    uint32_t boundary;                        /* +0x10 */
    uint32_t bounce_scale;                    /* +0x14 */
};

_Static_assert(sizeof(RuntimeRecordManager) == 0x18,
               "runtime record manager must be 0x18 bytes");
_Static_assert(sizeof(RuntimeSubRecord) == 0x18,
               "runtime sub-record must be 0x18 bytes");

void RuntimeRecord_Clear(volatile RuntimeRecordManager *m)
{
    m->source = 0;
    m->flags = 0;
    m->records = 0;
    m->count = 0;
    m->bounce_scale = 0;
    m->boundary = 0;
}

void RuntimeRecord_Init(RuntimeRecordManager *m,
                        const uint32_t *source, uint16_t flags)
{
    uint32_t count = source[2];
    uint32_t bytes = count * 0x18u;
    RuntimeAllocationDescriptor *allocation;

    /* The zero-size path reports and returns before writing the manager. */
    if (bytes == 0) {
        sub_08057C5C((const void *)(uintptr_t)0x087270A4u);
        return;
    }

    allocation = (RuntimeAllocationDescriptor *)Heap_AllocAlt(bytes);
    m->allocation = allocation;
    if (allocation == 0) {
        sub_08057C5C((const void *)(uintptr_t)0x087270DCu, bytes, count);
        return;
    }

    m->records = (RuntimeSubRecord *)(uintptr_t)allocation->address;
    m->source = source;
    m->count = (int16_t)count;
    m->boundary = 0;
    m->bounce_scale = 0x80;
    m->flags = flags;

    /* The source descriptor points to a linked list of coordinate pairs. */
    RuntimeSourceNode *node =
        (RuntimeSourceNode *)(uintptr_t)source[0];
    for (int32_t i = 0; i < m->count; ++i) {
        RuntimeSubRecord *record = &m->records[i];
        record->velocity_x = 0;
        record->velocity_y = 0;
        record->acceleration_x = 0;
        record->acceleration_y = 0;
        record->position_x = node->position_x;
        record->position_y = node->position_y;
        node = node->next;
    }
}

/* Arithmetic shift used by the ROM's ASRS #8 after its 32-bit multiply. */
static int32_t RuntimeRecord_ArithmeticShiftRight8(uint32_t value)
{
    if ((value & 0x80000000u) != 0)
        return -1 - (int32_t)((~value) >> 8);
    return (int32_t)(value >> 8);
}

/* Interpret a 32-bit ARM result as signed without relying on a narrowing cast. */
static int32_t RuntimeRecord_SignedValue(uint32_t value)
{
    if ((value & 0x80000000u) != 0)
        return -1 - (int32_t)(~value);
    return (int32_t)value;
}

/*
 * 0x08050420 integrates each 0x18-byte record, mirrors its position to the
 * source list, and optionally clamps/reverses one axis at the manager boundary.
 */
void RuntimeRecord_Update(RuntimeRecordManager *m)
{
    RuntimeSubRecord *record = m->records;
    RuntimeSourceNode *node = (RuntimeSourceNode *)(uintptr_t)m->source[0];
    const uint16_t flags = m->flags;
    const int16_t count = m->count;

    for (int32_t i = 0; i < count; ++i, ++record) {
        record->position_x += record->velocity_x;
        record->position_y += record->velocity_y;
        record->velocity_x += record->acceleration_x;
        record->velocity_y += record->acceleration_y;

        /* The ROM copies these integrated values before boundary handling. */
        node->position_x = record->position_x;
        node->position_y = record->position_y;

        if ((flags & 3u) != 0) {
            uint32_t *position = (flags & 1u) != 0
                ? &record->position_x : &record->position_y;
            uint32_t *velocity = (flags & 1u) != 0
                ? &record->velocity_x : &record->velocity_y;
            uint32_t start_bits = *position - m->boundary;
            uint32_t end_bits = *position + *velocity - m->boundary;
            int32_t start = RuntimeRecord_SignedValue(start_bits);
            int32_t end = RuntimeRecord_SignedValue(end_bits);
            int crossed;

            if (start > 0)
                crossed = end < 0;
            else if (end > 0)
                crossed = 1;
            else if (start < 0)
                crossed = 0;
            else
                crossed = end < 0;

            if (crossed) {
                uint32_t reflected_velocity = 0;
                if ((flags & 4u) != 0) {
                    uint32_t product = m->bounce_scale * *velocity;
                    reflected_velocity = 0u - product;
                    reflected_velocity = (uint32_t)
                        RuntimeRecord_ArithmeticShiftRight8(reflected_velocity);
                }
                *position = m->boundary;
                *velocity = reflected_velocity;
            }
        }

        node = node->next;
    }
}
