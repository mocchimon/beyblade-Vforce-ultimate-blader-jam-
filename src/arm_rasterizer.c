#include <stddef.h>
#include <stdint.h>
#include "arm_rasterizer.h"

#define ARMRASTER_RECIPROCAL_TABLE_ADDRESS 0x0874D1E4u
#define ARMRASTER_PARAMETER_TABLE_ADDRESS  0x0874CC60u

static int32_t ArmRaster_SignedBits(uint32_t bits)
{
    if ((bits & 0x80000000u) == 0)
        return (int32_t)bits;
    return -1 - (int32_t)(~bits);
}

static int32_t ArmRaster_Asr32(uint32_t bits, unsigned shift)
{
    uint32_t shifted = bits >> shift;

    if ((bits & 0x80000000u) != 0)
        shifted |= ~(0xFFFFFFFFu >> shift);
    return ArmRaster_SignedBits(shifted);
}

static uint16_t ArmRaster_ReadU16(const uint8_t *bytes)
{
    return (uint16_t)((uint16_t)bytes[0] | ((uint16_t)bytes[1] << 8));
}

static int32_t ArmRaster_ReadS16(const uint8_t *bytes)
{
    uint16_t bits = ArmRaster_ReadU16(bytes);

    if ((bits & 0x8000u) == 0)
        return (int32_t)bits;
    return -1 - (int32_t)(uint16_t)~bits;
}

static uint32_t ArmRaster_ReadU32(const uint8_t *bytes)
{
    return (uint32_t)bytes[0] |
           ((uint32_t)bytes[1] << 8) |
           ((uint32_t)bytes[2] << 16) |
           ((uint32_t)bytes[3] << 24);
}

static int32_t ArmRaster_ReadS32(const uint8_t *bytes)
{
    return ArmRaster_SignedBits(ArmRaster_ReadU32(bytes));
}

static int32_t ArmRaster_ReadS8(const uint8_t *bytes)
{
    uint8_t bits = bytes[0];

    if ((bits & 0x80u) == 0)
        return (int32_t)bits;
    return -1 - (int32_t)(uint8_t)~bits;
}

static void ArmRaster_WriteU32(uint8_t *bytes, uint32_t offset,
                               uint32_t value)
{
    bytes[offset] = (uint8_t)value;
    bytes[offset + 1u] = (uint8_t)(value >> 8);
    bytes[offset + 2u] = (uint8_t)(value >> 16);
    bytes[offset + 3u] = (uint8_t)(value >> 24);
}

static void ArmRaster_WriteU16(uint8_t *bytes, uint32_t offset,
                               uint16_t value)
{
    bytes[offset] = (uint8_t)value;
    bytes[offset + 1u] = (uint8_t)(value >> 8);
}

static int32_t ArmRaster_Add32(int32_t left, int32_t right)
{
    return ArmRaster_SignedBits((uint32_t)left + (uint32_t)right);
}

static int32_t ArmRaster_Subtract32(int32_t left, int32_t right)
{
    return ArmRaster_SignedBits((uint32_t)left - (uint32_t)right);
}

static int32_t ArmRaster_Multiply32(int32_t left, int32_t right)
{
    return ArmRaster_SignedBits((uint32_t)left * (uint32_t)right);
}

static int32_t ArmRaster_InterpolateSamples(int32_t difference,
                                             uint32_t table_index,
                                             unsigned result_shift)
{
    const int16_t *table =
        (const int16_t *)(uintptr_t)ARMRASTER_RECIPROCAL_TABLE_ADDRESS;
    uint32_t product = (uint32_t)difference *
                       (uint32_t)table[table_index];

    return ArmRaster_Asr32(product, result_shift);
}

/* ROM 0x080641B8: emits one to three interpolated samples. */
static void ArmRaster_EmitSamples(uint8_t *destination, uint32_t control,
                                  int32_t start, int32_t end)
{
    uint32_t count = control & 0xFFu;
    uint32_t sample = ((uint32_t)start << 8) +
                      ((control & 0xFF00u) << 4);
    uint32_t delta = ((uint32_t)end - (uint32_t)start) << 8;
    uint32_t factor;
    int32_t step;

    destination[0] = (uint8_t)(sample >> 12);
    if (count < 2u)
        return;

    factor = count == 2u ? 0x8000u : 0x5555u;
    step = ArmRaster_Asr32(delta * factor, 16);
    sample += (uint32_t)step;
    destination[1] = (uint8_t)(sample >> 12);
    if (count == 2u)
        return;

    sample += (uint32_t)step;
    destination[2] = (uint8_t)(sample >> 12);
}

