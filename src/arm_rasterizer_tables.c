#include <stddef.h>
#include <stdint.h>
#include "arm_rasterizer.h"

/*
 * Source reconstruction of ARM image helper 0x08064C38.
 *
 * The routine appends a signed 16-bit item to an indexed node table and links
 * that node into the selected bucket. The structure names are intentionally
 * layout-oriented: original type names and the larger subsystem's semantics
 * are not known yet.
 */
typedef struct {
    uint8_t unknown_00[4];
    int16_t node_count;             /* +0x04 */
    uint8_t unknown_06[2];
    int16_t *bucket_links;          /* +0x08: 4-byte bucket records */
    int16_t *node_links;            /* +0x0C: 4-byte node records */
} ArmRaster_LinkTable;

void ArmRaster_InsertBucketItem(ArmRaster_LinkTable *table,
                                uint32_t bucket_index,
                                int16_t item)
{
    uint32_t index = (uint16_t)table->node_count;
    int16_t *node = table->node_links + index * 2u;
    int16_t *bucket = table->bucket_links + bucket_index * 2u;

    node[0] = item;
    node[1] = -1;

    if (bucket[0] < 0) {
        /* Empty bucket: initialize both words to this node index. */
        bucket[0] = (int16_t)index;
        bucket[1] = (int16_t)index;
    } else {
        /* Non-empty bucket: append after its current tail. */
        int16_t tail = bucket[1];
        table->node_links[(uint16_t)tail * 2u + 1u] = (int16_t)index;
        bucket[1] = (int16_t)index;
    }

    table->node_count = (int16_t)(table->node_count + 1);
}

/*
 * Source reconstruction of ARM image helper 0x08064C8C.
 *
 * The input descriptor offsets are retained directly from the ROM because
 * their original C structure is unknown. A selection list may restrict the
 * primitive records processed; each selection-map entry is {start,count}.
 */
static void ArmRaster_AddPrimitiveToBucket(ArmRaster_LinkTable *bucket_table,
                                           const uint8_t *primitive_ref,
                                           const uint8_t *vertex_records,
                                           uint32_t primitive_index)
{
    const uint32_t *refs = (const uint32_t *)primitive_ref;
    uint16_t a = (uint16_t)refs[0];
    uint16_t b = (uint16_t)(refs[0] >> 16);
    uint16_t c = (uint16_t)refs[1];
    uint16_t flags = (uint16_t)(refs[1] >> 16);
    const uint8_t *va = vertex_records + (uint32_t)a * 0x10u;
    const uint8_t *vb = vertex_records + (uint32_t)b * 0x10u;
    const uint8_t *vc = vertex_records + (uint32_t)c * 0x10u;
    int alternate_bucket = (b == c) || ((flags & 1u) != 0);
    int32_t bucket_value;

    if (!alternate_bucket) {
        int32_t dx_ab = *(const int32_t *)(va + 0x00) -
                        *(const int32_t *)(vb + 0x00);
        int32_t dy_ab = *(const int32_t *)(va + 0x04) -
                        *(const int32_t *)(vb + 0x04);
        int32_t dx_cb = *(const int32_t *)(vc + 0x00) -
                        *(const int32_t *)(vb + 0x00);
        int32_t dy_cb = *(const int32_t *)(vc + 0x04) -
                        *(const int32_t *)(vb + 0x04);
        uint32_t determinant = (uint32_t)dx_ab * (uint32_t)dy_cb -
                               (uint32_t)dy_ab * (uint32_t)dx_cb;

        /* ARM's CMP/BGT observes the signed 32-bit result after wraparound. */
        if ((int32_t)determinant > 0)
            return;
    }

    /* Preserve the ARM 32-bit add/ASR sequence used to choose the bucket. */
    uint32_t first_sum = (uint32_t)*(const int32_t *)(va + 0x08) +
                         (uint32_t)*(const int32_t *)(vb + 0x08);
    int32_t half_sum = (int32_t)first_sum >> 1;
    uint32_t second_sum = (uint32_t)half_sum +
                          (uint32_t)*(const int32_t *)(vc + 0x08);
    bucket_value = (int32_t)second_sum >> 8;
    bucket_value += alternate_bucket ? 17 : 16;
    bucket_value &= 31;

    ArmRaster_InsertBucketItem(bucket_table,
                               (uint32_t)(31 - bucket_value),
                               (int16_t)primitive_index);
}

