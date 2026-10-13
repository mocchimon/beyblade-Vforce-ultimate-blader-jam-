#include <stddef.h>
#include <stdint.h>

/* Reconstructed from 0x080631D4 and 0x08063210. */
typedef struct RuntimeBufferDescriptor {
    uint32_t source;          /* +0x00 */
    uint16_t destination_x;   /* +0x04, in halfwords */
    uint16_t row_stride;      /* +0x06, in halfwords */
    int16_t row_count;        /* +0x08 */
    uint16_t reserved0;       /* +0x0A */
    uint32_t buffer_payload;  /* +0x0C */
    void *buffer_descriptor;  /* +0x10: heap block descriptor */
} RuntimeBufferDescriptor;

_Static_assert(offsetof(RuntimeBufferDescriptor, destination_x) == 0x04,
               "runtime buffer x offset mismatch");
_Static_assert(offsetof(RuntimeBufferDescriptor, row_stride) == 0x06,
               "runtime buffer stride offset mismatch");
_Static_assert(offsetof(RuntimeBufferDescriptor, row_count) == 0x08,
               "runtime buffer count offset mismatch");
_Static_assert(offsetof(RuntimeBufferDescriptor, buffer_payload) == 0x0C,
               "runtime buffer payload offset mismatch");
_Static_assert(offsetof(RuntimeBufferDescriptor, buffer_descriptor) == 0x10,
               "runtime buffer allocation descriptor offset mismatch");
_Static_assert(sizeof(RuntimeBufferDescriptor) == 0x14,
               "runtime buffer descriptor size mismatch");

extern void *Heap_Alloc(uint32_t size);

/*
 * 0x080631D4. The ROM rounds the two halfword dimensions down to even values,
 * allocates row_stride * row_count * 2 bytes, and stores both the heap block
 * descriptor and its payload pointer. Argument names are intentionally based
 * on the observed layout rather than an assumed game-specific use.
 */
void RuntimeBuffer_Init(RuntimeBufferDescriptor *descriptor,
                        const void *source,
                        uint32_t destination_x,
                        uint32_t row_stride,
                        uint32_t row_count)
{
    uint32_t aligned_x = destination_x & ~1u;
    uint32_t aligned_stride = row_stride & ~1u;
    void *allocation = Heap_Alloc(2u * aligned_stride * row_count);

    descriptor->source = (uint32_t)(uintptr_t)source;
    descriptor->destination_x = (uint16_t)aligned_x;
    descriptor->row_stride = (uint16_t)aligned_stride;
    descriptor->row_count = (int16_t)row_count;
    descriptor->buffer_descriptor = allocation;
    descriptor->buffer_payload = *(const uint32_t *)allocation;
}

/*
 * 0x08063210. The copy routine is selected by the ROM function-pointer slot
 * at 0x0807D998 and invoked through the shared bx-r3 trampoline at 0x08065C44.
 * The third argument is the row byte count; destination_x is applied in
 * 16-bit units. The concrete copy backend remains a runtime-installed target.
 */
void RuntimeBuffer_CopyRow(const RuntimeBufferDescriptor *descriptor,
                           void *destination,
                           int32_t row_index)
{
    typedef void (*CopyCallback)(const void *source, void *destination,
                                 uint32_t byte_count);
    CopyCallback copy;
    const uint8_t *source_row;
    uint8_t *destination_row;
    uint32_t row_bytes;

    if (row_index < 0 || row_index >= descriptor->row_count)
        return;

    copy = (CopyCallback)(uintptr_t)
        *(volatile const uint32_t *)(uintptr_t)0x0807D998u;
    row_bytes = (uint32_t)descriptor->row_stride * 2u;
    source_row = (const uint8_t *)(uintptr_t)descriptor->buffer_payload
        + (uint32_t)row_index * row_bytes;
    destination_row = (uint8_t *)destination
        + (uint32_t)descriptor->destination_x * 2u;
    copy(source_row, destination_row, row_bytes);
}