/* ROM 0x08064218: emits a packed-path span, preserving its sample sequence. */
static void ArmRaster_EmitPackedSamples(uint8_t *destination,
                                        uint32_t control,
                                        int32_t start, int32_t end)
{
    uint32_t count = control & 0xFFu;
    uint32_t table_index = count << 4;
    uint32_t sample = ((uint32_t)start << 8) +
                      ((control & 0xFF00u) << 4);
    uint32_t delta = ((uint32_t)end - (uint32_t)start) << 8;
    int32_t step;

    if (count == 0)
        return;

    step = ArmRaster_InterpolateSamples(
        ArmRaster_SignedBits(delta), table_index,
        table_index < 16u ? 12u : 16u);
    for (uint32_t i = 0; i < count; ++i) {
        destination[i] = (uint8_t)(sample >> 12);
        sample += (uint32_t)step;
    }
}

static void ArmRaster_DrawSpan(uint8_t *destination, int32_t width,
                               uint16_t flags, uint16_t attribute_start,
                               uint16_t attribute_end)
{
    uint32_t control;
    int32_t start = (int32_t)(attribute_start >> 7);
    int32_t end = (int32_t)(attribute_end >> 7);

    if (width <= 0)
        return;

    control = ((uint32_t)width & 0xFFu) |
               (((uint32_t)(flags & (uint16_t)~3u)) << 6);
    if (width >= 4)
        ArmRaster_EmitPackedSamples(destination, control, start, end);
    else
        ArmRaster_EmitSamples(destination, control, start, end);
}

/* Source reconstruction of ARM image entry 0x08064850. */
void ArmRaster_DrawRows(void *output_pointer, const void *destination_pointer)
{
    uint8_t *output = (uint8_t *)output_pointer;
    uint8_t *destination = (uint8_t *)destination_pointer;
    uint16_t flags = ArmRaster_ReadU16(output + 0x1E);
    uint32_t first_row = output[0x17];
    uint32_t row_base_offset = first_row << 6;
    int32_t remaining_rows = (int32_t)(ArmRaster_ReadU16(output + 0x14) &
                                       0xFFu);
    int32_t upper_rows = (int32_t)(ArmRaster_ReadU16(output + 0x14) >> 8);
    int32_t clip = (int32_t)first_row + remaining_rows - 31;

    if (clip >= 0) {
        remaining_rows -= clip;
        upper_rows -= clip;
    }
    if (remaining_rows <= 0)
        return;

    if ((flags & 2u) != 0) {
        int32_t slope = ArmRaster_ReadS16(output + 6);
        int32_t edge_a = slope < 0
            ? ArmRaster_ReadS16(output + 4)
            : ArmRaster_ReadS16(output + 12);
        int32_t edge_b = slope < 0
            ? ArmRaster_ReadS16(output + 12)
            : ArmRaster_ReadS16(output + 4);

        while (remaining_rows > 0) {
            uint8_t *row = destination + row_base_offset;
            int32_t column_a = ArmRaster_Asr32((uint32_t)edge_a, 6);
            int32_t column_b = ArmRaster_Asr32((uint32_t)edge_b, 6);
            int32_t left = slope < 0 ? column_a : column_b;
            int32_t width = slope < 0 ? column_b - column_a
                                      : column_a - column_b;

            if (width > 0) {
                uint8_t *span = (uint8_t *)(uintptr_t)
                    ((uintptr_t)row + (uint32_t)left);
                ArmRaster_DrawSpan(span, width, flags, 0, 0);
            }

            --remaining_rows;
            if (remaining_rows <= 0)
                break;

            edge_b = edge_a;
            if (remaining_rows > 1) {
                edge_a = ArmRaster_SignedBits((uint32_t)edge_a +
                                               (uint32_t)slope);
            } else {
                edge_a = ArmRaster_ReadS16(output + 0x10);
                slope = ArmRaster_SignedBits((uint32_t)edge_a -
                                              (uint32_t)edge_b);
            }

            {
                uint32_t magnitude = slope < 0 ? 0u - (uint32_t)slope
                                                : (uint32_t)slope;
                if (magnitude < 64u)
                    magnitude = 64u;
                if (slope >= 0)
                    edge_b = ArmRaster_SignedBits((uint32_t)edge_a -
                                                   magnitude);
                else
                    edge_b = ArmRaster_SignedBits((uint32_t)edge_a +
                                                   magnitude);
            }
            row_base_offset += 64u;
        }
        return;
    }

    {
        int32_t left_x = ArmRaster_ReadS16(output + 4);
        int32_t right_x = ArmRaster_ReadS16(output + 12);
        uint16_t left_attribute = ArmRaster_ReadU16(output);
        uint16_t right_attribute = ArmRaster_ReadU16(output + 8);

        while (remaining_rows > 0) {
            uint8_t *row = destination + row_base_offset;
            int32_t left_column = ArmRaster_Asr32((uint32_t)left_x, 6);
            int32_t right_column = ArmRaster_Asr32((uint32_t)right_x, 6);
            int32_t span_width = left_x < 0
                ? right_column : right_column - left_column;
            int32_t draw_column = left_x < 0 ? 0 : left_column;

            if (span_width > 0)
                ArmRaster_DrawSpan(row + (uint32_t)draw_column, span_width,
                                   flags, left_attribute, right_attribute);

            --remaining_rows;
            if (remaining_rows <= 0)
                break;

            if (upper_rows == remaining_rows) {
                uint32_t upper_x = ArmRaster_ReadU32(output + 0x10);
                uint32_t upper_attribute = ArmRaster_ReadU32(output + 0x18);

                if ((flags & 1u) != 0) {
                    right_x = ArmRaster_ReadS16(output + 0x10);
                    right_attribute = ArmRaster_ReadU16(output + 0x18);
                    ArmRaster_WriteU32(output, 0x0C, upper_x);
                    ArmRaster_WriteU32(output, 0x08, upper_attribute);
                } else {
                    left_x = ArmRaster_ReadS16(output + 0x10);
                    left_attribute = ArmRaster_ReadU16(output + 0x18);
                    ArmRaster_WriteU32(output, 0x04, upper_x);
                    ArmRaster_WriteU32(output, 0x00, upper_attribute);
                }
            }

            left_x = ArmRaster_SignedBits((uint32_t)left_x +
                                           (uint32_t)ArmRaster_ReadS16(output + 6));
            left_attribute = (uint16_t)(left_attribute +
                ArmRaster_ReadS16(output + 2));
            if ((flags & 1u) == 0) {
                right_x = ArmRaster_SignedBits((uint32_t)right_x +
                    (uint32_t)ArmRaster_ReadS16(output + 14));
                right_attribute = (uint16_t)(right_attribute +
                    ArmRaster_ReadS16(output + 10));
            }
            row_base_offset += 64u;
        }
    }
}