void ArmRaster_BuildEdgeBuckets(const void *input_descriptor,
                                ArmRaster_LinkTable *bucket_table,
                                const int16_t *selection_list)
{
    const uint8_t *input = (const uint8_t *)input_descriptor;
    const uint8_t *header = *(const uint8_t * const *)(input + 0x00);
    const uint8_t *primitive_refs =
        *(const uint8_t * const *)(input + 0x08);
    const uint8_t *vertex_records =
        *(const uint8_t * const *)(input + 0x10);
    const uint8_t *selection_map = selection_list != NULL
        ? *(const uint8_t * const *)(input + 0x64) : NULL;
    uint32_t default_count = *(const uint16_t *)(header + 0x06);

    if (selection_list == NULL) {
        uint32_t index = 0;
        uint32_t remaining = default_count;
        do {
            ArmRaster_AddPrimitiveToBucket(bucket_table,
                                           primitive_refs + index * 8u,
                                           vertex_records, index);
            ++index;
            --remaining;
        } while (remaining != 0);
        return;
    }

    while (*selection_list >= 0) {
        uint16_t selection = (uint16_t)*selection_list++;
        const int16_t *range =
            (const int16_t *)(selection_map + (uint32_t)selection * 4u);
        uint32_t index = (uint16_t)range[0];
        int32_t remaining = range[1];

        do {
            ArmRaster_AddPrimitiveToBucket(bucket_table,
                                           primitive_refs + index * 8u,
                                           vertex_records, index);
            ++index;
            --remaining;
        } while (remaining != 0);
    }
}

/*
 * The ARM image's reciprocal table pointer is stored at ROM 0x08064214 and
 * contains 0x0874D1E4. Keep the source reconstruction anchored to that ROM
 * table; it is not copied into this project because the original ROM remains
 * an analysis input rather than a distributable project asset.
 */
#define ARMRASTER_RECIPROCAL_TABLE_ADDRESS 0x0874D1E4u

static int32_t ArmRaster_SignedBits(uint32_t bits)
{
    if ((bits & 0x80000000u) == 0)
        return (int32_t)bits;
    return -1 - (int32_t)(~bits);
}

static int32_t ArmRaster_Asr32(uint32_t bits, unsigned shift)
{
    uint32_t shifted;

    if (shift == 0)
        return ArmRaster_SignedBits(bits);

    shifted = bits >> shift;
    if ((bits & 0x80000000u) != 0)
        shifted |= ~(0xFFFFFFFFu >> shift);
    return ArmRaster_SignedBits(shifted);
}

static uint16_t ArmRaster_ReadU16(const uint8_t *bytes)
{
    return (uint16_t)((uint16_t)bytes[0] | ((uint16_t)bytes[1] << 8));
}

static int32_t ArmRaster_ReadS32(const uint8_t *bytes)
{
    uint32_t bits = (uint32_t)bytes[0] |
                    ((uint32_t)bytes[1] << 8) |
                    ((uint32_t)bytes[2] << 16) |
                    ((uint32_t)bytes[3] << 24);
    return ArmRaster_SignedBits(bits);
}

static void ArmRaster_WriteU8(uint8_t *bytes, uint32_t offset,
                              uint8_t value)
{
    bytes[offset] = value;
}

static void ArmRaster_WriteU16(uint8_t *bytes, uint32_t offset,
                               uint16_t value)
{
    bytes[offset] = (uint8_t)value;
    bytes[offset + 1u] = (uint8_t)(value >> 8);
}

static void ArmRaster_WriteU32(uint8_t *bytes, uint32_t offset,
                               uint32_t value)
{
    bytes[offset] = (uint8_t)value;
    bytes[offset + 1u] = (uint8_t)(value >> 8);
    bytes[offset + 2u] = (uint8_t)(value >> 16);
    bytes[offset + 3u] = (uint8_t)(value >> 24);
}

