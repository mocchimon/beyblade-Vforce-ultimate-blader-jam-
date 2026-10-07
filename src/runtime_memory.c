#include "gba.h"
#include <stdint.h>

/*
 * 0x08062E94.  This routine has a much smaller, cleaner contract than the
 * earlier draft suggested. It clears three globals, allocates two buffers,
 * checks both results, then installs their first words into runtime globals
 * and builds a descriptor at 0x040000D4.
 */
void *Heap_AllocAlt(uint32_t size);
void FatalError(uint32_t code);

void RuntimeMemory_Init(void)
{
    void *large;
    void *small;

    *(uint32_t *)0x03005E64u = 0;
    *(uint32_t *)0x03005E5Cu = 0;
    *(uint32_t *)0x03005E60u = 0;

    large = Heap_AllocAlt(0xC400);
    small = Heap_AllocAlt(0x1400);

    if (large == 0)
        FatalError(0x08755E48u);
    if (small == 0)
        FatalError(0x08755E78u);

    *(uint32_t *)0x03005E68u = *(uint32_t *)large;
    *(uint32_t *)0x03005E54u = *(uint32_t *)small;
    *(uint32_t *)0x03005E58u = 0;

    /* Exact literal descriptor writes. */
    *(uint32_t *)0x040000D4u = 0;
    *(uint32_t *)0x040000D8u = *(uint32_t *)small;
    *(uint32_t *)0x040000DCu = 0x85000500u;
}
