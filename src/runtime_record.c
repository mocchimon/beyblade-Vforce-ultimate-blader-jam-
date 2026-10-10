#include <stdint.h>

/*
 * Recovered from 0x0805AC4C and 0x0805AC80.
 *
 * The first helper allocates a 0x10-byte record from the alternate heap.
 * Heap_AllocAlt returns a descriptor, so the record payload is obtained from
 * descriptor[0]. The record layout is kept neutral: the only proven facts are
 * the exact writes performed by the original routine.
 */
typedef struct RuntimeRecord {
    uint32_t field00; /* input r0 */
    uint32_t field04; /* input r2 */
    uint16_t field08; /* low 16 bits of input r3 */
    uint8_t  padding0A[2];
    uint32_t field0C; /* input r1 */
} RuntimeRecord;

_Static_assert(sizeof(RuntimeRecord) == 0x10, "runtime record must be 0x10 bytes");

extern void *Heap_AllocAlt(uint32_t size);
extern void sub_08057B60(const void *message);

/* 0x0805AC4C: allocate and initialize a runtime record. */
RuntimeRecord *RuntimeRecord_Create(uint32_t field00, uint32_t field0C,
                                    uint32_t field04, uint32_t field08)
{
    void *descriptor = Heap_AllocAlt(0x10);
    RuntimeRecord *record;

    /* The original dereferences the descriptor directly; the allocator's
       failure path is expected to be non-returning. */
    record = (RuntimeRecord *)(uintptr_t)*(uint32_t *)descriptor;
    if (record == 0)
        sub_08057B60((const void *)0x0875536Cu);

    record->field00 = field00;
    record->field04 = field04;
    record->field08 = (uint16_t)field08;
    record->field0C = field0C;
    return record;
}

/* 0x0805AC80: store the current record/context pointer. */
void RuntimeRecord_SetCurrent(void *record)
{
    *(volatile void **)0x03005DC0u = record;
}