static int32_t ArmRaster_WrappedSubtract(int32_t left, int32_t right)
{
    return ArmRaster_SignedBits((uint32_t)left - (uint32_t)right);
}

static int32_t ArmRaster_WrappedMultiply(int32_t left, int32_t right)
{
    return ArmRaster_SignedBits((uint32_t)left * (uint32_t)right);
}

/*
 * Reproduce the ARM image's reciprocal-table multiply and conditional ASR.
 * difference_shift is 2 for coordinates and 9 for the byte attribute at
 * record offset +0x0C.
 */
static int32_t ArmRaster_InterpolateSlope(int32_t difference, int32_t dy,
                                          unsigned difference_shift)
{
    const int16_t *reciprocal_table =
        (const int16_t *)(uintptr_t)ARMRASTER_RECIPROCAL_TABLE_ADDRESS;
    uint32_t dy_bits = (uint32_t)dy;
    uint32_t magnitude = dy < 0 ? 0u - dy_bits : dy_bits;
    uint32_t numerator = (uint32_t)difference << difference_shift;
    int32_t reciprocal;
    uint32_t product;
    unsigned result_shift;

    if (dy < 0)
        numerator = 0u - numerator;

    reciprocal = reciprocal_table[magnitude];
    product = numerator * (uint32_t)reciprocal;
    result_shift = dy < 16 ? 12u : 16u;
    return ArmRaster_Asr32(product, result_shift);
}

static uint32_t ArmRaster_PackSlope(int32_t slope, uint32_t low_halfword)
{
    return (low_halfword & 0xFFFFu) | ((uint32_t)slope << 16);
}

static uint32_t ArmRaster_PackAttributeSlope(int32_t slope,
                                             uint8_t attribute)
{
    return ArmRaster_PackSlope(slope, (uint32_t)attribute << 7);
}

/* Branch target 0x08064724 handles the repeated second/third vertex index. */
static int ArmRaster_ProcessRepeatedIndex(uint8_t *output,
                                          const uint8_t *record_a,
                                          const uint8_t *record_b,
                                          uint16_t primitive_flags)
{
    int32_t y_a = ArmRaster_ReadS32(record_a + 4);
    int32_t y_b = ArmRaster_ReadS32(record_b + 4);
    int32_t top_row;
    int32_t bottom_row;
    int32_t row_count;

    if (y_a > y_b) {
        const uint8_t *record_swap = record_a;
        int32_t y_swap = y_a;
        record_a = record_b;
        record_b = record_swap;
        y_a = y_b;
        y_b = y_swap;
    }

    top_row = ArmRaster_Asr32((uint32_t)y_a, 6);
    bottom_row = ArmRaster_Asr32((uint32_t)y_b, 6);
    row_count = ArmRaster_WrappedSubtract(bottom_row, top_row);
    ArmRaster_WriteU8(output, 0x17, (uint8_t)top_row);
    if (row_count < 1)
        row_count = 1;
    ArmRaster_WriteU16(output, 0x14, (uint16_t)row_count);

    if (row_count <= 1) {
        int32_t x_a = ArmRaster_ReadS32(record_a);
        int32_t x_b = ArmRaster_ReadS32(record_b);

        if (x_a <= x_b) {
            ArmRaster_WriteU16(output, 0x04, (uint16_t)x_a);
            ArmRaster_WriteU16(output, 0x0C, (uint16_t)x_b);
        } else {
            ArmRaster_WriteU16(output, 0x04, (uint16_t)x_b);
            ArmRaster_WriteU16(output, 0x0C, (uint16_t)x_a);
        }
        ArmRaster_WriteU16(output, 0x1E,
                           (uint16_t)(((uint32_t)(primitive_flags | 1u))
                                      << 1));
        ArmRaster_WriteU32(output, 0x00, 0);
        ArmRaster_WriteU32(output, 0x08, 0);
        return 1;
    }

    {
        int32_t x_a = ArmRaster_ReadS32(record_a);
        int32_t x_b = ArmRaster_ReadS32(record_b);
        int32_t dy = ArmRaster_WrappedSubtract(y_b, y_a);
        int32_t slope = ArmRaster_InterpolateSlope(
            ArmRaster_WrappedSubtract(x_b, x_a), dy, 2);
        int32_t endpoint = ArmRaster_SignedBits((uint32_t)x_b +
                                                (uint32_t)slope);
        uint32_t magnitude = slope < 0 ? 0u - (uint32_t)slope
                                       : (uint32_t)slope;

        ArmRaster_WriteU16(output, 0x10, (uint16_t)x_b);
        ArmRaster_WriteU16(output, 0x06, (uint16_t)slope);
        if (magnitude < 64u)
            magnitude = 64u;

        if (slope >= 0) {
            ArmRaster_WriteU16(output, 0x0C, (uint16_t)endpoint);
            ArmRaster_WriteU16(output, 0x04,
                               (uint16_t)((uint32_t)endpoint - magnitude));
        } else {
            ArmRaster_WriteU16(output, 0x04, (uint16_t)endpoint);
            ArmRaster_WriteU16(output, 0x0C,
                               (uint16_t)((uint32_t)endpoint + magnitude));
        }
        ArmRaster_WriteU16(output, 0x1E,
                           (uint16_t)(((uint32_t)(primitive_flags | 1u))
                                      << 1));
        ArmRaster_WriteU32(output, 0x00, 0);
        ArmRaster_WriteU32(output, 0x08, 0);
    }
    return 1;
}

