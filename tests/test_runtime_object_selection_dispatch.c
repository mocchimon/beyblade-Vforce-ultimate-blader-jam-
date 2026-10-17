#include <assert.h>
#include <stdint.h>
#include <stdio.h>

#include "runtime_object_selection.h"

static void *g_released_subcontext;
static void *g_finalizer_context;
static const uint8_t *g_finalizer_code_stream;
static uint32_t g_finalizer_object_byte;
static uint32_t g_finalizer_return;

void ResourceNode_ReleaseChain(void *subcontext)
{
    g_released_subcontext = subcontext;
}

uint32_t RuntimeObjectSelection_Finalize(void *context,
                                         const uint8_t *code_stream,
                                         uint32_t control_value)
{
    g_finalizer_context = context;
    g_finalizer_code_stream = code_stream;
    g_finalizer_object_byte = control_value;
    return g_finalizer_return;
}

int main(void)
{
    uint32_t storage[16] = {0};
    uint8_t *context = (uint8_t *)storage;
    uint32_t state_word = 0x12345678u;
    uint16_t control = 0xA55Au;

    *(uint32_t *)(void *)(context + 0x10) = state_word;
    RuntimeObjectSelection_AddStateBits(context, 2u);
    assert(*(uint32_t *)(void *)(context + 0x10) == (state_word | 0x800u));
    assert(RuntimeObjectSelection_GetStateBits(context) ==
           (((state_word | 0x800u) >> 10) & 3u));

    *(uint16_t *)(void *)(context + 0x14) = control;
    RuntimeObjectSelection_SetControlNibble(context, 0xABu);
    assert(*(uint16_t *)(void *)(context + 0x14) == 0xB55Au);

    context[0x18] = 0x55u;
    context[0x19] = 0xAAu;
    context[0x1A] = 0x66u;
    RuntimeObjectSelection_SetByte19ToOne(context);
    assert(context[0x18] == 0x55u && context[0x19] == 1u &&
           context[0x1A] == 0x66u);
    RuntimeObjectSelection_SetByte19ToZero(context);
    assert(context[0x19] == 0u);

    *(uint16_t *)(void *)(context + 0x0A) = 0xFFFFu;
    g_finalizer_return = 0x1234ABCDu;
    assert(RuntimeObjectSelection_Dispatch(context,
                                           (const uint8_t *)(uintptr_t)0x87654320u,
                                           0x12345678u) == 0xCDu);
    assert(g_released_subcontext == context + 0x14);
    assert(*(uint16_t *)(void *)(context + 0x0A) == 0u);
    assert(g_finalizer_context == context);
    assert(g_finalizer_code_stream ==
           (const uint8_t *)(uintptr_t)0x87654320u);
    assert(g_finalizer_object_byte == 0x78u);

    puts("PASS: selection dispatch and packed-field behavior");
    return 0;
}
