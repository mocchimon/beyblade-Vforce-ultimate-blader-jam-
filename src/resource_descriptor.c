#include <stddef.h>
#include <stdint.h>

/*
 * Recovered from 0x0805FEF4.  This is a heap-backed surface/context
 * constructor, despite the historical ResourceDescriptor name.  The
 * payload is 0x44 bytes of metadata followed by two dimension-dependent
 * regions.  Unknown fields are kept explicit rather than given guessed
 * graphics semantics.
 */
typedef struct ResourceDescriptor {
    uint8_t  field00;
    uint8_t  field01;
    uint8_t  field02;
    uint8_t  field03;
    uint8_t  width;        /* +0x04: first argument */
    uint8_t  field05;
    uint8_t  format;       /* +0x06: low byte of third argument */
    uint8_t  field07;
    uint32_t field08;
    uint32_t field0C;      /* heap descriptor */
    uint32_t derived_10;   /* +0x10: fixed-point/interval value */
    uint32_t field14;
    uint32_t height;       /* +0x18: second argument */
    uint32_t field1C;
    uint32_t field20;
    uint32_t region_a;     /* +0x24 */
    uint32_t region_a_end; /* +0x28 */
    uint32_t region_b;     /* +0x2C */
    uint32_t region_b_end; /* +0x30 */
    uint32_t region_b_copy;/* +0x34 */
    uint32_t region_b_copy_end; /* +0x38 */
    uint32_t region_a_copy;/* +0x3C */
    uint32_t region_a_copy_end; /* +0x40 */
} ResourceDescriptor;

_Static_assert(offsetof(ResourceDescriptor, field0C) == 0x0C,
               "surface context field offset mismatch");
_Static_assert(offsetof(ResourceDescriptor, derived_10) == 0x10,
               "surface context field offset mismatch");
_Static_assert(offsetof(ResourceDescriptor, height) == 0x18,
               "surface context field offset mismatch");
_Static_assert(offsetof(ResourceDescriptor, region_a) == 0x24,
               "surface context field offset mismatch");
_Static_assert(sizeof(ResourceDescriptor) == 0x44,
               "surface context header size mismatch");

extern void *Heap_AllocAlt(uint32_t size);
extern void sub_08057C5C(const void *message, uint32_t argument);
extern uint32_t sub_080660A8(uint32_t numerator, uint32_t denominator);

#define SURFACE_CONTEXT_GLOBAL (*(volatile ResourceDescriptor **)0x03005DC4u)
#define REG16(address) (*(volatile uint16_t *)(uintptr_t)(address))

/* 0x0805FEF4: arguments are width, height, and a compact format value. */
void ResourceDescriptor_Init(uint32_t width, uint32_t height, uint32_t format)
{
    uint32_t area = width * height;
    uint32_t region_bytes = (area << 1) + (height << 1);
    uint32_t allocation_size = 0x44u + region_bytes;
    void *descriptor;
    ResourceDescriptor *context;
    uint32_t region_a;
    uint32_t region_b;
    uint32_t quotient;

    /* The original reports a diagnostic if height is not 4-aligned, but
       continues into allocation and setup. */
    if ((height & 3u) != 0)
        sub_08057C5C((const void *)0x08755858u, 0);

    descriptor = Heap_AllocAlt(allocation_size);
    if (descriptor == 0) {
        sub_08057C5C((const void *)0x087558A8u, allocation_size);
        return; /* The original diagnostic path is expected not to return. */
    }

    context = (ResourceDescriptor *)(uintptr_t)*(uint32_t *)descriptor;
    SURFACE_CONTEXT_GLOBAL = context;
    context->field0C = (uint32_t)(uintptr_t)descriptor;
    context->field00 = 0;
    context->field01 = 0;
    context->field02 = 0;
    context->width = (uint8_t)width;
    context->field03 = 0;
    context->format = (uint8_t)format;
    context->field05 = 0;
    context->height = height;
    context->field1C = 0;
    context->field20 = 0x10;

    region_a = (uint32_t)(uintptr_t)context + 0x44u;
    region_b = region_a + (height << 1);
    context->region_a = region_a;
    context->region_a_end = region_a + height;
    context->region_b = region_b;
    context->region_b_end = region_b + area;
    context->region_b_copy = region_b;
    context->region_b_copy_end = region_b + area;
    context->region_a_copy = region_a;
    context->region_a_copy_end = region_a + height;

    /* The binary divides 0x359E4 by (height >> 1), then subtracts the
       quotient from 0x20000. Keep the exact arithmetic and denominator. */
    quotient = sub_080660A8(0x000359E4u, height >> 1);
    context->derived_10 = 0x00020000u - quotient;
    context->field14 = 0;

    /* Exact halfword writes observed at 0x04000134 and 0x04000128. Their
       hardware-level role is not inferred here. */
    REG16(0x04000134u) = 0;
    REG16(0x04000128u) = (uint16_t)(0x6000u | (format & 0xFFFFu));
}
