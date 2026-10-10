#include <stddef.h>
#include <stdint.h>

extern void *Heap_Alloc(uint32_t size);
extern void sub_08057B60(const void *message);

/* Heap_Alloc returns a block descriptor; its +0/+4 fields are base and size. */
typedef struct ArmRasterHeapBlock {
    uint32_t address;
    uint32_t size;
    uint32_t previous;
    uint32_t next;
} ArmRasterHeapBlock;

typedef struct ArmRasterRelocation {
    uint8_t table_byte_offset;
    uint8_t context_byte_offset;
} ArmRasterRelocation;

/*
 * Relocations consumed by 0x0805EFC0. Three table slots (+0x3C, +0x4C,
 * +0x50) are not rebased into context fields; the original routine leaves
 * the corresponding context offsets untouched as well.
 */
static const ArmRasterRelocation sArmRasterRelocations[] = {
    {0x00, 0x04}, {0x04, 0x08}, {0x08, 0x0C}, {0x0C, 0x10},
    {0x10, 0x14}, {0x14, 0x18}, {0x18, 0x1C}, {0x1C, 0x20},
    {0x20, 0x24}, {0x24, 0x28}, {0x28, 0x2C}, {0x2C, 0x30},
    {0x30, 0x34}, {0x34, 0x38}, {0x38, 0x3C},
    {0x40, 0x44}, {0x44, 0x48}, {0x48, 0x4C},
    {0x54, 0x58}, {0x58, 0x5C}, {0x5C, 0x60}, {0x60, 0x64},
    {0x64, 0x68}, {0x68, 0x6C}, {0x6C, 0x70}, {0x70, 0x74},
    {0x74, 0x78}, {0x78, 0x7C}, {0x7C, 0x80}
};

/* ROM image and the immediately following relocation/offset table. */
#define ARM_RASTER_IMAGE_BASE ((const uint8_t *)0x080641B8u)
#define ARM_RASTER_RELOCATION_TABLE ((const uint32_t *)0x08064EDCu)
#define ARM_RASTER_IMAGE_SIZE 0x0D24u
#define DMA3_SOURCE (*(volatile uint32_t *)0x040000D4u)
#define DMA3_DESTINATION (*(volatile uint32_t *)0x040000D8u)
#define DMA3_CONTROL (*(volatile uint32_t *)0x040000DCu)

/*
 * Reconstructed from 0x0805EFC0.
 *
 * context points to a runtime descriptor. If existing_descriptor_ref is NULL,
 * allocate a fresh 0xD24-byte heap block and DMA-copy the ARM image into its
 * address. Otherwise reuse the descriptor pointer stored at *existing_ref.
 * The context's +0 field retains the heap descriptor pointer; the fields
 * listed above receive rebased pointers into descriptor->address.
 */
void *ArmRaster_LoadModule(void *context, void *existing_descriptor_ref)
{
    uint8_t *context_bytes = (uint8_t *)context;
    ArmRasterHeapBlock *block;

    if (existing_descriptor_ref == NULL) {
        block = (ArmRasterHeapBlock *)Heap_Alloc(ARM_RASTER_IMAGE_SIZE);
        *(ArmRasterHeapBlock **)context_bytes = block;
        if (block == NULL) {
            sub_08057B60((const void *)0x08755668u);
            return NULL;
        }

        DMA3_SOURCE = (uint32_t)(uintptr_t)ARM_RASTER_IMAGE_BASE;
        DMA3_DESTINATION = block->address;
        DMA3_CONTROL = (block->size >> 2) | 0x84000000u;
        (void)DMA3_CONTROL;
    } else {
        block = *(ArmRasterHeapBlock **)existing_descriptor_ref;
        *(ArmRasterHeapBlock **)context_bytes = block;
    }

    for (size_t i = 0;
         i < sizeof(sArmRasterRelocations) / sizeof(sArmRasterRelocations[0]);
         ++i) {
        const ArmRasterRelocation *reloc = &sArmRasterRelocations[i];
        uint32_t offset = ARM_RASTER_RELOCATION_TABLE[
            reloc->table_byte_offset / sizeof(uint32_t)];
        *(uint32_t *)(context_bytes + reloc->context_byte_offset) =
            block->address + offset;
    }

    return context;
}
