#include <stdint.h>

#include "resource_node.h"
#include "runtime_object_selection.h"

void RuntimeObjectSelection_ResetContext(void *context_pointer)
{
    uint8_t *context = (uint8_t *)context_pointer;

    ResourceNode_ReleaseChain(context + 0x14);
    *(uint16_t *)(void *)(context + 0x0A) = 0;
}

uint32_t RuntimeObjectSelection_Dispatch(void *context,
                                         const uint8_t *code_stream,
                                         uint32_t object_byte)
{
    RuntimeObjectSelection_ResetContext(context);

    /* The ROM truncates this argument before calling the finalizer and
     * truncates the finalizer's return value before returning to its caller. */
    return (uint8_t)RuntimeObjectSelection_Finalize(
        context, code_stream, (uint8_t)object_byte);
}

void RuntimeObjectSelection_AddStateBits(void *context_pointer,
                                         uint32_t value)
{
    uint8_t *context = (uint8_t *)context_pointer;
    uint32_t *state_word = (uint32_t *)(void *)(context + 0x10);

    *state_word |= (value & 0x03u) << 10;
}

uint32_t RuntimeObjectSelection_GetStateBits(const void *context_pointer)
{
    const uint8_t *context = (const uint8_t *)context_pointer;
    const uint32_t *state_word =
        (const uint32_t *)(const void *)(context + 0x10);

    return (*state_word >> 10) & 0x03u;
}

void RuntimeObjectSelection_SetControlNibble(void *context_pointer,
                                             uint32_t value)
{
    uint8_t *context = (uint8_t *)context_pointer;
    uint16_t *control = (uint16_t *)(void *)(context + 0x14);

    *control = (uint16_t)((*control & 0x0FFFu) | ((value & 0x0Fu) << 12));
}

void RuntimeObjectSelection_SetByte19ToOne(void *context_pointer)
{
    ((uint8_t *)context_pointer)[0x19] = 1;
}

void RuntimeObjectSelection_SetByte19ToZero(void *context_pointer)
{
    ((uint8_t *)context_pointer)[0x19] = 0;
}

/* ROM 0x08064F5C. The byte value 32 advances the stream but does not
 * contribute to the number of entries. */
uint32_t RuntimeObjectSelection_CountEntries(const uint8_t *code_stream)
{
    uint32_t count = 0;

    while (*code_stream != 0u) {
        if (*code_stream != 32u)
            ++count;
        ++code_stream;
    }

    return count;
}
