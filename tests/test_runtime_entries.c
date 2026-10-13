#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

#define RAM 0x03000000u
#define RAM_SIZE 0x10000u
#define U32(a) (*(uint32_t *)(uintptr_t)(a))
#define U8(a) (*(uint8_t *)(uintptr_t)(a))
#define U16(a) (*(uint16_t *)(uintptr_t)(a))
#define ENTRIES 0x03003000u
#define SOURCES 0x03004000u
#define SELECTOR 0x03004500u
#define VALUES 0x03005000u

extern int32_t RuntimeEntry_AllocIndexed(uint32_t, uint32_t);
extern int32_t RuntimeEntry_Alloc(uint32_t, uint32_t);
extern int RuntimeEntry_IsActive(uint32_t);
extern void RuntimeEntry_Deactivate(uint32_t);
extern void RuntimeEntry_SetStatus2(uint32_t);
extern void RuntimeEntry_AdvanceStatus(uint32_t);
extern void RuntimeEntry_SetLimit(uint32_t, uint32_t);
extern void RuntimeEntry_SetPointer(uint32_t, uint32_t);

static void reset(void) {
    memset((void *)(uintptr_t)RAM, 0, RAM_SIZE);
    U32(0x03005E24u) = ENTRIES;
    U8(0x03005E04u) = 2;
    U32(0x03005E9Cu) = 0x42;
    U32(0x03000D98u) = VALUES;
    U32(VALUES) = 0x12345678u;
    U32(VALUES+4) = 0xABCDEF01u;
    U32(SOURCES) = 0x08001000u;
    U32(SOURCES+4) = 0x08002000u;
    U32(SOURCES+8) = 0x08003000u;
    U16(SELECTOR) = 2;
}

int main(void) {
    void *p = mmap((void *)(uintptr_t)RAM, RAM_SIZE, PROT_READ|PROT_WRITE,
                   MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED_NOREPLACE, -1, 0);
    if (p == MAP_FAILED) { perror("mmap"); return 2; }
    assert((uintptr_t)p == RAM);
    reset();
    assert(RuntimeEntry_AllocIndexed(SOURCES, SELECTOR) == 0x42);
    assert(U8(ENTRIES+0x16) == 1);
    assert(U32(ENTRIES) == 0x08003000u);
    assert(U32(ENTRIES+4) == 0x08003010u);
    assert(U32(ENTRIES+8) == 0x12345678u);
    assert(U32(ENTRIES+0x1C) == SOURCES);
    assert(U32(ENTRIES+0x20) == SELECTOR);
    assert(U16(ENTRIES+0x24) == 1);
    assert(RuntimeEntry_IsActive(0x42));
    assert(RuntimeEntry_Alloc(0x08006000u, 1) == 0x43);
    assert(U32(ENTRIES+0x28+8) == 0xABCDEF01u);
    assert(RuntimeEntry_Alloc(0x08007000u, 0) == -1);
    RuntimeEntry_SetStatus2(0x42);
    assert(U8(ENTRIES+0x16) == 2);
    RuntimeEntry_AdvanceStatus(0x42);
    assert(U8(ENTRIES+0x16) == 1);
    RuntimeEntry_SetLimit(0x42, 0x500);
    assert(U16(ENTRIES+0x10) == 0x100);
    RuntimeEntry_SetPointer(0x42, 1);
    assert(U32(ENTRIES+8) == 0xABCDEF01u);
    RuntimeEntry_Deactivate(0x42);
    assert(!RuntimeEntry_IsActive(0x42));
    assert(RuntimeEntry_AllocIndexed(SOURCES, SELECTOR) == 0x44);
    assert(U32(ENTRIES+0x18) == 0x44);
    puts("runtime-entry selection/lifecycle tests: PASS");
    assert(munmap(p, RAM_SIZE) == 0);
    return 0;
}
