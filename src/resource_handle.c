#include <stdint.h>
#include "gba.h"

#define RUNTIME_CTX ((volatile uint8_t *)0x03000FB0u)

extern int32_t RuntimeEntry_AllocIndexed(uint32_t source, uint32_t secondary_table);
extern void RuntimeEntry_Deactivate(uint32_t serial);
extern void RuntimeEntry_SetLimit(uint32_t serial, uint32_t value);

/* 0x0804AF60 */
void RuntimeResource_ReleaseSelected(void)
{
    volatile uint16_t *selected = (volatile uint16_t *)(RUNTIME_CTX + 0xC26);
    if ((int16_t)*selected != -1) {
        uint32_t serial = *(volatile uint32_t *)(RUNTIME_CTX + 0xC2C);
        RuntimeEntry_Deactivate(serial);
    }
    *selected = 0xFFFFu;
}

/*
 * 0x0804AF08. The ROM table is an array of source/secondary-table pairs.
 * The runtime entry allocator returns a serial stored at +0xC2C.
 */
void RuntimeResource_Select(uint32_t index)
{
    volatile uint16_t *selected = (volatile uint16_t *)(RUNTIME_CTX + 0xC26);
    volatile uint32_t *table = (volatile uint32_t *)0x08075640u;

    RuntimeResource_ReleaseSelected();
    *selected = (uint16_t)index;

    uint32_t pair = index * 2u;
    uint32_t source = table[pair + 0];
    uint32_t secondary = table[pair + 1];
    int32_t serial = RuntimeEntry_AllocIndexed(source, secondary);
    *(volatile uint32_t *)(RUNTIME_CTX + 0xC2C) = (uint32_t)serial;

    uint16_t value = *(volatile uint16_t *)(*(volatile uint32_t *)0x03000F48u + 0x6E6u);
    RuntimeEntry_SetLimit((uint32_t)serial, value);
}