typedef struct {
    const uint8_t *record;
    int32_t y;
} ArmRaster_Vertex;

/* Source reconstruction of the ARM image entry at ROM 0x08064364. */
int ArmRaster_ProcessPrimitiveEdges(void *output_pointer,
                                    const void *coordinate_records_pointer,
                                    const void *primitive_record_pointer)
{
    uint8_t *output = (uint8_t *)output_pointer;
    const uint8_t *coordinate_records =
        (const uint8_t *)coordinate_records_pointer;
    const uint8_t *primitive_record = (const uint8_t *)primitive_record_pointer;
    uint16_t index0 = ArmRaster_ReadU16(primitive_record + 0x00);
    uint16_t index1 = ArmRaster_ReadU16(primitive_record + 0x02);
    uint16_t index2 = ArmRaster_ReadU16(primitive_record + 0x04);
    uint16_t primitive_flags = ArmRaster_ReadU16(primitive_record + 0x06);
    ArmRaster_Vertex vertices[3];
    int32_t min_y;
    int32_t middle_y;
    int32_t max_y;
    int32_t row_count;
    int32_t upper_row_count;
    int32_t dy_upper;
    int32_t dy_total;
    int32_t dy_lower;
    int32_t x_min;
    int32_t x_middle;
    int32_t x_max;
    uint8_t attr_min;
    uint8_t attr_middle;
    uint8_t attr_max;
    int orientation;
    int32_t upper_x_slope;

    vertices[0].record = coordinate_records + (uint32_t)index0 * 0x10u;
    vertices[1].record = coordinate_records + (uint32_t)index1 * 0x10u;
    vertices[2].record = coordinate_records + (uint32_t)index2 * 0x10u;
    vertices[0].y = ArmRaster_ReadS32(vertices[0].record + 4);
    vertices[1].y = ArmRaster_ReadS32(vertices[1].record + 4);
    vertices[2].y = ArmRaster_ReadS32(vertices[2].record + 4);

    if (index1 == index2) {
        return ArmRaster_ProcessRepeatedIndex(output, vertices[0].record,
                                              vertices[1].record,
                                              primitive_flags);
    }

    /* Stable three-item sort matching the ARM CMP/BLE swap sequence. */
    if (vertices[0].y > vertices[1].y) {
        ArmRaster_Vertex swap = vertices[0];
        vertices[0] = vertices[1];
        vertices[1] = swap;
    }
    if (vertices[0].y > vertices[2].y) {
        ArmRaster_Vertex swap = vertices[0];
        vertices[0] = vertices[2];
        vertices[2] = swap;
    }
    if (vertices[1].y > vertices[2].y) {
        ArmRaster_Vertex swap = vertices[1];
        vertices[1] = vertices[2];
        vertices[2] = swap;
    }

    min_y = vertices[0].y;
    middle_y = vertices[1].y;
    max_y = vertices[2].y;
    row_count = ArmRaster_WrappedSubtract(
        ArmRaster_Asr32((uint32_t)max_y, 6),
        ArmRaster_Asr32((uint32_t)min_y, 6));
    if (row_count <= 0)
        return 0;

    upper_row_count = ArmRaster_WrappedSubtract(
        ArmRaster_Asr32((uint32_t)max_y, 6),
        ArmRaster_Asr32((uint32_t)middle_y, 6));
    ArmRaster_WriteU8(output, 0x17,
                      (uint8_t)ArmRaster_Asr32((uint32_t)min_y, 6));
    ArmRaster_WriteU16(output, 0x14,
                       (uint16_t)((uint32_t)row_count |
                                  ((uint32_t)upper_row_count << 8)));

    dy_upper = ArmRaster_WrappedSubtract(max_y, middle_y);
    dy_total = ArmRaster_WrappedSubtract(max_y, min_y);
    dy_lower = ArmRaster_WrappedSubtract(dy_total, dy_upper);
    x_min = ArmRaster_ReadS32(vertices[0].record);
    x_middle = ArmRaster_ReadS32(vertices[1].record);
    x_max = ArmRaster_ReadS32(vertices[2].record);
    attr_min = vertices[0].record[0x0C];
    attr_middle = vertices[1].record[0x0C];
    attr_max = vertices[2].record[0x0C];

    orientation = ArmRaster_WrappedMultiply(
                      ArmRaster_WrappedSubtract(x_middle, x_min), dy_lower) <=
                  ArmRaster_WrappedMultiply(
                      ArmRaster_WrappedSubtract(x_max, x_min), dy_total);
    upper_x_slope = ArmRaster_InterpolateSlope(
        ArmRaster_WrappedSubtract(x_middle, x_max), dy_upper, 2);

    if (row_count == upper_row_count) {
        int32_t long_x_slope = ArmRaster_InterpolateSlope(
            ArmRaster_WrappedSubtract(x_middle, x_min), dy_total, 2);
        uint32_t long_x = ArmRaster_PackSlope(long_x_slope,
                                              (uint32_t)x_min);
        uint32_t upper_attr = ArmRaster_PackAttributeSlope(
            ArmRaster_InterpolateSlope(
                ArmRaster_WrappedSubtract((int32_t)attr_middle,
                                          (int32_t)attr_max),
                dy_upper, 9),
            attr_max);
        uint32_t long_attr = ArmRaster_PackAttributeSlope(
            ArmRaster_InterpolateSlope(
                ArmRaster_WrappedSubtract((int32_t)attr_middle,
                                          (int32_t)attr_min),
                dy_total, 9),
            attr_min);
        uint32_t upper_x = ArmRaster_PackSlope(upper_x_slope,
                                               (uint32_t)x_max);

        ArmRaster_WriteU16(output, 0x1E,
                           (uint16_t)((((uint32_t)primitive_flags &
                                        ~1u) << 1) | (uint32_t)orientation));
        if (orientation) {
            ArmRaster_WriteU32(output, 0x04, long_x);
            ArmRaster_WriteU32(output, 0x0C, upper_x);
            ArmRaster_WriteU32(output, 0x00, long_attr);
            ArmRaster_WriteU32(output, 0x08, upper_attr);
        } else {
            ArmRaster_WriteU32(output, 0x04, upper_x);
            ArmRaster_WriteU32(output, 0x0C, long_x);
            ArmRaster_WriteU32(output, 0x00, upper_attr);
            ArmRaster_WriteU32(output, 0x08, long_attr);
        }
        return 1;
    }

    {
        int32_t long_x_slope = ArmRaster_InterpolateSlope(
            ArmRaster_WrappedSubtract(x_middle, x_min), dy_total, 2);
        int32_t lower_x_slope = ArmRaster_InterpolateSlope(
            ArmRaster_WrappedSubtract(x_max, x_min), dy_lower, 2);
        uint32_t long_x = ArmRaster_PackSlope(long_x_slope,
                                              (uint32_t)x_min);
        uint32_t lower_x = ArmRaster_PackSlope(lower_x_slope,
                                               (uint32_t)x_min);
        uint32_t upper_attr = ArmRaster_PackAttributeSlope(
            ArmRaster_InterpolateSlope(
                ArmRaster_WrappedSubtract((int32_t)attr_middle,
                                          (int32_t)attr_max),
                dy_upper, 9),
            attr_max);
        uint32_t long_attr = ArmRaster_PackAttributeSlope(
            ArmRaster_InterpolateSlope(
                ArmRaster_WrappedSubtract((int32_t)attr_middle,
                                          (int32_t)attr_min),
                dy_total, 9),
            attr_min);
        uint32_t lower_attr = ArmRaster_PackAttributeSlope(
            ArmRaster_InterpolateSlope(
                ArmRaster_WrappedSubtract((int32_t)attr_max,
                                          (int32_t)attr_min),
                dy_lower, 9),
            attr_min);

        ArmRaster_WriteU32(output, 0x10,
                           ArmRaster_PackSlope(upper_x_slope,
                                               (uint32_t)x_max));
        ArmRaster_WriteU16(output, 0x1E,
                           (uint16_t)((((uint32_t)primitive_flags &
                                        ~1u) << 1) | (uint32_t)orientation));
        ArmRaster_WriteU32(output, 0x18, upper_attr);
        if (orientation) {
            ArmRaster_WriteU32(output, 0x04, long_x);
            ArmRaster_WriteU32(output, 0x0C, lower_x);
            ArmRaster_WriteU32(output, 0x00, long_attr);
            ArmRaster_WriteU32(output, 0x08, lower_attr);
        } else {
            ArmRaster_WriteU32(output, 0x04, lower_x);
            ArmRaster_WriteU32(output, 0x0C, long_x);
            ArmRaster_WriteU32(output, 0x00, lower_attr);
            ArmRaster_WriteU32(output, 0x08, long_attr);
        }
    }
    return 1;
}

