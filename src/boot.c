#include <stdint.h>

/* Semantic reconstruction of the cartridge relocation stub. */
void Boot_RelocateStartup(void)
{
    const uint32_t *src = (const uint32_t *)0x087FE7E4;
    uint32_t *dst = (uint32_t *)0x020000C0;
    uint32_t bytes = 0x184C;

    while (bytes != 0) {
        *dst++ = *src++;
        bytes -= 4;
    }

    ((void (*)(void))0x020000C0)();
}
