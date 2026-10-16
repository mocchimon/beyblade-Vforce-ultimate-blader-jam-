#define _GNU_SOURCE
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

void RuntimeScript_SetDescriptor(const void *descriptor);
void RuntimeScript_Start(uint32_t index);
void RuntimeScript_Stop(void);
void RuntimeScript_Service(void);

static uint32_t last_alloc_source;
static uint32_t last_alloc_index;
static uint32_t last_deactivated;
static uint32_t last_limit_serial;
static uint32_t last_limit;
static unsigned deactivate_calls;
static int alloc_failure;
static unsigned limit_calls;

int32_t RuntimeEntry_Alloc(uint32_t source, uint32_t index)
{
    last_alloc_source = source;
    last_alloc_index = index;
    return alloc_failure ? -1 : (int32_t)(0x1000u + index);
}

void RuntimeEntry_Deactivate(uint32_t serial)
{
    last_deactivated = serial;
    ++deactivate_calls;
}

void RuntimeEntry_SetLimit(uint32_t serial, uint32_t limit)
{
    ++limit_calls;
    last_limit_serial = serial;
    last_limit = limit;
}

void sub_08057C5C(const void *message, uint32_t argument)
{
    (void)message;
    (void)argument;
}

static volatile uint32_t *g32(uint32_t address)
{
    return (volatile uint32_t *)(uintptr_t)address;
}

static int fail(const char *message)
{
    fprintf(stderr, "runtime-script test failed: %s\n", message);
    return 1;
}

