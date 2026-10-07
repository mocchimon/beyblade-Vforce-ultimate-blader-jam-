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

void *RuntimeObject_Alloc(uint32_t size);
void RuntimeObject_Prepare(void);
void FatalError(uint32_t code);
void ResourceTable_Init(void *context);

void RuntimeObjectTable_Init(void *base, uint32_t count)
{
    void *table;
    void *aux;

    /* 0x08062370 is called before the argument checks. */
    RuntimeObject_Prepare();

    if (count > 0x10)
        count = 0x10;

    if ((uintptr_t)base > 0x0000ABEAu)
        base = (void *)0x0000ABEAu;

    RUNTIME_OBJECT_DESC->base = (uint32_t)(uintptr_t)base;
    RUNTIME_OBJECT_DESC->enabled = 1;
    RUNTIME_OBJECT_DESC->reserved = 0;

    /*
     * Exact expression recovered from 0x624E0..0x624EE is:
     *     3 * descriptor_count + 5 * count, with the former derived from
     *     the 16-bit value at 0x03005E4C, followed by an allocation.
     * Keep the machine-level expression documented rather than hiding it
     * behind an invented semantic structure.
     */
    {
        uint32_t n = *(uint16_t *)0x03005E4Cu;
        uint32_t bytes = (3u * n + (5u * count)) << 3;
        table = RuntimeObject_Alloc(bytes);
    }

    *(void **)0x03005E2Cu = table;
    if (table == 0)
        FatalError(0x08755DB4u);

    *(uint32_t *)0x03005E1Cu = *(uint32_t *)table;

    aux = RuntimeObject_Alloc(0x440);
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
    *(uint16_t *)0x03000D9Eu = 0x03004000u; /* stored as a halfword by ROM */
    *(uint32_t *)0x03000DD8u = *(uint32_t *)0x03005E50u;
}
