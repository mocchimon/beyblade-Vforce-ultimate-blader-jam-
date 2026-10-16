#include <stdint.h>
#include <stddef.h>

/* 0x08057B54: str r1,[r0]; str r2,[r0,#4]; bx lr.
 * Two 32-bit stores; caller must provide at least eight writable bytes. */
void sub_08057B54(uint32_t *destination, uint32_t first, uint32_t second) {
    destination[0] = first;
    destination[1] = second;
}

/* 0x08057C64: ldr r0,=0x03000E30; ldr r0,[r0]; bx lr. */
uint32_t sub_08057C64(void) {
    return *(volatile const uint32_t *)(uintptr_t)0x03000E30u;
}

/* 0x08057C70: ldr r0,=0x04000006; ldrh r0,[r0]; bx lr.
 * Hardware VCOUNT register (current scanline). */
uint16_t sub_08057C70(void) {
    return *(volatile const uint16_t *)(uintptr_t)0x04000006u;
}
