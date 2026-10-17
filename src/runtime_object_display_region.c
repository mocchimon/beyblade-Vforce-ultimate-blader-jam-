#include <stddef.h>
#include <stdint.h>

#include "child_resource_helpers.h"
#include "runtime_object_records.h"

typedef struct RuntimeObjectDisplayBounds {
    uint32_t value00;
    uint32_t value04;
    uint32_t value08;
    uint32_t value0C;
    uint32_t value10;
    uint32_t value14;
} RuntimeObjectDisplayBounds;

typedef struct RuntimeObjectDisplayRegionView {
    uint32_t value00;
    uint32_t value04;
    uint32_t boundsAddress08;
    uint32_t value0C;
    uint32_t value10;
    uint8_t unknown14[0x2C];
    uint32_t displayX40;
    uint32_t displayY44;
    uint8_t unknown48[0x16];
    uint8_t mode5E;
    uint8_t xShift5F;
    uint8_t yShift60;
    uint8_t unknown61[3];
    uint16_t flags64;
    uint8_t unknown66[0x16];
    uint8_t wrapFlags7C;
} RuntimeObjectDisplayRegionView;

_Static_assert(offsetof(RuntimeObjectDisplayRegionView, value0C) == 0x0C,
               "display-region coordinate must be at +0x0C");
_Static_assert(offsetof(RuntimeObjectDisplayRegionView, displayX40) == 0x40,
               "display X word must be at +0x40");
_Static_assert(offsetof(RuntimeObjectDisplayRegionView, mode5E) == 0x5E,
               "display mode byte must be at +0x5E");
_Static_assert(offsetof(RuntimeObjectDisplayRegionView, flags64) == 0x64,
               "display flags must be at +0x64");
_Static_assert(offsetof(RuntimeObjectDisplayRegionView, wrapFlags7C) == 0x7C,
               "wrap flags must be at +0x7C");
_Static_assert(offsetof(RuntimeObjectDisplayBounds, value14) == 0x14,
               "display-bound offset must be at +0x14");

/* 0x08059334. Its transfer backend still uses the reconstructed indirect
 * dispatcher, so this recovery preserves the original seven-argument call
 * sites without claiming pixel-equivalent output. */
extern void Render_PrepareTransfer(void *child,
                                   int32_t x, int32_t y,
                                   uint32_t width, uint32_t height,
                                   uint32_t source_stride,
                                   uint32_t source_offset);

static int32_t RuntimeObject_DisplayBitsToSigned(uint32_t value)
{
    if ((value & 0x80000000u) == 0)
        return (int32_t)value;
    return -1 - (int32_t)(~value);
}

static uint32_t RuntimeObject_DisplayArithmeticShiftRight(
    uint32_t value, uint32_t amount)
{
    uint32_t shifted = value >> amount;
    if ((value & 0x80000000u) != 0)
        shifted |= 0xFFFFFFFFu << (32u - amount);
    return shifted;
}

static uint32_t RuntimeObject_DisplayShiftMask(uint8_t shift)
{
    if (shift >= 32u)
        return 0;
    return (uint8_t)(1u << shift);
}

/* 0x080596D0. Updates the display-relative words, adjusts the active clip
 * bounds, requests wrapped transfer strips, and updates the selected BG
 * offsets or affine reference point. The raw field names remain neutral. */
