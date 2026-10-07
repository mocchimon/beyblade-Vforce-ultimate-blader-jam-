#include "gba.h"
#include <stdint.h>

/* Globals at 0x03005E64/5C/60 are initialized here. */
void RuntimeMemory_Init(void)
{
    void *large;
    void *small;

    *(uint32_t *)0x03005E64 = 0;
    *(uint32_t *)0x03005E5C = 0;
    *(uint32_t *)0x03005E60 = 0;

    /* 0xC400-byte and 0x1400-byte allocations are made by the original. */
    large = Heap_Alloc(0xC400);
    small = Heap_Alloc(0x1400);

    if (large == 0)
        FatalError(0x0875485E);
    if (small == 0)
        FatalError(0x08755E78);

    *(void **)0x03005E68 = large;
    *(void **)0x03005E54 = small;
    *(uint32_t *)0x03005E58 = 0;

    /* Descriptor passed to the following pool initialization code. */
    *(void **)0x03005E64 = (void *)0x030400D4;
    *(uint32_t *)0x03005E68 = (uint32_t)(uintptr_t)small;
    *(uint32_t *)0x03005E6C = 0x00000500;
}

void *Heap_Alloc(uint32_t size);
void FatalError(uint32_t code);
