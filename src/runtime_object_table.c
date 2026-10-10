#include "runtime.h"
#include <stdint.h>

/*
 * Recovered from 0x08062490.
 *
 * The descriptor itself is at 0x03005E40.  The function receives a base
 * pointer and an entry count; the count is capped at 0x10 and the base is
 * capped at 0x0000ABEA before being stored in the descriptor.
 *
 * The exact purpose of the table is still unresolved, so the fields retain
 * neutral names and the helper calls remain explicit rather than guessed.
 */
typedef struct RuntimeObjectDescriptor {
    uint32_t base;
    uint32_t enabled;
    uint32_t reserved;
} RuntimeObjectDescriptor;

#define RUNTIME_OBJECT_DESC ((RuntimeObjectDescriptor *)0x03005E40u)
#define RUNTIME_OBJECT_COUNT (*(uint8_t *)0x03005E04u)
#define RUNTIME_OBJECT_BASE (*(uint32_t *)0x03005E50u)
#define RUNTIME_OBJECT_AUX  (*(uint32_t *)0x03005E24u)
#define RUNTIME_OBJECT_TABLE (*(uint32_t **)0x03000D98u)

void RuntimeObject_Prepare(void);
void *Heap_AllocAlt(uint32_t size);
void FatalError(uint32_t code);
void ResourceTable_Init(void *context);

/*
 * 0x08062370. Reset/release path called before RuntimeObjectTable_Init.
 * The globals at +0x2C/+0x30 hold heap descriptors; the values copied into
 * +0x1C/+0x28 are payload addresses and must not be passed to Heap_Free.
 */
void RuntimeObject_Prepare(void)
{
    void **table_descriptor = (void **)0x03005E2Cu;
    void **aux_descriptor = (void **)0x03005E30u;

    if (*table_descriptor != 0) {
        *(volatile uint32_t *)0x040000C4u = 0;
        *(volatile uint32_t *)0x040000D0u = 0;
        *(volatile uint32_t *)0x04000104u = 0;
        *(volatile uint32_t *)0x04000100u = 0;
        Heap_Free(*table_descriptor);
        if (*aux_descriptor != 0)
            Heap_Free(*aux_descriptor);
        *(uint32_t *)0x03005E28u = 0;
        *(uint32_t *)0x03005E1Cu = 0;
        *(uint32_t *)0x03005E50u = 0;
        *table_descriptor = 0;
    }
}

void RuntimeObjectTable_Init(void *base, uint32_t count)
{
    void *table;
    void *aux;

    /* 0x08062370 releases any prior table state and stops associated HW. */
    RuntimeObject_Prepare();

    if (count > 0x10)
        count = 0x10;

    if ((uintptr_t)base > 0x0000ABEAu)
        base = (void *)0x0000ABEAu;

    RUNTIME_OBJECT_DESC->base = (uint32_t)(uintptr_t)base;
    RUNTIME_OBJECT_DESC->enabled = 1;
    RUNTIME_OBJECT_DESC->reserved = 0;

    /*
     * The ROM computes n = round_up(base / 0x28, 0x10), stores n at
     * 0x03005E4C and -n at 0x03005E18, then requests 3*n + 40*count bytes
     * from the main heap. 0x080661E4 is the unsigned division helper, not an
     * allocator; the allocation call itself is Heap_Alloc at 0x0805A3CC.
     */
    {
        uint32_t n = ((uint32_t)(uintptr_t)base / 0x28u + 0x0Fu) & ~0x0Fu;
        *(uint16_t *)0x03005E4Cu = (uint16_t)n;
        *(uint16_t *)0x03005E18u = (uint16_t)(0u - n);
        table = Heap_Alloc(3u * n + 40u * count);
    }

    *(void **)0x03005E2Cu = table;
    if (table == 0)
        FatalError(0x08755DB4u);

    *(uint32_t *)0x03005E1Cu = *(uint32_t *)table;

    aux = Heap_AllocAlt(0x440);
    *(void **)0x03005E30u = aux;
    if (aux == 0)
        FatalError(0x08755DE8u);

    *(uint32_t *)0x03005E28u = *(uint32_t *)aux;
    *(uint32_t *)0x03005E50u = *(uint32_t *)0x03005E1Cu + 0x200;
    *(uint32_t *)0x03000D98u = *(uint32_t *)0x03005E50u;
    *(uint8_t *)0x03005E04u = (uint8_t)count;

    /* These are literal descriptor values written by the original. */
    *(uint32_t *)0x040000D4u = 0;
    *(uint32_t *)0x040000D8u = *(uint32_t *)0x03005E50u;
    *(uint32_t *)0x040000DCu = 0x85000500u;

    ResourceTable_Init(base);

    *(uint16_t *)0x03000DA0u = 0x80;
    *(uint16_t *)0x03000D9Eu = (uint16_t)0x03004000u; /* stored as a halfword by ROM */
    *(uint32_t *)0x03000DD8u = *(uint32_t *)0x03005E50u;
}
