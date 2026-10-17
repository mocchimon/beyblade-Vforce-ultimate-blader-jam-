#define _GNU_SOURCE
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

#define RAM_BASE 0x03000000u
#define RAM_SIZE 0x00010000u
#define U32(a) (*(uint32_t *)(uintptr_t)(a))
#define U16(a) (*(uint16_t *)(uintptr_t)(a))
#define U8(a) (*(uint8_t *)(uintptr_t)(a))

extern void ResourceNode_Unlink(void *node);
extern void ResourceNode_UnlinkAuxiliary(void *node);
extern void ResourceNode_ReleaseChain(void *context);
extern void *ResourceNode_AllocateChain(void *context, uint32_t count,
                                        uint32_t resource_class);
extern void *ResourceNode_ResizeChain(void *context, uint32_t count,
                                      uint32_t resource_class);
extern void ResourceNode_ValidateActiveList(void *head);
static unsigned release_calls, diagnostic_calls;
static int32_t released_token;
static uint32_t released_mask, diagnostic_messages[8];
void RuntimeRange_Release(int32_t token, uint32_t mask) {
    release_calls++; released_token = token; released_mask = mask;
}
void sub_08057C5C(const void *message, uint32_t argument) {
    (void)argument;
    assert(diagnostic_calls < sizeof(diagnostic_messages) / sizeof(diagnostic_messages[0]));
    diagnostic_messages[diagnostic_calls++] = (uint32_t)(uintptr_t)message;
}
void sub_08057B60(const void *message) {
    assert(diagnostic_calls < sizeof(diagnostic_messages) / sizeof(diagnostic_messages[0]));
    diagnostic_messages[diagnostic_calls++] = (uint32_t)(uintptr_t)message;
}
static void reset(void) {
    memset((void *)(uintptr_t)RAM_BASE, 0, RAM_SIZE);
    release_calls = diagnostic_calls = 0;
    memset(diagnostic_messages, 0, sizeof(diagnostic_messages));
    released_token = 0; released_mask = 0;
}
int main(void) {
    void *mapped = mmap((void *)(uintptr_t)RAM_BASE, RAM_SIZE,
                        PROT_READ | PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED_NOREPLACE, -1, 0);
    if (mapped == MAP_FAILED) { perror("mmap fixed GBA IWRAM"); return 2; }
    assert((uintptr_t)mapped == RAM_BASE);

    /* Unlink middle primary node, release its range, recycle auxiliary head. */
    reset();
    U32(0x03005DE4) = 0x03002000;
    U32(0x03002004) = 0x03002100;
    U32(0x03002100) = 0x03002000;
    U32(0x03002104) = 0x03002200;
    U32(0x03002200) = 0x03002100;
    U32(0x03002124) = 37;
    U16(0x03002116) = 8; /* 1 << (8-5) */
    U32(0x03002130) = 0x03002400;
    U32(0x03005DF8) = 0x03002400;
    U32(0x03002404) = 0x03002500;
    U32(0x03002500) = 0x03002400;
    U32(0x03005DE8) = 0x03002600;
    U32(0x03005DEC) = 0x03002700;
    ResourceNode_Unlink((void *)(uintptr_t)0x03002100);
    assert(release_calls == 1 && released_token == 37 && released_mask == 8);
    assert(U32(0x03002124) == UINT32_MAX);
    assert(U32(0x03002004) == 0x03002200 && U32(0x03002200) == 0x03002000);
    assert(U32(0x03005DEC) == 0x03002100 && U32(0x03002104) == 0x03002700);
    assert(U32(0x03005DF8) == 0x03002500 && U32(0x03002500) == 0);
    assert(U32(0x03005DE8) == 0x03002400 && U32(0x03002404) == 0x03002600);
    assert(U32(0x03002130) == 0 && U32(0x03005DF4) == 1);
    assert(diagnostic_calls == 0);

    /* Primary head removal with suppressed release and blocked auxiliary removal. */
    reset();
    U32(0x03005DE4) = 0x03002100;
    U32(0x03002104) = 0x03002200;
    U32(0x03002200) = 0x03002100;
    U32(0x03002124) = 12;
    U16(0x03002120) = 1;
    U32(0x03002130) = 0x03002400;
    U8(0x03002419) = 1;
    U32(0x03005DF8) = 0x03002400;
    ResourceNode_Unlink((void *)(uintptr_t)0x03002100);
    assert(release_calls == 0 && U32(0x03002124) == UINT32_MAX);
    assert(U32(0x03005DE4) == 0x03002200 && U32(0x03002200) == 0);
    assert(U32(0x03005DF8) == 0x03002400 && U32(0x03005DE8) == 0);
    assert(U32(0x03002130) == 0 && diagnostic_calls == 0);

    /* Auxiliary tail unlink: repair predecessor, leave active head untouched. */
    reset();
    U32(0x03005DF8) = 0x03002400;
    U32(0x03002404) = 0x03002500;
    U32(0x03002500) = 0x03002400;
    ResourceNode_UnlinkAuxiliary((void *)(uintptr_t)0x03002500);
    assert(U32(0x03005DF8) == 0x03002400 && U32(0x03002404) == 0);
    assert(U32(0x03005DE8) == 0x03002500);

    /* Primary tail removal: no range-release call for a negative token. */
    reset();
    U32(0x03005DE4) = 0x03002000;
    U32(0x03002004) = 0x03002100;
    U32(0x03002100) = 0x03002000;
    U32(0x03002124) = UINT32_MAX;
    ResourceNode_Unlink((void *)(uintptr_t)0x03002100);
    assert(release_calls == 0 && U32(0x03002004) == 0);
    assert(U32(0x03005DEC) == 0x03002100 && diagnostic_calls == 0);

    /* Validator reports a non-null head predecessor through the ROM message. */
    reset();
    U32(0x03002000) = 0x03001F00;
    U32(0x03002004) = 0;
    U32(0x03001F04) = 0;
    ResourceNode_ValidateActiveList((void *)(uintptr_t)0x03002000);
    assert(diagnostic_calls == 2);
    assert(diagnostic_messages[0] == 0x0875591C);
    assert(diagnostic_messages[1] == 0x08755938);

    /* Validator detects a broken back-link on the second node. */
    reset();
    U32(0x03002000) = 0;
    U32(0x03002004) = 0x03002100;
    U32(0x03002100) = 0;
    U32(0x03002104) = 0;
    ResourceNode_ValidateActiveList((void *)(uintptr_t)0x03002000);
    assert(diagnostic_calls == 1);
    assert(diagnostic_messages[0] == 0x08755954);

    /* Empty embedded chains return without touching their context or globals. */
    reset();
    U32(0x03005DF4) = 9;
    U32(0x03005DEC) = 0x03002700;
    U32(0x03002800) = 0x03002100;
    U32(0x03002804) = 0x03002200;
    U32(0x03002808) = 0;
    U32(0x0300282C) = 0x12345678;
    ResourceNode_ReleaseChain((void *)(uintptr_t)0x03002800);
    assert(U32(0x03005DF4) == 9 && U32(0x03005DEC) == 0x03002700);
    assert(U32(0x03002800) == 0x03002100);
    assert(U32(0x03002804) == 0x03002200);
    assert(U32(0x0300282C) == 0x12345678);
    assert(release_calls == 0 && diagnostic_calls == 0);

    /* Release a two-node middle segment with range and auxiliary ownership. */
    reset();
    U32(0x03005DE4) = 0x03002000;
    U32(0x03005DEC) = 0x03002700;
    U32(0x03005DF4) = 4;
    U32(0x03002000) = 0;
    U32(0x03002004) = 0x03002100;
    U32(0x03002100) = 0x03002000;
    U32(0x03002104) = 0x03002200;
    U16(0x03002116) = 7; /* 1 << (7-5) */
    U32(0x03002124) = 0; /* Token zero is valid and must be released. */
    U32(0x03002130) = 0x03002400;
    U32(0x03002200) = 0x03002100;
    U32(0x03002204) = 0x03002300;
    U32(0x03002224) = UINT32_MAX;
    U32(0x03002300) = 0x03002200;
    U32(0x03002304) = 0;
    U32(0x03005DF8) = 0x03002400;
    U32(0x03002404) = 0x03002500;
    U32(0x03002500) = 0x03002400;
    U32(0x03005DE8) = 0x03002600;
    U32(0x03002800) = 0x03002100;
    U32(0x03002804) = 0x03002200;
    U32(0x03002808) = 2;
    U32(0x0300282C) = 0x12345678;
    ResourceNode_ReleaseChain((void *)(uintptr_t)0x03002800);
    assert(release_calls == 1 && released_token == 0 && released_mask == 4);
    assert(U32(0x03005DF4) == 6);
    assert(U32(0x03002004) == 0x03002300);
    assert(U32(0x03002300) == 0x03002000);
    assert(U32(0x03005DEC) == 0x03002100);
    assert(U32(0x03002104) == 0x03002200);
    assert(U32(0x03002204) == 0x03002700);
    assert(U32(0x03002124) == UINT32_MAX);
    assert(U32(0x03002224) == UINT32_MAX);
    assert(U32(0x03002130) == 0);
    assert(U32(0x03005DF8) == 0x03002500);
    assert(U32(0x03002500) == 0);
    assert(U32(0x03005DE8) == 0x03002400);
    assert(U32(0x03002404) == 0x03002600);
    assert(U32(0x03002800) == 0 && U32(0x03002804) == 0);
    assert(U32(0x03002808) == 0 && U32(0x0300282C) == 0x12345678);
    assert(diagnostic_calls == 0);

    /* Allocate a two-node batch, extend it, then shrink by recycling/reuse. */
    reset();
    U32(0x03005DE4) = 0x03002000;
    U16(0x03002022) = 1;
    U32(0x03002004) = 0;
    U32(0x03005DEC) = 0x03002100;
    U32(0x03002104) = 0x03002200;
    U32(0x03002204) = 0x03002300;
    U32(0x03002304) = 0;
    U32(0x03002124) = UINT32_MAX;
    U32(0x03002224) = UINT32_MAX;
    U32(0x03002324) = UINT32_MAX;
    U32(0x03005DF4) = 3;
    U32(0x03002800) = 0;
    U32(0x03002804) = 0;
    U32(0x03002808) = 0;
    assert(ResourceNode_AllocateChain((void *)(uintptr_t)0x03002800, 2, 2) ==
           (void *)(uintptr_t)0x03002100);
    assert(U32(0x03002800) == 0x03002100);
    assert(U32(0x03002804) == 0x03002200 && U32(0x03002808) == 2);
    assert(U32(0x03005DEC) == 0x03002300 && U32(0x03005DF4) == 1);
    assert(U32(0x03002004) == 0x03002100);
    assert(U32(0x03002100) == 0x03002000);
    assert(U32(0x03002104) == 0x03002200);
    assert(U32(0x03002200) == 0x03002100 && U32(0x03002204) == 0);
    assert(U16(0x03002122) == 2 && U16(0x03002222) == 2);
    assert(diagnostic_calls == 0);

    assert(ResourceNode_ResizeChain((void *)(uintptr_t)0x03002800, 3, 99) ==
           (void *)(uintptr_t)0x03002100);
    assert(U32(0x03002804) == 0x03002300 && U32(0x03002808) == 3);
    assert(U32(0x03005DEC) == 0 && U32(0x03005DF4) == 0);
    assert(U32(0x03002204) == 0x03002300);
    assert(U32(0x03002300) == 0x03002200 && U32(0x03002304) == 0);
    assert(U16(0x03002322) == 2);

    assert(ResourceNode_ResizeChain((void *)(uintptr_t)0x03002800, 4, 99) == 0);
    assert(U32(0x03002808) == 3 && U32(0x03005DF4) == 0);
    assert(diagnostic_calls == 1 && diagnostic_messages[0] == 0x08755B30);

    assert(ResourceNode_ResizeChain((void *)(uintptr_t)0x03002800, 1, 2) ==
           (void *)(uintptr_t)0x03002100);
    assert(U32(0x03002800) == 0x03002100);
    assert(U32(0x03002804) == 0x03002100 && U32(0x03002808) == 1);
    assert(U32(0x03005DEC) == 0x03002200 && U32(0x03005DF4) == 2);
    assert(U32(0x03002004) == 0x03002100);
    assert(U32(0x03002100) == 0x03002000 && U32(0x03002104) == 0);
    assert(U32(0x03002200) == 0x03002100 && U32(0x03002204) == 0x03002300);
    assert(diagnostic_calls == 2 && diagnostic_messages[1] == 0x08755B4C);

    puts("resource-node list lifecycle tests: PASS (9 scenarios)");
    assert(munmap(mapped, RAM_SIZE) == 0);
    return 0;
}
