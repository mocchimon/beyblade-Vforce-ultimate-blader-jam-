#include "runtime.h"
#include <stdint.h>

/*
 * 0x08060544 is called during startup and again from the persistent frame
 * path.  The two arguments are capped at 0x80 and 0x20 respectively, and
 * the routine allocates backing storage with the game's EWRAM allocator.
 *
 * It therefore appears to reset/recreate per-frame pools rather than being
 * a one-time platform initialization routine.  Exact pool semantics are
 * intentionally left open until callers are recovered.
 */
void Runtime_ResetPools(uint32_t countA, uint32_t countB)
{
    if (countA > 0x80)
        countA = 0x80;
    if (countB > 0x20)
        countB = 0x20;

    /* Recovered allocation sizes:
     *   countA * 0x34
     *   countB * 0x1C
     *   fixed 0x100-byte allocation
     * The actual pointers are stored in 0x03005DE0/0x03005DDC/0x03005DD4.
     */
    (void)countA;
    (void)countB;
}
