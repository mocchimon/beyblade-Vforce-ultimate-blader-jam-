#include <stdint.h>

#include "runtime_object_selection.h"

static uint16_t RuntimeObjectSelection_LayoutReadHalfword(
    const void *base, uint32_t offset)
{
    const uint8_t *bytes = (const uint8_t *)base;
    return *(const uint16_t *)(const void *)(bytes + offset);
}

static uint32_t RuntimeObjectSelection_LayoutReadWord(const void *base,
                                                       uint32_t offset)
{
    const uint8_t *bytes = (const uint8_t *)base;
    return *(const uint32_t *)(const void *)(bytes + offset);
}

static void RuntimeObjectSelection_LayoutWriteWord(void *base,
                                                    uint32_t offset,
                                                    uint32_t value)
{
    uint8_t *bytes = (uint8_t *)base;
    *(uint32_t *)(void *)(bytes + offset) = value;
}

static int32_t RuntimeObjectSelection_LayoutArithmeticShiftRight8(
    uint32_t value)
{
    uint32_t shifted = value >> 8;
    if ((value & 0x80000000u) != 0u)
        shifted |= 0xFF000000u;
    return (int32_t)shifted;
}

static uint16_t RuntimeObjectSelection_LayoutNodeIndex(const void *node)
{
    return (uint16_t)(RuntimeObjectSelection_LayoutReadHalfword(node, 0x1E) &
                      0x7FFFu);
}

static uint32_t RuntimeObjectSelection_LayoutCoordinateBase(
    const void *node, uint32_t indexed_offsets, uint32_t base_coordinate)
{
    if (indexed_offsets != 0u) {
        uint16_t offset_index =
            RuntimeObjectSelection_LayoutReadHalfword(node, 0x18);
        uint8_t object_offset = *(const uint8_t *)(uintptr_t)(
            indexed_offsets + offset_index);
        return base_coordinate - object_offset;
    }

    return base_coordinate;
}

/* ROM 0x08061260. Lay out each chain segment in fixed-point coordinates.
 * Context +0x29 is the signed per-index displacement table, +0x2A is the
 * signed row step, and +0x2C optionally points at a record supplying scale. */
