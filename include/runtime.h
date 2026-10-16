#ifndef UBJ_RUNTIME_H
#define UBJ_RUNTIME_H

#include <stdint.h>

/* Reconstructed heap/free-list primitives.  Names are semantic and remain
 * provisional until more callers are analyzed. */
void *Heap_Alloc(uint32_t size);
void *Heap_AllocAlt(uint32_t size);
void Heap_Free(void *block);
void *Heap_FindFreeBlock(void *head, uint32_t size);
void *Heap_InsertBlock(uint32_t size, uint32_t arena_base,
                       uint32_t arena_size, void *current_head,
                       void *descriptor, void *head_pointer);
void *Heap_FindAvailable(void *head, uint32_t count);

/* Startup/frame memory-pool initialization. */
void Runtime_ResetPools(uint32_t countA, uint32_t countB);

/* Controller/input mapping state. */
void Input_ResetMappings(void);
void Input_SetMapping(uint32_t index, uint32_t value);
void Input_SetState(uint32_t state);
uint32_t Input_TestMask(uint32_t mask);

/* Recovered ARM7TDMI arithmetic helpers and compiler ABI support. */
uint32_t Math_DivideUnsigned(uint32_t numerator, uint32_t denominator);
int32_t Math_DivideSigned(int32_t numerator, int32_t denominator);
uint32_t __aeabi_uidiv(uint32_t numerator, uint32_t denominator);

/* ROM-confirmed return-only service entries. */
void sub_08057B60(const void *message);
/* ROM saves r0-r3 and returns; callers pass one to three arguments. */
void sub_08057C5C(const void *message, ...);

#endif

/* Child command/event queue recovered from 0x080587B8/0x08058900. */
void ChildQueue_Append(void *child, uint32_t value0, uint32_t value2,
                       uint32_t value3, uint32_t value1);
void ChildQueue_Clear(void *child);
