#include <stdint.h>

/* Recovered 0x28-byte runtime-entry pool.  The original names are unknown. */
typedef struct RuntimeEntry {
    uint32_t source;       /* +00 */
    uint32_t source_plus10;/* +04 */
    uint32_t table_value;  /* +08 */
    uint32_t field0C;      /* +0C */
    uint16_t limit;        /* +10 */
    uint8_t  unk12[2];     /* +12 */
    uint16_t field14;      /* +14 */
    uint8_t  status;       /* +16 */
    uint8_t  field17;      /* +17 */
    uint32_t serial;       /* +18 */
    uint32_t field1C;      /* +1C */
    uint32_t field20;      /* +20 */
    uint16_t field24;      /* +24 */
    uint8_t  pad26[2];     /* +26 */
} RuntimeEntry;

#define ENTRY_BASE   (*(RuntimeEntry **)0x03005E24u)
#define ENTRY_COUNT  (*(volatile uint8_t *)0x03005E04u)
#define ENTRY_SERIAL (*(volatile uint32_t *)0x03005E9Cu)
#define TABLE_0D98   (*(uint32_t **)0x03000D98u)

/* 0x08062934: initialize an entry from a source pointer and table index. */
static void RuntimeEntry_Init(RuntimeEntry *e, uint32_t source, uint32_t index)
{
    e->status = 1;
    e->source = source;
    e->field14 = 0;
    e->field17 = 0;
    e->limit = 0x100;
    e->source_plus10 = source + 0x10;
    if (index > 0x7F)
        index = 0x7F;
    e->table_value = TABLE_0D98[index];
    e->field0C = 0;
    e->field1C = 0;
    e->field20 = 0;
    e->field24 = 0;
}

/* 0x08062974: alternate initializer using an indexed secondary table. */
static void RuntimeEntry_InitIndexed(RuntimeEntry *e, uint32_t source_table,
                                      uint32_t secondary_table)
{
    uint32_t index = *(const uint16_t *)secondary_table;
    uint32_t value = ((uint32_t *)source_table)[index];
    e->status = 1;
    e->source = value;
    e->field14 = 0;
    e->field17 = 0;
    e->limit = 0x100;
    e->source_plus10 = value + 0x10;
    /* The original clamps the secondary-table pointer itself to 0x7F before
       indexing TABLE_0D98, so a normal ROM pointer ends up selecting entry 0x7F. */
    uint32_t table_index = secondary_table > 0x7F ? 0x7F : secondary_table;
    e->table_value = TABLE_0D98[table_index];
    e->field0C = 0;
    e->field1C = source_table;
    e->field20 = secondary_table;
    e->field24 = 1;
}

/* 0x08062A74: find an active entry by its serial/handle. */
RuntimeEntry *RuntimeEntry_Find(uint32_t serial)
{
    RuntimeEntry *e = ENTRY_BASE;
    uint32_t count = ENTRY_COUNT;
    if (count == 0)
        return 0;
    while (count--) {
        if (e->status != 0 && e->serial == serial)
            return e;
        ++e;
    }
    return 0;
}

/* 0x08062A14: allocate an entry for a source and index. */
int32_t RuntimeEntry_Alloc(uint32_t source, uint32_t index)
{
    RuntimeEntry *e = ENTRY_BASE;
    int32_t remaining = (int32_t)ENTRY_COUNT - 1;
    while (remaining >= 0) {
        if (e->status == 0) {
            RuntimeEntry_Init(e, source, index);
            e->serial = ENTRY_SERIAL;
            ++ENTRY_SERIAL;
            return (int32_t)e->serial;
        }
        e++;
        --remaining;
    }
    return -1;
}

/* 0x080629B4: allocate an entry from a source pointer and a secondary table. */
int32_t RuntimeEntry_AllocIndexed(uint32_t source, uint32_t secondary_table)
{
    RuntimeEntry *e = ENTRY_BASE;
    int32_t remaining = (int32_t)ENTRY_COUNT - 1;
    while (remaining >= 0) {
        if (e->status == 0) {
            RuntimeEntry_InitIndexed(e, source, secondary_table);
            e->serial = ENTRY_SERIAL;
            ++ENTRY_SERIAL;
            return (int32_t)e->serial;
        }
        e += 1;
        --remaining;
    }
    return -1;
}

void RuntimeEntry_Deactivate(uint32_t serial)
{
    RuntimeEntry *e = RuntimeEntry_Find(serial);
    if (e)
        e->status = 0;
}

void RuntimeEntry_SetStatus2(uint32_t serial)
{
    RuntimeEntry *e = RuntimeEntry_Find(serial);
    if (e)
        e->status = 2;
}

void RuntimeEntry_AdvanceStatus(uint32_t serial)
{
    RuntimeEntry *e = RuntimeEntry_Find(serial);
    if (e && e->status == 2)
        e->status = 1;
}

void RuntimeEntry_SetLimit(uint32_t serial, uint32_t value)
{
    RuntimeEntry *e = RuntimeEntry_Find(serial);
    if (e) {
        if (value > 0x100)
            value = 0x100;
        e->limit = (uint16_t)value;
    }
}

void RuntimeEntry_SetPointer(uint32_t serial, uint32_t index)
{
    RuntimeEntry *e = RuntimeEntry_Find(serial);
    if (!e)
        return;
    if (index > 0x7F)
        index = 0x7F;
    e->table_value = TABLE_0D98[index];
}
