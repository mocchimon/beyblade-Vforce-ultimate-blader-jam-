#include <stdint.h>

/* ROM 0x08060958. Initialize the 0x400-unit free-range arena and
 * 31 recycled 8-byte descriptors in a caller-provided IWRAM pool.
 * Existing resource nodes have their range tokens released first.
 */
#define G32(a) (*(volatile uint32_t *)(uintptr_t)(a))
#define G16(a) (*(volatile uint16_t *)(uintptr_t)(a))

extern void RuntimeRange_Release(int32_t token, uint32_t amount);

void RuntimeRange_Reset(uint32_t reserved)
{
    uint32_t object = G32(0x03005DE4u);
    reserved = (uint16_t)reserved;
    while (object) {
        uint16_t flags = G16(object + 0x20u);
        if (!(flags & 1u)) {
            int32_t token = (int32_t)G32(object + 0x24u);
            if (token >= 0) {
                uint32_t size_shift = (uint16_t)(G16(object + 0x16u) - 5u);
                RuntimeRange_Release(token, 1u << (size_shift & 31u));
            }
            G32(object + 0x24u) = UINT32_MAX;
        }
        object = G32(object + 4u);
    }

    G32(0x03005E6Cu) = reserved;
    uint32_t pool = G32(0x03005DCCu);
    if (!pool)
        return;

    G32(0x03005DC8u) = pool;
    G32(0x03005DD8u) = pool + 8u;
    G16(pool) = (uint16_t)reserved;
    G16(pool + 2u) = (uint16_t)(0x400u - reserved);
    G32(pool + 4u) = 0;

    /* r3 starts at 0x1d and loops 30 times, linking 31 spare nodes. */
    uint32_t node = pool + 8u;
    for (unsigned i = 0; i < 30; ++i) {
        uint32_t next = node + 8u;
        G32(node + 4u) = next;
        node = next;
    }
    G32(node + 4u) = 0;
}