/* Source reconstruction of ARM image entry 0x08064A14. */
void ArmRaster_ApplyVertexParameters(const void *descriptor_pointer,
                                     const void *parameter_pointer,
                                     uint32_t phase)
{
    const uint8_t *descriptor = (const uint8_t *)descriptor_pointer;
    const uint8_t *parameters = (const uint8_t *)parameter_pointer;
    const uint8_t *count_descriptor =
        *(const uint8_t * const *)(descriptor + 0x00);
    uint8_t *output_records =
        *(uint8_t * const *)(descriptor + 0x10);
    const uint8_t *parameter_table =
        (const uint8_t *)(uintptr_t)ARMRASTER_PARAMETER_TABLE_ADDRESS;
    uint32_t table_index = 255u - (uint32_t)ArmRaster_ReadU16(parameters + 0x0E);
    const uint8_t *table_entry = (const uint8_t *)(uintptr_t)
        ((uintptr_t)parameter_table + table_index * 2u);
    int32_t coefficient_a = ArmRaster_ReadS16(table_entry);
    int32_t coefficient_b = ArmRaster_ReadS16(table_entry + 128u);
    int32_t parameter_x = ArmRaster_ReadS8(parameters + 0x24);
    int32_t parameter_y = ArmRaster_ReadS8(parameters + 0x25);
    int32_t parameter_z = ArmRaster_ReadS8(parameters + 0x26);
    int32_t rotated_x = ArmRaster_Asr32((uint32_t)ArmRaster_Subtract32(
        ArmRaster_Multiply32(parameter_x, coefficient_b),
        ArmRaster_Multiply32(parameter_z, coefficient_a)), 8);
    int32_t rotated_y = ArmRaster_Asr32((uint32_t)ArmRaster_Add32(
        ArmRaster_Multiply32(parameter_z, coefficient_b),
        ArmRaster_Multiply32(parameter_x, coefficient_a)), 8);
    int32_t row_parameter = parameter_y;
    int32_t offset_x = ArmRaster_ReadS16(parameters + 0x2C);
    int32_t offset_y = ArmRaster_ReadS16(parameters + 0x2E);
    int32_t adjusted_x = ArmRaster_Subtract32(
        ArmRaster_ReadS32(output_records), offset_x);
    int32_t adjusted_y = ArmRaster_Subtract32(
        ArmRaster_ReadS32(output_records + 4), offset_y);
    int32_t stored_limit = -65281;
    int32_t row_count = ArmRaster_ReadS16(count_descriptor + 4);
    uint8_t *row_record = output_records + 12u;

    ArmRaster_WriteU32(output_records, 0, (uint32_t)adjusted_x);
    ArmRaster_WriteU32(output_records, 4, (uint32_t)adjusted_y);
    if (adjusted_y > stored_limit)
        stored_limit = adjusted_y;

    /* The ROM uses a do/while loop; the descriptor is expected to be nonzero. */
    do {
        int32_t row_x = ArmRaster_ReadS8(row_record);
        int32_t row_y = ArmRaster_ReadS8(row_record + 1);
        int32_t row_z = ArmRaster_ReadS8(row_record + 2);
        int32_t transformed = ArmRaster_Multiply32(rotated_x, row_x);
        uint32_t sample;

        transformed = ArmRaster_Add32(
            transformed, ArmRaster_Multiply32(row_parameter, row_y));
        transformed = ArmRaster_Add32(
            transformed, ArmRaster_Multiply32(rotated_y, row_z));
        sample = (uint32_t)ArmRaster_Asr32((uint32_t)transformed, 7) + 128u;
        sample += phase >> 3;
        sample >>= phase & 7u;
        if (ArmRaster_SignedBits(sample) > 255)
            sample = 255u;
        row_record[0] = (uint8_t)sample;

        row_record += 4u;
        row_count = ArmRaster_Subtract32(row_count, 1);
    } while (row_count != 0);

    ArmRaster_WriteU16((uint8_t *)parameters, 0x30, (uint16_t)stored_limit);
}

