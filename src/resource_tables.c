#include "gba.h"
#include <stdint.h>

/* These helper meanings are intentionally unresolved. */
void ResourceTable_Generate(void *context, uint32_t index,
                            uint32_t *out_a, uint32_t *out_b);
uint32_t ResourceTable_Transform(uint32_t value);
uint32_t ResourceTable_Combine(uint32_t value, void *context);

/*
 * Resource-table setup recovered from 0x080623CC.
 *
 * This routine iterates 0x80 entries. Each entry is populated from a
 * generated pair of values and written into the table pointed to by
 * 0x03000D98. The exact semantic meaning of the generated values is not
 * established yet, so this remains deliberately neutral.
 */
void ResourceTable_Init(void *context)
{
    uint32_t *dst = *(uint32_t **)0x03000D98;
    uint32_t i;

    for (i = 0; i < 0x80; ++i) {
        uint32_t a;
        uint32_t b;
        uint32_t value;

        /* Original calls a helper with the current table seed and constants. */
        ResourceTable_Generate(context, i, &a, &b);
        value = (a << 12) | (b >> 20);
        value = ResourceTable_Transform(value);
        value = ResourceTable_Combine(value, context);
        *dst++ = value;
    }

    *(uint32_t *)0x03000D90 = *(uint32_t *)0x03000D94;
    *(uint32_t *)0x03000D94 = 0x4000 - *(uint16_t *)0x03005E4C;
    *(uint16_t *)0x03000DA2 = (uint16_t)(uintptr_t)0x03000D98;
    *(uint16_t *)0x03000DA0 = 0x100;
}

