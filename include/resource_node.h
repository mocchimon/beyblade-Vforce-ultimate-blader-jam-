#ifndef UBJ_RESOURCE_NODE_H
#define UBJ_RESOURCE_NODE_H

#include <stdint.h>

/* ROM 0x08060A04. The second incoming word is ignored by the routine. */
void *ResourceNode_AcquireByClass(uint32_t resource_class,
                                  uint32_t ignored_selected_index);

/* ROM 0x08060B8C. Several parameters remain neutral because the resource
 * record's higher-level meaning is not established. */
void ResourceNode_ConfigureSelectionEntry(
    void *entry, const void *metadata, uint32_t position_x,
    uint32_t ignored_position_y, uint32_t arg4, uint32_t arg5,
    uint32_t arg6, uint32_t arg7);

#endif
