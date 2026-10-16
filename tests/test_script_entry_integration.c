#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

#define RAM 0x03000000u
#define SIZE 0x10000u
#define WORD(a) (*(volatile uint32_t *)(uintptr_t)(a))
#define BYTE(a) (*(volatile uint8_t *)(uintptr_t)(a))
#define HALF(a) (*(volatile uint16_t *)(uintptr_t)(a))

extern void RuntimeScript_SetDescriptor(const void *);
extern void RuntimeScript_Start(uint32_t);
extern void RuntimeScript_Service(void);
extern void RuntimeScript_Stop(void);
extern int RuntimeEntry_IsActive(uint32_t);
extern int32_t RuntimeEntry_Alloc(uint32_t, uint32_t);

void sub_08057C5C(const void *message, uint32_t argument) {
    (void)message; (void)argument;
    assert(!"unexpected diagnostic callback");
}

int main(void) {
    void *mapped = mmap((void *)(uintptr_t)RAM, SIZE, PROT_READ|PROT_WRITE,
                        MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED_NOREPLACE, -1, 0);
    if (mapped == MAP_FAILED) { perror("mmap"); return 2; }
    assert((uintptr_t)mapped == RAM);
    memset(mapped, 0, SIZE);

    /* Descriptor, script index, source lookup, script record pool, entry pool. */
    WORD(0x03002000u) = 1;
    WORD(0x03002008u) = 0x03002100u;
    WORD(0x0300200Cu) = 0x03002200u;
    WORD(0x03002100u) = 0x03003000u;
    WORD(0x03002104u) = 0x03003100u;
    WORD(0x0300220Cu) = 0x03005000u; /* source lookup index 3 */
    WORD(0x03005E28u) = 0x03004000u; /* 16 records of 0x24 bytes */
    WORD(0x03005E24u) = 0x03006000u; /* runtime entry pool */
    BYTE(0x03005E04u) = 2;
    WORD(0x03005E9Cu) = 0x123u;
    WORD(0x03000D98u) = 0x03007000u;
    WORD(0x03007000u + 7u * 4u) = 0xCAFE1234u;

    /* C0 select source[3]; 90 create ID 7, limit 12; delay one tick. */
    BYTE(0x03003000u) = 0xC0;
    BYTE(0x03003001u) = 3;
    BYTE(0x03003002u) = 0x90;
    BYTE(0x03003003u) = 7;
    BYTE(0x03003004u) = 12;
    BYTE(0x03003005u) = 0;
    BYTE(0x03003006u) = 1;

    RuntimeScript_SetDescriptor((void *)(uintptr_t)0x03002000u);
    RuntimeScript_Start(0);
    RuntimeScript_Service();
    assert(WORD(0x03004000u) == 0x03005000u);
    assert(BYTE(0x03004004u) == 1);
    assert(BYTE(0x03004005u) == 7);
    assert(WORD(0x03004008u) == 0x123u);
    assert(WORD(0x03006000u) == 0x03005000u);
    assert(WORD(0x03006004u) == 0x03005010u);
    assert(WORD(0x03006008u) == 0xCAFE1234u);
    assert(HALF(0x03006010u) == 12);
    assert(RuntimeEntry_IsActive(0x123u));
    assert(WORD(0x03005E9Cu) == 0x124u);
    assert(WORD(0x03005E08u) == 0x10000u);

    /* Remove the same identifier through the script's 0x8 family. */
    BYTE(0x03003100u) = 0x80;
    BYTE(0x03003101u) = 7;
    BYTE(0x03003102u) = 0;
    BYTE(0x03003103u) = 0;
    BYTE(0x03003104u) = 1;
    WORD(0x03005E00u) = 0x03003100u;
    WORD(0x03005E08u) = 0;
    RuntimeScript_Service();
    assert(!RuntimeEntry_IsActive(0x123u));
    assert(BYTE(0x03004004u) == 0);

    /* Reuse the freed runtime entry, with a new serial. */
    assert(RuntimeEntry_Alloc(0x03005100u, 7) == 0x124);
    assert(RuntimeEntry_IsActive(0x124u));
    RuntimeScript_Stop();
    assert(WORD(0x03005E0Cu) == 0);
    assert(RuntimeEntry_IsActive(0x124u)); /* not script-owned */

    puts("script + runtime-entry integration: PASS");
    assert(munmap(mapped, SIZE) == 0);
    return 0;
}
