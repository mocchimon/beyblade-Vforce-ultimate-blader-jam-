#ifndef UBJ_RESOURCE_NODE_H
#define UBJ_RESOURCE_NODE_H

#include <stdint.h>

/* ROM 0x08060D00. Releases a counted primary-node segment carried by the
 * embedded context and returns that segment to the primary free chain. */
void ResourceNode_ReleaseChain(void *context);

/* ROM 0x08060C40. Removes a contiguous batch from the primary free chain and
 * inserts it into the active list under the supplied class. */
void *ResourceNode_AllocateChain(void *context, uint32_t count,
                                 uint32_t resource_class);

/* ROM 0x08060DBC. Reuses or resizes the segment represented by context. */
void *ResourceNode_ResizeChain(void *context, uint32_t count,
                               uint32_t resource_class);

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
