#ifndef UBJ_RUNTIME_OBJECT_SELECTION_H
#define UBJ_RUNTIME_OBJECT_SELECTION_H

#include <stdint.h>

/* Recovered from the Thumb entry at 0x08050AA0. Field meanings stay neutral
 * where the ROM establishes layout and data flow but not gameplay purpose. */
uint32_t RuntimeObject_InitializeEntryTable(void *manager,
                                           const void *source_descriptor,
                                           uint32_t selected_index);

void RuntimeObjectSelection_InitializeContext(
    void *context, uint32_t object_value0, uint32_t object_value4,
    int32_t position_x, int32_t position_y, uint32_t extent,
    uint32_t selection_flags);

/* ROM 0x0806124C. Releases the embedded resource-node segment and clears the
 * context halfword at +0x0A. */
void RuntimeObjectSelection_ResetContext(void *context);

/* ROM 0x080614E0. Consumes a zero-terminated code stream and initializes the
 * corresponding nodes in the selection context's resource chain. The byte
 * argument becomes each entry's control nibble. */
uint32_t RuntimeObjectSelection_Finalize(void *context,
                                         const uint8_t *code_stream,
                                         uint32_t control_value);

/* ROM 0x08061260. Assigns fixed-point positions to the context's node chain,
 * splitting groups when their projected cursor exceeds the extent. */
void RuntimeObjectSelection_ApplyLayout(void *context);

/* ROM 0x080614D4. Stores the low halfword as selection flags, then applies
 * the layout routine. */
void RuntimeObjectSelection_SetFlagsAndApplyLayout(void *context,
                                                    uint32_t flags);

/* ROM 0x08061684. Resets the selection context, runs the finalizer, and
 * returns its low byte. */
uint32_t RuntimeObjectSelection_Dispatch(void *context,
                                         const uint8_t *code_stream,
                                         uint32_t object_byte);

/* Packed selection-context fields recovered from nearby Thumb helpers. */
void RuntimeObjectSelection_AddStateBits(void *context, uint32_t value);
uint32_t RuntimeObjectSelection_GetStateBits(const void *context);
void RuntimeObjectSelection_SetControlNibble(void *context, uint32_t value);
void RuntimeObjectSelection_SetByte19ToOne(void *context);
void RuntimeObjectSelection_SetByte19ToZero(void *context);

/* ROM 0x08064F5C. Counts nonzero bytes in a selection stream, excluding the
 * special byte value 32. */
uint32_t RuntimeObjectSelection_CountEntries(const uint8_t *code_stream);

/* ROM helper at 0x08063AC4. The incoming record pointer is ignored. */
uint32_t sub_08063AC4(uint32_t ignored_record_pointer);

#endif
