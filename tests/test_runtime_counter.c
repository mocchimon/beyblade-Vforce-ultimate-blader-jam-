#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>

void sub_08057B78(void);
void sub_08057B88(void);

int main(void) {
    void *p = mmap((void *)(uintptr_t)0x03000000u, 0x10000,
                   PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
    assert(p != MAP_FAILED);
    volatile uint32_t *const counter = (volatile uint32_t *)(uintptr_t)0x03000EE0u;
    counter[0] = 41u;
    counter[1] = 0xDEADBEEFu;
    sub_08057B88();
    assert(counter[0] == 42u && counter[1] == 0xDEADBEEFu);
    counter[0] = UINT32_MAX;
    sub_08057B88();
    assert(counter[0] == 0u && counter[1] == 0xDEADBEEFu);
    counter[0] = 123u;
    sub_08057B78();
    assert(counter[0] == 0u && counter[1] == 0u);
    assert(munmap(p, 0x10000) == 0);
    puts("runtime counter host tests: PASS");
    return 0;
}
