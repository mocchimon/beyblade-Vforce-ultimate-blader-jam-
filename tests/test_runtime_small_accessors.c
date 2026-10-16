#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

void sub_08057B54(uint32_t *, uint32_t, uint32_t);
uint32_t sub_08057C64(void);
uint16_t sub_08057C70(void);

static void *map_gba_page(uintptr_t address) {
    void *p = mmap((void *)address, 4096, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    if (p == MAP_FAILED) { perror("mmap"); exit(1); }
    return p;
}

int main(void) {
    uint32_t words[] = {0, 0, 0xabcdef01u};
    sub_08057B54(words, 0x11223344u, 0x55667788u);
    if (words[0] != 0x11223344u || words[1] != 0x55667788u || words[2] != 0xabcdef01u) return 1;
    map_gba_page(0x03000000u);
    map_gba_page(0x04000000u);
    *(volatile uint32_t *)(uintptr_t)0x03000E30u = 0xDEADBEEFu;
    *(volatile uint16_t *)(uintptr_t)0x04000006u = 0x00A0u;
    if (sub_08057C64() != 0xDEADBEEFu || sub_08057C70() != 0x00A0u) return 2;
    *(volatile uint16_t *)(uintptr_t)0x04000006u = 0x00E3u;
    if (sub_08057C70() != 0x00E3u) return 3;
    puts("runtime small accessors: PASS");
    return 0;
}
