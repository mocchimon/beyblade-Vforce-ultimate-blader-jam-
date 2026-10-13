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
static unsigned release_calls, validate_calls;
static int32_t released_token;
static uint32_t released_mask, validated_head;
void RuntimeRange_Release(int32_t token, uint32_t mask) {
    release_calls++; released_token = token; released_mask = mask;
}
void ResourceNode_ValidateActiveList(void *head) {
    validate_calls++; validated_head = (uint32_t)(uintptr_t)head;
}
static void reset(void) {
    memset((void *)(uintptr_t)RAM_BASE, 0, RAM_SIZE);
    release_calls = validate_calls = 0;
    released_token = 0; released_mask = validated_head = 0;
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
    assert(validate_calls == 1 && validated_head == 0x03002000);

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
    assert(U32(0x03002130) == 0 && validated_head == 0x03002200);

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
    assert(U32(0x03005DEC) == 0x03002100 && validated_head == 0x03002000);

    puts("resource-node list lifecycle tests: PASS (4 scenarios)");
    assert(munmap(mapped, RAM_SIZE) == 0);
    return 0;
}
