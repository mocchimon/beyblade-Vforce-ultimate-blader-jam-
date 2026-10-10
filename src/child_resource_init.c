#include <stdint.h>
#include "runtime.h"

typedef struct ChildResourceHeader {
    uint32_t field_00;
    uint32_t data_size;
    uint32_t field_08;
    uint32_t source_offset;
    uint8_t data[];
} ChildResourceHeader;

extern uint32_t ChildResource_SelectLayout(void *child, uint32_t arg1, uint32_t arg2);
extern uint16_t ChildResource_LayoutValueA(uint32_t index);
extern uint16_t ChildResource_LayoutValueB(uint32_t index);
extern uint16_t ChildResource_LayoutValueC(uint32_t value);

/* 0x08058ACC */
void ChildResource_Init(void *child, uint32_t index, const ChildResourceHeader *src,
                        uint32_t flags, uint32_t x, uint32_t y)
{
    uint8_t *c = (uint8_t *)child;
    const uint8_t *s = (const uint8_t *)src;
    uint32_t nested;
    uint32_t layout_size;

    *(uint32_t *)(c + 0x68) = (uint32_t)src;
    *(uint16_t *)(c + 0x64) = s[0x18];
    layout_size = ChildResource_SelectLayout(child, (uint16_t)flags, *(uint16_t *)(c + 0x64));
    (void)layout_size;
    nested = index * 0x18u + *(const uint32_t *)(0x03000CA0u);
    *(uint32_t *)(c + 0x08) = nested;

    *(uint32_t *)(nested + 0x00) = 0;
    *(uint32_t *)(nested + 0x04) = 0;
    *(uint32_t *)(nested + 0x10) = 0;
    *(uint32_t *)(nested + 0x14) = 0;
    *(uint32_t *)(nested + 0x08) = (1u << *(uint8_t *)(c + 0x5F)) - 1u;
    *(uint32_t *)(nested + 0x0C) = (1u << *(uint8_t *)(c + 0x60)) - 1u;

    *(uint32_t *)(c + 0x00) = *(const uint16_t *)(s + 0x1C);
    *(uint32_t *)(c + 0x04) = *(const uint16_t *)(s + 0x1E);
    *(uint8_t *)(c + 0x5E) = (uint8_t)index;
    *(uint32_t *)(c + 0x0C) = 0; *(uint32_t *)(c + 0x10) = 0; *(uint32_t *)(c + 0x14) = 0;
    *(uint32_t *)(c + 0x18) = 0; *(uint32_t *)(c + 0x1C) = 0; *(uint32_t *)(c + 0x20) = 0;
    *(uint32_t *)(c + 0x54) = 0; *(uint32_t *)(c + 0x58) = 0;
    *(uint32_t *)(c + 0x24) = 0x10; *(uint32_t *)(c + 0x28) = 0; *(uint32_t *)(c + 0x2C) = 0;
    *(uint32_t *)(c + 0x30) = 0x10000; *(uint32_t *)(c + 0x34) = 0x10000;
    *(uint32_t *)(c + 0x38) = 0; *(uint32_t *)(c + 0x3C) = 0;
    *(uint16_t *)(c + 0x48) = 0; *(uint16_t *)(c + 0x4A) = 0;
    *(uint32_t *)(c + 0x4C) = 0; *(uint32_t *)(c + 0x50) = 0;
    *(uint8_t *)(c + 0x7C) = (uint8_t)(x & 0x0C);
    *(int32_t *)(c + 0x80) = -1; *(uint32_t *)(c + 0x84) = 0;

    /* +04 is the inline-data length.  The original uses the raw length here;
       table placement itself rounds the complete 0x10+length record to 4 bytes. */
    *(uint32_t *)(c + 0x6C) = (uint32_t)(s + *(const uint32_t *)(s + 0x04));
    *(uint32_t *)(c + 0x74) = *(const uint32_t *)(s + 0x08);
    *(uint32_t *)(c + 0x70) = (uint32_t)(s + *(const uint32_t *)(s + 0x0C));
    *(uint32_t *)(c + 0x78) = *(const uint32_t *)(s + 0x10);
    *(uint8_t *)(c + 0x5D) = *(uint8_t *)0x03000DE0u;
    *(uint8_t *)(c + 0x61) = s[0x14];
    (void)flags; (void)y;
}
