#include <stdint.h>

#include "resource_node.h"
#include "runtime.h"
#include "runtime_object_selection.h"

static uint16_t RuntimeObjectSelection_ReadHalfword(const void *base,
                                                     uint32_t offset)
{
    const uint8_t *bytes = (const uint8_t *)base;
    return *(const uint16_t *)(const void *)(bytes + offset);
}

static uint32_t RuntimeObjectSelection_ReadWord(const void *base,
                                                 uint32_t offset)
{
    const uint8_t *bytes = (const uint8_t *)base;
    return *(const uint32_t *)(const void *)(bytes + offset);
}

static void RuntimeObjectSelection_WriteWord(void *base, uint32_t offset,
                                             uint32_t value)
{
    uint8_t *bytes = (uint8_t *)base;
    *(uint32_t *)(void *)(bytes + offset) = value;
}

/* ROM 0x080614E0. Resize the embedded resource-node segment for the incoming
 * zero-terminated code stream, initialize one entry per ordinary code, and
 * carry the special code 32 as a cursor-reset marker for the next entry. */
uint32_t RuntimeObjectSelection_Finalize(void *context_pointer,
                                         const uint8_t *code_stream,
                                         uint32_t control_value)
{
    uint8_t *context = (uint8_t *)context_pointer;
    uint32_t entry_count =
        RuntimeObjectSelection_CountEntries(code_stream);
    uint32_t object_pointer = RuntimeObjectSelection_ReadWord(context, 0x24);
    uint8_t base_coordinate =
        *(const uint8_t *)(uintptr_t)(object_pointer + 4u);
    uint32_t offset_table = RuntimeObjectSelection_ReadWord(context, 0x20);
    uint32_t existing_count = RuntimeObjectSelection_ReadWord(context, 0x1C);
    uint16_t cursor = RuntimeObjectSelection_ReadHalfword(context, 0x0A);
    uint16_t selection_flags = RuntimeObjectSelection_ReadHalfword(context,
                                                                    0x08);
    uint32_t append_after = RuntimeObjectSelection_ReadWord(context, 0x18);
    uint32_t record_pointer = RuntimeObjectSelection_ReadWord(context, 0x2C);
    uint8_t state_argument = (uint8_t)((selection_flags & 0x0180u) >> 7);
    uint16_t pending_marker = 0;
    uint32_t record_flags = 0;

    if (code_stream == 0 || *code_stream == 0)
        return 0;

    if (ResourceNode_ResizeChain(context + 0x14,
                                 existing_count + entry_count,
                                 context[0x2B]) == 0) {
        sub_08057C5C((const void *)(uintptr_t)0x08755B7Cu, code_stream);
        return 0;
    }

    /* Preserve the old tail across resize: its +4 link becomes the first
     * appended node when a chain already existed. With an empty old chain the
     * return from resize is the first new node instead. */
    uint32_t entry_pointer;
    if (append_after != 0)
        entry_pointer = RuntimeObjectSelection_ReadWord(
            (const void *)(uintptr_t)append_after, 4);
    else
        entry_pointer = RuntimeObjectSelection_ReadWord(context, 0x14);

    if (record_pointer != 0) {
        uint32_t attributes = RuntimeObjectSelection_ReadWord(
            (const void *)(uintptr_t)record_pointer, 8);
        record_flags = ((attributes & 0x03E0u) << 20) | 0x0100u;

        if ((selection_flags & 0x0008u) == 0) {
            const uint8_t *record =
                (const uint8_t *)(uintptr_t)record_pointer;
            uint16_t width = RuntimeObjectSelection_ReadHalfword(record, 20);
            uint16_t height = RuntimeObjectSelection_ReadHalfword(record, 22);

            if (width > 0x00B0u || height > 0x00B0u)
                record_flags |= 0x0200u;
        }
    }

    for (;;) {
        uint8_t code = *code_stream++;
        uint16_t coordinate = base_coordinate;

        if (code == 0)
            break;

        if (code == 32u) {
            coordinate = context[0x28];
            pending_marker = 0x8000u;
        } else {
            const volatile uint8_t *code_map =
                (const volatile uint8_t *)(uintptr_t)0x0807D9A4u;
            uint8_t mapped_code = code_map[code];
            void *entry = (void *)(uintptr_t)entry_pointer;
            const void *metadata = (const void *)(uintptr_t)object_pointer;

            ResourceNode_ConfigureSelectionEntry(
                entry, metadata, 0, 0, 0, state_argument, 0, mapped_code);
            RuntimeObjectSelection_SetControlNibble(entry, control_value);
            RuntimeObjectSelection_AddStateBits(entry, context[0x0E]);

            if (offset_table != 0) {
                const volatile uint8_t *offsets =
                    (const volatile uint8_t *)(uintptr_t)offset_table;
                coordinate = (uint16_t)(coordinate - offsets[mapped_code]);
            }

            coordinate = (uint16_t)(coordinate +
                                    (int8_t)context[0x29]);
            *(uint16_t *)(void *)((uint8_t *)entry + 0x1E) =
                (uint16_t)(cursor | pending_marker);
            pending_marker = 0;

            if (record_pointer != 0) {
                uint32_t packed = RuntimeObjectSelection_ReadWord(entry, 0x10);
                packed &= 0xC1FFFCFFu;
                packed |= record_flags;
                RuntimeObjectSelection_WriteWord(entry, 0x10, packed);
                RuntimeObjectSelection_WriteWord(entry, 0x30,
                                                  record_pointer);
            }

            entry_pointer = RuntimeObjectSelection_ReadWord(entry, 4);
        }

        cursor = (uint16_t)(cursor + coordinate);
    }

    RuntimeObjectSelection_ApplyLayout(context_pointer);
    *(uint16_t *)(void *)(context + 0x0A) = cursor;
    return 1;
}
