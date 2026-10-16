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
    uint32_t ignored_object_value8);

/* ROM helper at 0x08063AC4. The incoming record pointer is ignored. */
uint32_t sub_08063AC4(uint32_t ignored_record_pointer);

#endif
