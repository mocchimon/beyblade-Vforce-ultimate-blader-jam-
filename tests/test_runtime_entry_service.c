#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

void RuntimeEntry_ServiceOne(void *entry, uint32_t end, uint32_t threshold);
#define MEM8(a) (*(volatile uint8_t *)(uintptr_t)(a))
#define MEM32(a) (*(volatile uint32_t *)(uintptr_t)(a))
#define ENTRY 0x03002000u
#define SOURCE 0x03003000u
static unsigned callback_calls;
static uint32_t seen_end, seen_threshold;
static void *seen_entry;
static void refresh(void *entry, uint32_t end, uint32_t threshold) {
    ++callback_calls;
    seen_entry = entry;
    seen_end = end;
    seen_threshold = threshold;
}
static void map_memory(uintptr_t addr, size_t len) {
    void *p = mmap((void *)addr, len, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    assert(p == (void *)addr);
}
static void setup(void) {
    memset((void *)(uintptr_t)ENTRY, 0, 0x28);
    memset((void *)(uintptr_t)SOURCE, 0, 0x100);
    callback_calls = 0;
    seen_entry = 0;
    MEM32(ENTRY) = SOURCE;
    MEM8(ENTRY + 0x16) = 1;
    MEM32(SOURCE + 4) = 0x30; /* first boundary SOURCE + 0x40 */
    MEM32(SOURCE + 8) = 0x10; /* second boundary SOURCE + 0x20 */
}
static void invoke(void) {
    RuntimeEntry_ServiceOne((void *)(uintptr_t)ENTRY, 87, 19);
}
int main(void) {
    map_memory(0x03000000, 0x10000);
    map_memory(0x0807D000, 0x1000);
    assert((uintptr_t)refresh <= UINT32_MAX);
    MEM32(0x0807D988) = (uint32_t)(uintptr_t)refresh;

    setup();
    MEM8(ENTRY + 0x16) = 0;
    MEM32(ENTRY + 4) = SOURCE + 0x40;
    invoke();
    assert(callback_calls == 0 && MEM32(ENTRY + 4) == SOURCE + 0x40);

    setup();
    MEM32(ENTRY + 4) = SOURCE + 0x3f;
    invoke();
    assert(callback_calls == 1 && seen_entry == (void *)(uintptr_t)ENTRY);
    assert(seen_end == 87 && seen_threshold == 19);
    assert(MEM32(ENTRY + 4) == SOURCE + 0x3f && MEM8(ENTRY + 0x16) == 1);

    setup();
    MEM32(ENTRY + 4) = SOURCE + 0x40;
    invoke();
    assert(callback_calls == 1 && MEM32(ENTRY + 4) == SOURCE + 0x20);

    setup();
    MEM32(ENTRY + 4) = SOURCE + 0x40 + 0x47;
    invoke();
    assert(callback_calls == 1 && MEM32(ENTRY + 4) == SOURCE + 0x20 + (0x47 % 0x20));

    setup();
    MEM32(SOURCE + 8) = 0;
    MEM32(ENTRY + 4) = SOURCE + 0x40;
    invoke();
    assert(callback_calls == 1 && MEM8(ENTRY + 0x16) == 0);

    setup();
    MEM32(SOURCE + 8) = MEM32(SOURCE + 4);
    MEM32(ENTRY + 4) = SOURCE + 0x43;
    invoke();
    assert(callback_calls == 1 && MEM32(ENTRY + 4) == SOURCE + 0x40);

    puts("runtime entry service: passed status, callback, boundary, modulo, terminal, zero divisor");
    return 0;
}
