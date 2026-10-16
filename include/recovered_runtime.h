#ifndef RECOVERED_RUNTIME_H
#define RECOVERED_RUNTIME_H
#include <stdint.h>

void ResourceTable_Init(void *context);
void RuntimeMemory_Init(void);
void FrameEvent_Service(void);

void ResourceTable_Generate(void *context, uint32_t index,
                            uint32_t *out_a, uint32_t *out_b);
uint32_t ResourceTable_Transform(uint32_t value);
uint32_t ResourceTable_Combine(uint32_t value, void *context);
void *Heap_Alloc(uint32_t size);
void sub_08057B60(const void *message);
/* ROM saves r0-r3 and returns; callers pass one to three arguments. */
void sub_08057C5C(const void *message, ...);
void FrameEvent_UpdateTiming(void);

#endif