/*
 * Reconstructed loop at ARM image offset +0xC28 (ROM 0x08064DE0).
 * bucket_count is at +0; bucket_heads and node_links are at +8 and +0x0C.
 * The second descriptor supplies primitive records at +8 and coordinate
 * records at +0x10. Each bucket node stores {primitive_index,next}.
 */
void ArmRaster_ProcessEdgeBuckets(const void *bucket_descriptor,
                                  const void *vertex_descriptor,
                                  const void *draw_list,
                                  void *output)
{
    const uint8_t *bucket_bytes = (const uint8_t *)bucket_descriptor;
    const uint8_t *vertex_bytes = (const uint8_t *)vertex_descriptor;
    uint32_t bucket_count = *(const uint16_t *)(bucket_bytes + 0x00);
    const int16_t *bucket_heads =
        *(const int16_t * const *)(bucket_bytes + 0x08);
    const int16_t *node_links =
        *(const int16_t * const *)(bucket_bytes + 0x0C);
    const uint8_t *primitive_records =
        *(const uint8_t * const *)(vertex_bytes + 0x08);
    const void *coordinate_records =
        *(const void * const *)(vertex_bytes + 0x10);

    for (uint32_t bucket_index = 0; bucket_index < bucket_count;
         ++bucket_index) {
        int16_t node_index = bucket_heads[bucket_index * 2u];
        while (node_index >= 0) {
            const int16_t *node = node_links + (uint16_t)node_index * 2u;
            uint16_t primitive_index = (uint16_t)node[0];
            const void *primitive_record =
                primitive_records + (uint32_t)primitive_index * 8u;

            if (ArmRaster_ProcessPrimitiveEdges(output, coordinate_records,
                                                primitive_record) != 0) {
                ArmRaster_DrawRows(output, draw_list);
            }
            node_index = node[1];
        }
    }
}