int main(void)
{
    const uintptr_t ram_base = 0x03000000u;
    const size_t ram_size = 0x10000u;
    uint8_t *ram = mmap((void *)ram_base, ram_size,
                        PROT_READ | PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);
    uint32_t *descriptor = (uint32_t *)(uintptr_t)0x03002000u;
    uint32_t *script_table = (uint32_t *)(uintptr_t)0x03002100u;
    uint32_t *source_pointer_table = (uint32_t *)(uintptr_t)0x03002200u;
    uint8_t *script = (uint8_t *)(uintptr_t)0x03003000u;
    uint32_t *record_words = (uint32_t *)(uintptr_t)0x03004000u;

    if (ram == MAP_FAILED)
        return fail("could not map simulated GBA RAM");
    memset(ram, 0, ram_size);

    descriptor[0] = 2;
    descriptor[2] = 0x03002100u;
    descriptor[3] = 0x03002200u;
    source_pointer_table[3] = 0x03005000u;
    script_table[0] = 0x03003000u;
    script_table[1] = 0x03003080u;
    script_table[2] = 0x03003100u;
    script_table[3] = 0x03003180u;
    RuntimeScript_SetDescriptor(descriptor);
    RuntimeScript_Start(1);
    if (*g32(0x03005E00u) != 0x03003100u ||
        *g32(0x03005E20u) != 0x03003180u ||
        *g32(0x03005E0Cu) != 1 || *g32(0x03005E08u) != 0 ||
        *g32(0x03005E10u) != 0)
        return fail("indexed start did not load cursor pair/reset timing");
    if (*g32(0x03005E0Cu) != 1)
        return fail("start did not enable interpreter");

    /* One script record at index zero, with one occupied/free slot set. */
    *g32(0x03005E28u) = 0x03004000u;
    record_words[0] = 0x12345678u;
    *g32(0x03005E00u) = 0x03003000u;
    *g32(0x03005E08u) = 0;
    *g32(0x03005E10u) = 0;
    script[0] = 0x90; /* create an entry in record zero */
    script[1] = 7;    /* identifier */
    script[2] = 12;   /* limit */
    script[3] = 0;    /* delay opcode */
    script[4] = 1;
    RuntimeScript_Service();
    if (last_alloc_source != 0x12345678u || last_alloc_index != 7)
        return fail("0x9-family did not allocate from selected record");
    if (last_limit_serial != 0x1007u || last_limit != 12)
        return fail("0x9-family did not apply entry limit");
    if (((uint8_t *)record_words)[4] != 1 ||
        ((uint8_t *)record_words)[5] != 7 || record_words[2] != 0x1007u)
        return fail("0x9-family did not store slot state/identifier/serial");
    if (*g32(0x03005E08u) != 0x10000u)
        return fail("delay command did not add a 16.16 interval");

    /* Exhausted entry pool must not create a phantom script slot. */
    memset((uint8_t *)record_words + 4, 0, 4 * 8);
    alloc_failure = 1;
    {
        unsigned previous_limits = limit_calls;
        *g32(0x03005E00u) = 0x03003000u;
        *g32(0x03005E08u) = 0;
        *g32(0x03005E10u) = 0;
        RuntimeScript_Service();
        if (((uint8_t *)record_words)[4] != 0 || limit_calls != previous_limits)
            return fail("allocation failure published a phantom entry");
    }
    alloc_failure = 0;
    /* Restore the active slot for the remove-entry test below. */
    ((uint8_t *)record_words)[4] = 1;
    ((uint8_t *)record_words)[5] = 7;
    record_words[2] = 0x1007u;

    /* Remove the entry, skipping the command's second operand byte. */
    *g32(0x03005E00u) = 0x03003200u;
    *g32(0x03005E08u) = 0;
    *g32(0x03005E10u) = 0;
    script = (uint8_t *)(uintptr_t)0x03003200u;
    script[0] = 0x80;
    script[1] = 7;
    script[2] = 0;
    script[3] = 0;
    script[4] = 1;
    RuntimeScript_Service();
    if (deactivate_calls != 1 || last_deactivated != 0x1007u)
        return fail("0x8-family did not deactivate matching entry");
    if (((uint8_t *)record_words)[4] != 0)
        return fail("0x8-family did not clear slot active byte");

    /* B2 loads a big-endian step; the following delay exits the command loop. */
    *g32(0x03005E00u) = 0x03003300u;
    *g32(0x03005E08u) = 0;
    script = (uint8_t *)(uintptr_t)0x03003300u;
    script[0] = 0xB2;
    script[1] = 0;
    script[2] = 0;
    script[3] = 0;
    script[4] = 4;
    script[5] = 0;
    script[6] = 1;
    RuntimeScript_Service();
    if (*g32(0x03005E10u) != 4 || *g32(0x03005E08u) != 0x10000u)
        return fail("B2 did not set step / delay did not terminate processing");

    /* C-family source selection resolves through descriptor +0x0C. */
    *g32(0x03005E00u) = 0x03003400u;
    *g32(0x03005E08u) = 0;
    *g32(0x03005E10u) = 0;
    script = (uint8_t *)(uintptr_t)0x03003400u;
    script[0] = 0xC0;
    script[1] = 3;
    script[2] = 0;
    script[3] = 1;
    RuntimeScript_Service();
    if (record_words[0] != 0x03005000u)
        return fail("C-family did not resolve source pointer table entry");

    /* B0 jumps to the saved cursor and resumes at its delay command. */
    *g32(0x03005E00u) = 0x03003480u;
    *g32(0x03005E20u) = 0x03003500u;
    *g32(0x03005E08u) = 0;
    *g32(0x03005E10u) = 0;
    script = (uint8_t *)(uintptr_t)0x03003480u;
    script[0] = 0xB0;
    script = (uint8_t *)(uintptr_t)0x03003500u;
    script[0] = 0;
    script[1] = 1;
    RuntimeScript_Service();
    if (*g32(0x03005E00u) != 0x03003502u ||
        *g32(0x03005E08u) != 0x10000u)
        return fail("B0 did not jump to the saved cursor");

    /* Stop must also deactivate any still-active script-owned slot. */
    ((uint8_t *)record_words)[4] = 1;
    ((uint8_t *)record_words)[5] = 7;
    record_words[2] = 0x1007u;
    *g32(0x03005E0Cu) = 1;
    RuntimeScript_Stop();
    if (*g32(0x03005E0Cu) != 0 || deactivate_calls != 2 ||
        ((uint8_t *)record_words)[4] != 0)
        return fail("stop did not deactivate slots and clear interpreter state");

    puts("Runtime script: lifecycle, delay, add/remove, B0/B2/C families passed");
    munmap(ram, ram_size);
    return 0;
}