void RuntimeObjectSelection_ApplyLayout(void *context_pointer)
{
    uint8_t *context = (uint8_t *)context_pointer;
    uint32_t indexed_offsets = RuntimeObjectSelection_LayoutReadWord(
        context, 0x20);
    uint32_t object_pointer = RuntimeObjectSelection_LayoutReadWord(
        context, 0x24);
    uint32_t base_coordinate =
        *(const uint8_t *)(uintptr_t)(object_pointer + 4u);
    uint32_t base_x = RuntimeObjectSelection_LayoutReadWord(context, 0x00);
    uint32_t base_y = RuntimeObjectSelection_LayoutReadWord(context, 0x04);
    uint32_t count = RuntimeObjectSelection_LayoutReadWord(context, 0x1C);
    uint32_t current = RuntimeObjectSelection_LayoutReadWord(context, 0x14);
    uint32_t first_unpositioned = current;
    uint32_t anchor = 0u;
    uint32_t cumulative_y = 0u;
    uint32_t scale = 0x100u;
    uint16_t extent =
        RuntimeObjectSelection_LayoutReadHalfword(context, 0x0C);
    uint16_t flags =
        RuntimeObjectSelection_LayoutReadHalfword(context, 0x08);
    uint16_t previous_index = 0u;
    uint32_t record_pointer = RuntimeObjectSelection_LayoutReadWord(
        context, 0x2C);

    context[0x0F] = 0u;
    if (count == 0u)
        return;

    if (record_pointer != 0u) {
        scale = RuntimeObjectSelection_LayoutReadHalfword(
            (const void *)(uintptr_t)record_pointer, 0x14);
    }

    switch (flags & 3u) {
    case 1u:
        base_x += (uint32_t)extent << 8;
        break;
    case 2u:
        base_x += ((uint32_t)extent & ~1u) << 7;
        break;
    default:
        break;
    }

    for (uint32_t processed = 0u; processed < count; ++processed) {
        uint8_t *node = (uint8_t *)(uintptr_t)current;
        uint16_t marker_and_index =
            RuntimeObjectSelection_LayoutReadHalfword(node, 0x1E);
        uint16_t index = (uint16_t)(marker_and_index & 0x7FFFu);
        uint32_t displacement_address = (uint32_t)(uintptr_t)(
            context + 0x29u) + index;
        int32_t displacement = *(const int8_t *)(uintptr_t)
            displacement_address;
        uint32_t projected = (uint32_t)index - previous_index;
        uint32_t coordinate_base = RuntimeObjectSelection_LayoutCoordinateBase(
            node, indexed_offsets, base_coordinate);
        uint32_t remaining_after = count - processed - 1u;

        if ((marker_and_index & 0x8000u) != 0u)
            anchor = current;

        projected += (uint32_t)displacement;
        projected += coordinate_base;

        if (projected <= extent && remaining_after != 0u) {
            current = RuntimeObjectSelection_LayoutReadWord(node, 0x04);
            continue;
        }

        uint32_t endpoint;
        if (remaining_after == 0u) {
            endpoint = current;
        } else if (anchor != 0u) {
            endpoint = RuntimeObjectSelection_LayoutReadWord(
                (const void *)(uintptr_t)anchor, 0x00);
        } else {
            endpoint = RuntimeObjectSelection_LayoutReadWord(node, 0x00);
        }

        uint32_t endpoint_index = 0u;
        uint32_t x_delta = 0u;
        uint32_t mode = flags & 3u;

        if (mode == 1u || mode == 2u) {
            const void *endpoint_node = (const void *)(uintptr_t)endpoint;
            endpoint_index = RuntimeObjectSelection_LayoutNodeIndex(
                endpoint_node);
            x_delta = endpoint_index - previous_index;
            int32_t base_displacement =
                *(const int8_t *)(const void *)(context + 0x29);
            uint32_t endpoint_base =
                RuntimeObjectSelection_LayoutCoordinateBase(
                    endpoint_node, indexed_offsets, base_coordinate);
            x_delta += (uint32_t)base_displacement;
            x_delta += endpoint_base;

            if (mode == 1u)
                x_delta = 0u - (x_delta << 8);
            else
                x_delta = 0u - ((x_delta & ~1u) << 7);
        }

        x_delta -= (uint32_t)previous_index << 8;
        base_x += RuntimeObjectSelection_LayoutArithmeticShiftRight8(
            x_delta * scale);

        while (first_unpositioned != endpoint) {
            uint8_t *placed =
                (uint8_t *)(uintptr_t)first_unpositioned;
            uint32_t placed_index =
                RuntimeObjectSelection_LayoutNodeIndex(placed);
            uint32_t scaled_index =
                ((placed_index << 8) * scale);
            uint32_t x = base_x +
                RuntimeObjectSelection_LayoutArithmeticShiftRight8(
                    scaled_index);

            RuntimeObjectSelection_LayoutWriteWord(placed, 0x08, x);
            RuntimeObjectSelection_LayoutWriteWord(placed, 0x0C, base_y);
            first_unpositioned =
                RuntimeObjectSelection_LayoutReadWord(placed, 0x04);
        }

        if (endpoint != 0u)
            previous_index = RuntimeObjectSelection_LayoutNodeIndex(
                (const void *)(uintptr_t)endpoint);
        else
            previous_index = 0u;
        anchor = 0u;

        int32_t row_step = *(const int8_t *)(const void *)(context + 0x2A);
        uint32_t row_delta = (uint32_t)row_step << 8;
        base_y += row_delta;
        cumulative_y += row_delta;
        context[0x0F] = (uint8_t)(context[0x0F] + 1u);
        flags = RuntimeObjectSelection_LayoutReadHalfword(context, 0x08);

        current = RuntimeObjectSelection_LayoutReadWord(node, 0x04);
    }

    uint32_t vertical_mode = flags & 0x30u;
    if (vertical_mode == 0u)
        return;
    if (vertical_mode == 0x10u) {
        uint32_t sign_fill = cumulative_y & 0x80000000u;
        cumulative_y = (cumulative_y >> 1) | sign_fill;
    }
    if (cumulative_y == 0u)
        return;

    current = RuntimeObjectSelection_LayoutReadWord(context, 0x14);
    for (uint32_t remaining = count; remaining != 0u; --remaining) {
        uint8_t *node = (uint8_t *)(uintptr_t)current;
        uint32_t y = RuntimeObjectSelection_LayoutReadWord(node, 0x0C);
        RuntimeObjectSelection_LayoutWriteWord(node, 0x0C,
                                                y - cumulative_y);
        current = RuntimeObjectSelection_LayoutReadWord(node, 0x04);
    }
}

/* ROM 0x080614D4. The halfword at context +0x08 is the layout mode/flags. */
void RuntimeObjectSelection_SetFlagsAndApplyLayout(void *context_pointer,
                                                    uint32_t flags)
{
    uint8_t *context = (uint8_t *)context_pointer;
    *(uint16_t *)(void *)(context + 0x08) = (uint16_t)flags;
    RuntimeObjectSelection_ApplyLayout(context_pointer);
}
