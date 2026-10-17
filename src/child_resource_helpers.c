#include <stdint.h>

#include "child_resource_helpers.h"

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

/* 0x080599CC. Returns the selected BGxHOFS register address. */
uintptr_t ChildResource_HorizontalOffsetRegister(uint32_t mode)
{
    switch ((uint8_t)mode) {
    case 0: return 0x04000010u;
    case 1: return 0x04000014u;
    case 2: return 0x04000018u;
    case 3: return 0x0400001Cu;
    default: return (uint8_t)mode;
    }
}

/* 0x08059A0C. Returns the selected BGxVOFS register address. */
uintptr_t ChildResource_VerticalOffsetRegister(uint32_t mode)
{
    switch ((uint8_t)mode) {
    case 0: return 0x04000012u;
    case 1: return 0x04000016u;
    case 2: return 0x0400001Au;
    case 3: return 0x0400001Eu;
    default: return (uint8_t)mode;
    }
}

/* 0x08059A4C. Returns the selected BGxCNT register address. */
uintptr_t ChildResource_BackgroundControlRegister(uint32_t mode)
{
    switch ((uint8_t)mode) {
    case 0: return 0x04000008u;
    case 1: return 0x0400000Au;
    case 2: return 0x0400000Cu;
    case 3: return 0x0400000Eu;
    default: return (uint8_t)mode;
    }
}
