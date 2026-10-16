#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#define W(a) (*(volatile uint32_t *)(uintptr_t)(a))
#define H(a) (*(volatile uint16_t *)(uintptr_t)(a))
#define B(a) (*(volatile uint8_t *)(uintptr_t)(a))
extern void RuntimeScript_SetDescriptor(const void *);
extern void RuntimeScript_Start(uint32_t);
extern void FrameEvent_Service(void);
extern int RuntimeEntry_IsActive(uint32_t);
static unsigned refresh_count, transfer_count;
static uint32_t refresh_window, refresh_threshold, transfer_length;
static void refresh(void *entry, uint32_t end, uint32_t threshold) {
    assert(entry == (void *)(uintptr_t)0x03006000u);
    ++refresh_count; refresh_window = end; refresh_threshold = threshold;
}
static void transfer(uint32_t cursor, uint32_t length, uint32_t previous) {
    assert(cursor == 0x03008000u); assert(previous == 0);
    ++transfer_count; transfer_length = length;
}
void sub_08057C5C(const void *msg, uint32_t arg) {
    (void)msg; (void)arg; assert(!"unexpected diagnostic callback");
}
static void map_region(uintptr_t address, size_t length) {
    void *p = mmap((void *)address, length, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    assert(p == (void *)address);
    memset(p, 0, length);
}
int main(void) {
    map_region(0x03000000u, 0x10000);
    map_region(0x04000000u, 0x10000);
    map_region(0x0807D000u, 0x1000);
    assert((uintptr_t)refresh <= UINT32_MAX && (uintptr_t)transfer <= UINT32_MAX);
    W(0x0807D988u) = (uint32_t)(uintptr_t)refresh;
    W(0x03000D8Cu) = (uint32_t)(uintptr_t)transfer;
    W(0x03002000u) = 1;
    W(0x03002008u) = 0x03002100u;
    W(0x0300200Cu) = 0x03002200u;
    W(0x03002100u) = 0x03003000u;
    W(0x0300220Cu) = 0x03005000u;
    W(0x03005E28u) = 0x03004000u;
    W(0x03005E24u) = 0x03006000u;
    B(0x03005E04u) = 1;
    W(0x03005E9Cu) = 0x123u;
    W(0x03000D98u) = 0x03007000u;
    W(0x03007000u + 7u * 4u) = 0xCAFE1234u;
    /* Source header: first boundary +0x40, secondary boundary +0x20. */
    W(0x03005004u) = 0x30u;
    W(0x03005008u) = 0x10u;
    /* Select source 3, allocate entry 7 with limit 12, delay 1 tick. */
    B(0x03003000u) = 0xC0; B(0x03003001u) = 3;
    B(0x03003002u) = 0x90; B(0x03003003u) = 7;
    B(0x03003004u) = 12; B(0x03003005u) = 0;
    B(0x03003006u) = 1;
    W(0x03005E1Cu) = 0x03008000u;
    W(0x03005E44u) = 1;
    W(0x03000D90u) = 0x03008000u;
    W(0x03000D94u) = 100;
    H(0x04000100u) = 119;
    H(0x03000DA0u) = 77;
    H(0x03005E4Cu) = 0x1000;
    RuntimeScript_SetDescriptor((void *)(uintptr_t)0x03002000u);
    RuntimeScript_Start(0);
    FrameEvent_Service();
    assert(RuntimeEntry_IsActive(0x123u));
    assert(W(0x03006000u) == 0x03005000u);
    assert(H(0x03006010u) == 12);
    assert(refresh_count == 1 && refresh_window == 20 && refresh_threshold == 77);
    assert(transfer_count == 1 && transfer_length == 20);
    assert(W(0x03000D90u) == 0x03008014u);
    assert(W(0x03006004u) == 0x03005010u);
    puts("script -> entry allocation -> frame service -> entry refresh -> transfer: PASS");
    return 0;
}
