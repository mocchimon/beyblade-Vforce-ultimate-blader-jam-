#include <stdint.h>

extern int32_t RuntimeEntry_Alloc(uint32_t source, uint32_t index);

/* 0x08062C20: resolve one descriptor table entry and allocate its runtime entry. */
void RuntimeTable_AllocateIndexed(uint32_t table_index,
                                  uint32_t entry_index)
{
    uint32_t descriptor =
        *(volatile const uint32_t *)(uintptr_t)0x03005E14u;
    uint32_t count;
    uint32_t table;
    uint32_t source;

    count = *(volatile const uint32_t *)(uintptr_t)(descriptor + 4u);
    /* The original comparison is unsigned (BHS), matching this bounds check. */
    if (table_index >= count)
        return;

    table = *(volatile const uint32_t *)(uintptr_t)(descriptor + 0x0Cu);
    source = *(volatile const uint32_t *)(uintptr_t)
        (table + table_index * 4u);
    (void)RuntimeEntry_Alloc(source, entry_index);
}