void RuntimeObject_UpdateDisplayRegion(void *record_pointer,
                                       uint32_t delta_x, uint32_t delta_y)
{
    RuntimeObjectDisplayRegionView *record =
        (RuntimeObjectDisplayRegionView *)record_pointer;
    RuntimeObjectDisplayBounds *bounds =
        (RuntimeObjectDisplayBounds *)(uintptr_t)record->boundsAddress08;
    uint32_t mode_flag = (uint8_t)record->flags64 & 1u;
    uint32_t x_mask = RuntimeObject_DisplayShiftMask(record->xShift5F);
    uint32_t y_mask = RuntimeObject_DisplayShiftMask(record->yShift60);
    uint32_t span_x;
    uint32_t span_y;
    uint32_t end_x;
    uint32_t end_y;
    uint32_t delta_clip_x = 0;
    uint32_t delta_clip_y = 0;
    uint32_t source_x = 0;
    uint32_t dest_end_x = 0;
    uint32_t source_y = 0;
    uint32_t dest_start_y = 0;
    uint32_t transfer_x_span = 0;
    uint32_t transfer_y_span = 0;

    record->value0C += delta_x;
    record->value10 += delta_y;
    record->displayX40 += delta_x;
    record->displayY44 += delta_y;

    span_x = RuntimeObject_DisplayArithmeticShiftRight(record->value0C, 11);
    span_y = RuntimeObject_DisplayArithmeticShiftRight(record->value10, 11);
    end_x = span_x + 30u;
    end_y = span_y + 20u;

    if (RuntimeObject_DisplayBitsToSigned(end_x) >
        RuntimeObject_DisplayBitsToSigned(bounds->value08)) {
        delta_clip_x = end_x - bounds->value08;
        source_x = bounds->value10 + x_mask;
        dest_end_x = bounds->value08 + 1u;
        transfer_x_span = delta_clip_x;
    }

    if (RuntimeObject_DisplayBitsToSigned(span_x) <
        RuntimeObject_DisplayBitsToSigned(bounds->value00)) {
        delta_clip_x = span_x - bounds->value00;
        source_x = bounds->value10 + delta_clip_x;
        dest_end_x = bounds->value00 + delta_clip_x;
        transfer_x_span = 0u - delta_clip_x;
    }

    if (RuntimeObject_DisplayBitsToSigned(end_y) >
        RuntimeObject_DisplayBitsToSigned(bounds->value0C)) {
        delta_clip_y = end_y - bounds->value0C;
        source_y = bounds->value14 + y_mask;
        dest_start_y = bounds->value0C + 1u;
        transfer_y_span = delta_clip_y;
    }

    if (RuntimeObject_DisplayBitsToSigned(span_y) <
        RuntimeObject_DisplayBitsToSigned(bounds->value04)) {
        delta_clip_y = span_y - bounds->value04;
        source_y = bounds->value14 + delta_clip_y;
        dest_start_y = bounds->value04 + delta_clip_y;
        transfer_y_span = 0u - delta_clip_y;
    }

    if (delta_clip_x != 0 && (record->wrapFlags7C & 1u) == 0) {
        Render_PrepareTransfer(record_pointer,
                               RuntimeObject_DisplayBitsToSigned(dest_end_x),
                               RuntimeObject_DisplayBitsToSigned(bounds->value04),
                               source_x,
                               bounds->value14,
                               transfer_x_span,
                               32u);
    }

    bounds->value10 += delta_clip_x;
    bounds->value00 += delta_clip_x;
    bounds->value08 += delta_clip_x;

    if ((record->wrapFlags7C & 8u) != 0) {
        if (RuntimeObject_DisplayBitsToSigned(bounds->value08) >=
                RuntimeObject_DisplayBitsToSigned(record->value00) &&
            RuntimeObject_DisplayBitsToSigned(bounds->value00) >=
                RuntimeObject_DisplayBitsToSigned(record->value00)) {
            bounds->value00 -= record->value00;
            bounds->value08 -= record->value00;
            record->value0C -= record->value00 << 11;
        } else if (RuntimeObject_DisplayBitsToSigned(bounds->value08) < 0 &&
                   RuntimeObject_DisplayBitsToSigned(bounds->value00) < 0) {
            bounds->value00 += record->value00;
            bounds->value08 += record->value00;
            record->value0C += record->value00 << 11;
        }
    }

    if (delta_clip_y != 0 && (record->wrapFlags7C & 2u) == 0) {
        Render_PrepareTransfer(record_pointer,
                               RuntimeObject_DisplayBitsToSigned(bounds->value00),
                               RuntimeObject_DisplayBitsToSigned(dest_start_y),
                               bounds->value10,
                               source_y,
                               32u,
                               transfer_y_span);
    }

    bounds->value14 += delta_clip_y;
    bounds->value04 += delta_clip_y;
    bounds->value0C += delta_clip_y;

    if ((record->wrapFlags7C & 4u) != 0) {
        if (RuntimeObject_DisplayBitsToSigned(bounds->value0C) >=
                RuntimeObject_DisplayBitsToSigned(record->value04) &&
            RuntimeObject_DisplayBitsToSigned(bounds->value04) >=
                RuntimeObject_DisplayBitsToSigned(record->value00)) {
            bounds->value04 -= record->value04;
            bounds->value0C -= record->value04;
            record->value10 -= record->value04 << 11;
        } else if (RuntimeObject_DisplayBitsToSigned(bounds->value0C) < 0 &&
                   RuntimeObject_DisplayBitsToSigned(bounds->value04) < 0) {
            bounds->value04 += record->value04;
            bounds->value0C += record->value04;
            record->value10 += record->value04 << 11;
        }
    }

    if (mode_flag == 0) {
        uint8_t mode = record->mode5E;
        volatile uint16_t *horizontal = (volatile uint16_t *)(uintptr_t)
            ChildResource_HorizontalOffsetRegister(mode);
        volatile uint16_t *vertical = (volatile uint16_t *)(uintptr_t)
            ChildResource_VerticalOffsetRegister(mode);

        *horizontal = (uint16_t)(record->displayX40 >> 8);
        *vertical = (uint16_t)(record->displayY44 >> 8);
    } else {
        RuntimeObject_SetAffineReferencePoint(record->mode5E,
                                               record->displayX40,
                                               record->displayY44);
    }
}

/* 0x08059928. Derives the two word adjustments from frame +0x04/+0x08/+0x0C
 * and the record words at +0x0C/+0x10. */
void RuntimeObject_UpdateDisplayRegionFromFrame(void *record_pointer,
                                                const void *frame_pointer)
{
    RuntimeObjectDisplayRegionView *record =
        (RuntimeObjectDisplayRegionView *)record_pointer;
    const uint32_t *frame_words = (const uint32_t *)frame_pointer;
    uint32_t frame_offset = frame_words[3] << 7;
    uint32_t delta_x = frame_words[1] + frame_offset -
                       (record->value0C + 0x5800u);
    uint32_t delta_y = frame_words[2] + frame_offset -
                       (record->value10 + 0x2C00u);

    RuntimeObject_UpdateDisplayRegion(record_pointer, delta_x, delta_y);
}