/* Source reconstruction of ARM image entry 0x08064AFC. */
void ArmRaster_TransformVertexRows(const void *descriptor_pointer,
                                   const void *unused_argument,
                                   const void *transform_context_pointer,
                                   const void *vertex_values_pointer)
{
    const uint8_t *descriptor = (const uint8_t *)descriptor_pointer;
    const uint8_t *transform_context =
        (const uint8_t *)transform_context_pointer;
    const uint8_t *input_records =
        *(const uint8_t * const *)(descriptor + 4);
    const uint8_t *count_descriptor =
        *(const uint8_t * const *)(descriptor + 0);
    uint8_t *output_records =
        *(uint8_t * const *)(descriptor + 0x10);
    const uint8_t *vertex_values = (const uint8_t *)vertex_values_pointer + 4;
    int32_t row_count = ArmRaster_ReadS16(count_descriptor + 4);
    int32_t minimum_y = 0x00FF0000;
    int32_t minimum_x = 0x00FF0000;

    (void)unused_argument;

    do {
        uint32_t packed_values =
            (uint32_t)ArmRaster_ReadU16(input_records) |
            ((uint32_t)ArmRaster_ReadU16(input_records + 2) << 16);
        int32_t x = ArmRaster_ReadS16(input_records + 4);
        int32_t y = ArmRaster_ReadS16(input_records + 6);
        int32_t z = ArmRaster_ReadS16(input_records + 8);
        int32_t interpolation = ArmRaster_ReadS16(transform_context + 0x1A);

        ArmRaster_WriteU32(output_records, 0x0C, packed_values);

        if (interpolation != 0) {
            int32_t target_x = ArmRaster_ReadS16(vertex_values);
            int32_t target_y = ArmRaster_ReadS16(vertex_values + 2);
            int32_t target_z = ArmRaster_ReadS16(vertex_values + 4);
            int32_t delta_x = ArmRaster_Subtract32(target_x, x);
            int32_t delta_y = ArmRaster_Subtract32(target_y, y);
            int32_t delta_z = ArmRaster_Subtract32(target_z, z);

            x = ArmRaster_Add32(x, ArmRaster_Asr32((uint32_t)
                ArmRaster_Multiply32(delta_x, interpolation), 10));
            y = ArmRaster_Add32(y, ArmRaster_Asr32((uint32_t)
                ArmRaster_Multiply32(delta_y, interpolation), 10));
            z = ArmRaster_Add32(z, ArmRaster_Asr32((uint32_t)
                ArmRaster_Multiply32(delta_z, interpolation), 10));
        }

        {
            int32_t scale = ArmRaster_ReadS32(transform_context + 0x58);
            int32_t scaled_x = ArmRaster_Multiply32(x, scale);
            int32_t scaled_y = ArmRaster_Multiply32(y, scale);
            int32_t scaled_z = ArmRaster_Multiply32(z, scale);
            int32_t coord_x = ArmRaster_Asr32((uint32_t)scaled_x, 10);
            int32_t coord_y = ArmRaster_Asr32((uint32_t)scaled_y, 10);
            int32_t coord_z = ArmRaster_Asr32((uint32_t)scaled_z, 10);
            int32_t matrix_x = ArmRaster_Add32(scaled_x,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x34), coord_x));
            int32_t matrix_y = ArmRaster_Add32(scaled_y,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x38), coord_x));
            int32_t matrix_z = ArmRaster_Add32(scaled_z,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x3C), coord_x));

            matrix_x = ArmRaster_Add32(matrix_x,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x40), coord_y));
            matrix_y = ArmRaster_Add32(matrix_y,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x44), coord_y));
            matrix_z = ArmRaster_Add32(matrix_z,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x48), coord_y));
            matrix_x = ArmRaster_Add32(matrix_x,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x4C), coord_z));
            matrix_y = ArmRaster_Add32(matrix_y,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x50), coord_z));
            matrix_z = ArmRaster_Add32(matrix_z,
                ArmRaster_Multiply32(
                    ArmRaster_ReadS32(transform_context + 0x54), coord_z));

            x = ArmRaster_Asr32((uint32_t)matrix_x, 10);
            y = ArmRaster_Asr32((uint32_t)matrix_y, 10);
            z = ArmRaster_Asr32((uint32_t)matrix_z, 10);
        }

        if (ArmRaster_ReadU16(transform_context + 0x32) == 0) {
            int32_t middle = ArmRaster_Asr32(
                (uint32_t)ArmRaster_Subtract32(x, z), 1);
            middle = ArmRaster_Add32(middle, y);
            x = ArmRaster_Add32(x, z);
            y = middle;
        }

        if (y < minimum_y)
            minimum_y = y;
        if (x < minimum_x)
            minimum_x = x;

        ArmRaster_WriteU32(output_records, 0, (uint32_t)x);
        ArmRaster_WriteU32(output_records, 4, (uint32_t)y);
        ArmRaster_WriteU32(output_records, 8, (uint32_t)z);
        input_records += 10u;
        vertex_values += 6u;
        output_records += 16u;
        row_count = ArmRaster_Subtract32(row_count, 1);
    } while (row_count != 0);

    minimum_x = ArmRaster_Subtract32(minimum_x, 64);
    ArmRaster_WriteU16((uint8_t *)transform_context, 0x2E,
                       (uint16_t)minimum_y);
    ArmRaster_WriteU16((uint8_t *)transform_context, 0x2C,
                       (uint16_t)minimum_x);
}

/*
 * Recovered from ARM-state routine 0x08064E54.
 *
 * r0 = number of 64-byte output chunks
 * r1 = source row stride in bytes
 * r2 = source base
 * r3 = destination base
 *
 * Each iteration gathers eight 8-byte slices from source rows separated by
 * stride, then writes those slices contiguously. After each group of eight
 * iterations, the source advances to the next group of eight rows. The exact
 * caller-level texture/layout semantics are not yet proven.
 */
void ArmRaster_CopyEightRowSlices(uint32_t chunk_count,
                                  uint32_t source_stride,
                                  const uint8_t *source,
                                  uint8_t *destination)
{
    uint32_t remaining = chunk_count;

    while (remaining != 0) {
        for (uint32_t row = 0; row < 8; ++row) {
            const uint8_t *slice = source + row * source_stride;
            for (uint32_t byte = 0; byte < 8; ++byte)
                *destination++ = slice[byte];
        }

        source += 8;
        --remaining;

        /* Mirrors the ARM routine's stride correction at each 8-chunk edge. */
        if ((remaining & 7u) == 0) {
            source += source_stride * 8u;
            source -= 64u;
        }
    }
}
