#include <stdint.h>

/* ROM 0x0804AF08, Thumb. This is the consumer of the 32-entry directory.
 * The +0x0C26 and +0x0C2C fields are relative to the context base at
 * *(u32 *)0x03000FB0. The exact meanings of the two external calls remain
 * provisional, so the names below describe only their observed contract.
 */
#define RESOURCE_DIRECTORY ((const uint32_t *)0x08075640u)

/* Full implementation of this same ROM entry is in resource_handle.c. */
extern void RuntimeResource_Select(uint32_t index); /* 0x0804AF08 */

/* Pure address selection, preserving the original unsigned index arithmetic.
 * Caller must ensure index is within the 32-entry directory.
 */
void ResourceDirectory_GetBounds(uint32_t index, uint32_t *pointer_table,
                                 uint32_t *index_descriptor)
{
    *pointer_table = RESOURCE_DIRECTORY[index * 2u];
    *index_descriptor = RESOURCE_DIRECTORY[index * 2u + 1u];
}

void ResourceDirectory_Select(uint16_t index)
{
    RuntimeResource_Select(index);
}
