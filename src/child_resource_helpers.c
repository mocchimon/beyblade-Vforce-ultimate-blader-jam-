#include <stdint.h>

/*
 * 0x080592A8
 *
 * Selects the per-child tile/plane dimensions from the resource mode and
 * stores the resulting bit counts in child+0x5F/+0x60.  The return value is
 * the corresponding byte-size class.  These values are derived directly
 * from the switch in the ROM; their final graphics semantic is still being
 * traced.
 */
uint32_t ChildResource_SelectLayout(void *child, uint32_t arg1, uint32_t arg2)
{
    uint8_t *c = (uint8_t *)child;
    uint32_t mode = (arg1 << 16) >> 30;
    uint32_t parity = ((arg2 << 16) >> 16) & 1u;

    if (parity) {
        uint32_t shift = (mode << 1) + 8;
        c[0x5F] = (uint8_t)(mode + 4);
        return 1u << shift;
    }

    switch (mode) {
    case 0:
        c[0x5F] = 5;
        return 0x800;
    case 1:
        c[0x5F] = 6;
        c[0x60] = 5;
        return 0x1000;
    case 2:
        c[0x5F] = 5;
        c[0x60] = 6;
        return 0x1000;
    case 3:
        c[0x5F] = 6;
        c[0x60] = 6;
        return 0x2000;
    default:
        return 0;
    }
}

/* 0x080599CC / 0x08059A0C / 0x08059A4C */
uint16_t ChildResource_LayoutValueA(uint32_t index)
{
    switch ((uint8_t)index) {
    case 0: return 0x1000;
    case 1: return 0x1400;
    case 2: return 0x1800;
    case 3: return 0x1C00;
    default: return 0;
    }
}

uint16_t ChildResource_LayoutValueB(uint32_t index)
{
    switch ((uint8_t)index) {
    case 0: return 0x1200;
    case 1: return 0x1600;
    case 2: return 0x1A00;
    case 3: return 0x1E00;
    default: return 0;
    }
}

uint16_t ChildResource_LayoutValueC(uint32_t index)
{
    switch ((uint8_t)index) {
    case 0: return 0x0800;
    case 1: return 0x0A00;
    case 2: return 0x0C00;
    case 3: return 0x0E00;
    default: return 0;
    }
}
