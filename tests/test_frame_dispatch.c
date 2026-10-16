#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>

#define RAM8(a) (*(volatile uint8_t *)(uintptr_t)(a))
#define RAM16(a) (*(volatile uint16_t *)(uintptr_t)(a))
#define RAM32(a) (*(volatile uint32_t *)(uintptr_t)(a))

void FrameEvent_Service(void);
static unsigned script_calls, entry_calls, transfer_calls;
static uint32_t seen_end, seen_threshold, seen_cursor[2], seen_length[2], seen_previous[2];
static void *seen_entry;
void RuntimeScript_Service(void) { ++script_calls; }
void RuntimeEntry_ServiceOne(void *entry, uint32_t end, uint32_t threshold) {
    ++entry_calls; seen_entry = entry; seen_end = end; seen_threshold = threshold;
}
void test_transfer(uint32_t cursor, uint32_t length, uint32_t previous) {
    unsigned n = transfer_calls++;
    assert(n < 2);
    seen_cursor[n] = cursor; seen_length[n] = length; seen_previous[n] = previous;
}
static void reset_counters(void) {
    script_calls = entry_calls = transfer_calls = 0;
    seen_entry = 0; seen_end = seen_threshold = 0;
}
static void map_gba_memory(void) {
    void *p = mmap((void *)0x03000000, 0x10000, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    assert(p == (void *)0x03000000);
    p = mmap((void *)0x04000000, 0x10000, PROT_READ | PROT_WRITE,
             MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    assert(p == (void *)0x04000000);
}
static void init(void) {
    reset_counters();
    RAM32(0x03005E1C) = 0x03002000;
    RAM32(0x03005E44) = 1;
    RAM32(0x03005E24) = 0x03003000;
    RAM8(0x03005E04) = 2;
    RAM16(0x03000DA0) = 123;
    RAM16(0x03005E4C) = 0x1000;
    assert((uintptr_t)test_transfer <= UINT32_MAX);
    RAM32(0x03000D8C) = (uint32_t)(uintptr_t)test_transfer;
}
int main(void) {
    map_gba_memory();
    init();
    RAM32(0x03005E44) = 0;
    FrameEvent_Service();
    assert(script_calls == 0 && transfer_calls == 0);

    init();
    RAM32(0x03000D94) = 100;
    RAM16(0x04000100) = 119; /* rounds to 120 */
    RAM32(0x03000D90) = 0x03002100;
    FrameEvent_Service();
    assert(script_calls == 1 && entry_calls == 2 && transfer_calls == 1);
    assert(seen_entry == (void *)0x03003028);
    assert(seen_end == 20 && seen_threshold == 123);
    assert(seen_cursor[0] == 0x03002100 && seen_length[0] == 20 && seen_previous[0] == 0);
    assert(RAM32(0x03000D90) == 0x03002114);

    init();
    RAM32(0x03000D94) = 0xFFF0;
    RAM16(0x03005E4C) = 0xFFF0;
    RAM16(0x04000100) = 0x001F; /* rounds to 0x20 */
    RAM32(0x03000D90) = 0x03011FE0;
    FrameEvent_Service();
    assert(script_calls == 1 && entry_calls == 2 && transfer_calls == 2);
    assert(seen_length[0] == 0x10 && seen_cursor[0] == 0x03011FE0);
    assert(seen_length[1] == 0x10 && seen_cursor[1] == 0x03002000);
    assert(seen_previous[1] == 0x10);
    assert(seen_end == 0x20);
    assert(RAM32(0x03000D90) == 0x03002010);
    puts("frame dispatcher integration: passed gate, straight, wrap, and entry iteration");
    return 0;
}
