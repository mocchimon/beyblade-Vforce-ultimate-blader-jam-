#include <stddef.h>
#include <stdint.h>

#include "runtime_object_records.h"

typedef struct RuntimeObjectRecordArrayHeader {
    uint16_t unknown00;
    uint16_t count_a;          /* +0x02 */
    uint16_t count_b;          /* +0x04 */
    uint8_t unknown06[6];
    uint8_t *records;          /* +0x0C */
} RuntimeObjectRecordArrayHeader;

typedef struct RuntimeObjectRecord {
    uint8_t unknown00[0x14];
    uint32_t value14;          /* +0x14 */
    uint32_t value18;          /* +0x18 */
    uint32_t value1C;          /* +0x1C */
    uint32_t value20;          /* +0x20 */
    uint32_t scale24;          /* +0x24 */
    uint8_t unknown28[0x2C];
    uint32_t mirror54;         /* +0x54 */
    uint32_t mirror58;         /* +0x58 */
    uint8_t unknown5C[8];
    uint16_t flags64;          /* +0x64 */
} RuntimeObjectRecord;

_Static_assert(offsetof(RuntimeObjectRecordArrayHeader, records) == 0x0C,
               "record-array header pointer must be at +0x0C");
_Static_assert(offsetof(RuntimeObjectRecord, value14) == 0x14,
               "record field must be at +0x14");
_Static_assert(offsetof(RuntimeObjectRecord, value18) == 0x18,
               "record field must be at +0x18");
_Static_assert(offsetof(RuntimeObjectRecord, value1C) == 0x1C,
               "record field must be at +0x1C");
_Static_assert(offsetof(RuntimeObjectRecord, value20) == 0x20,
               "record field must be at +0x20");
_Static_assert(offsetof(RuntimeObjectRecord, scale24) == 0x24,
               "record field must be at +0x24");
_Static_assert(offsetof(RuntimeObjectRecord, mirror54) == 0x54,
               "record mirror must be at +0x54");
_Static_assert(offsetof(RuntimeObjectRecord, mirror58) == 0x58,
               "record mirror must be at +0x58");
_Static_assert(offsetof(RuntimeObjectRecord, flags64) == 0x64,
               "record flags must be at +0x64");
_Static_assert(sizeof(RuntimeObjectRecord) == 0x68,
               "record view ends at +0x68; ROM array stride is 0x88");

/* These direct Thumb callees remain outside the recovered source cluster. */
extern void sub_080596D0(RuntimeObjectRecord *record);
extern void sub_08058F84(RuntimeObjectRecord *record);

static uint32_t RuntimeObject_ArithmeticShiftRight8(uint32_t value)
{
    uint32_t shifted = value >> 8;
    if ((value & 0x80000000u) != 0)
        shifted |= 0xFF000000u;
    return shifted;
}

/* 0x08058F18. Updates two word pairs, mirrors them, then follows two
 * ROM-confirmed conditional paths. Names for the fields are intentionally
 * neutral because their gameplay purpose is not established. */
void RuntimeObject_UpdateRecord(void *record_pointer)
{
    RuntimeObjectRecord *record = (RuntimeObjectRecord *)record_pointer;
    uint32_t value14 = record->value14 + record->value1C;
    uint32_t value18 = record->value18 + record->value20;

    record->value14 = value14;
    record->value18 = value18;
    record->mirror54 = value14;
    record->mirror58 = value18;

    sub_080596D0(record);
    if ((record->flags64 & 1u) != 0)
        sub_08058F84(record);

    if (record->scale24 != 0) {
        uint32_t scaled14 = RuntimeObject_ArithmeticShiftRight8(
            record->value14 * record->scale24);
        uint32_t scaled18 = RuntimeObject_ArithmeticShiftRight8(
            record->value18 * record->scale24);
        uint32_t reduced14 = record->value14 - scaled14;
        uint32_t reduced18 = record->value18 - scaled18;

        record->value14 = reduced14;
        record->value18 = reduced18;

        /* Match the conditional stores at 0x08058F70 and 0x08058F7C. */
        if (scaled14 == 0 && reduced14 != 0)
            record->value14 = scaled14;
        if (scaled18 == 0 && reduced18 != 0)
            record->value18 = scaled18;
    }
}

/* 0x08050A74. The two halfword counts are added as unsigned values. Each
 * selected record is 0x88 bytes from the previous one. */
void RuntimeObject_UpdateRecordArray(void *header_pointer)
{
    RuntimeObjectRecordArrayHeader *header =
        (RuntimeObjectRecordArrayHeader *)header_pointer;
    uint32_t count = (uint32_t)header->count_a + header->count_b;
    uint8_t *record = header->records;

    for (uint32_t i = 0; i < count; ++i, record += 0x88)
        RuntimeObject_UpdateRecord(record);
}
