#include <stdint.h>

/* ROM 0x0804AF08, Thumb. This is the consumer of the 32-entry directory.
 * The +0x0C26 and +0x0C2C fields are relative to the context base at
 * *(u32 *)0x03000FB0. The exact meanings of the two external calls remain
 * provisional, so the names below describe only their observed contract.
 */
#define RESOURCE_DIRECTORY ((const uint32_t *)0x08075640u)
#define CONTEXT_BASE_PTR (*(volatile uint8_t * volatile *)0x03000FB0u)
#define RESOURCE_SESSION_PTR (*(volatile uint8_t * volatile *)0x03000F48u)

extern void ResourceDirectory_Prepare(void); /* 0x0804AF60 */
extern uint32_t ResourceDirectory_Create(uint32_t pointer_table,
                                         uint32_t index_descriptor); /* 0x080629B4 */
extern void ResourceDirectory_Apply(uint32_t handle,
                                    uint16_t setting); /* 0x08062AF8 */

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
    uint32_t pointer_table, index_descriptor, handle;
    ResourceDirectory_Prepare();
    *(volatile uint16_t *)(CONTEXT_BASE_PTR + 0x0C26u) = index;
    ResourceDirectory_GetBounds(index, &pointer_table, &index_descriptor);
    handle = ResourceDirectory_Create(pointer_table, index_descriptor);
    *(volatile uint32_t *)(CONTEXT_BASE_PTR + 0x0C2Cu) = handle;
    ResourceDirectory_Apply(handle,
        *(volatile uint16_t *)(RESOURCE_SESSION_PTR + 0x06E6u));
}
