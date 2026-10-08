#ifndef UBJ_RUNTIME_H
#define UBJ_RUNTIME_H

#include <stdint.h>

/* Reconstructed heap/free-list primitives.  Names are semantic and remain
 * provisional until more callers are analyzed. */
void *Heap_Alloc(uint32_t size);
void *Heap_AllocAlt(uint32_t size);
void Heap_Free(void *block);
void *Heap_FindFreeBlock(void *head, uint32_t size);
void *Heap_InsertBlock(void *node, uint32_t size);
void *Heap_FindAvailable(void *head, uint32_t count);

/* Startup/frame memory-pool initialization. */
void Runtime_ResetPools(uint32_t countA, uint32_t countB);

/* Controller/input mapping state. */
void Input_ResetMappings(void);
void Input_SetMapping(uint32_t index, uint32_t value);
void Input_SetState(uint32_t state);
uint32_t Input_TestMask(uint32_t mask);

#endif

/* Child command/event queue recovered from 0x080587B8/0x08058900. */
void ChildQueue_Append(void *child, uint32_t value0, uint32_t value2,
                       uint32_t value3, uint32_t value1);
void ChildQueue_Clear(void *child);
