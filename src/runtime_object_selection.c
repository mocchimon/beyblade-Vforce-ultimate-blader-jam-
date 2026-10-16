#include <stddef.h>
#include <stdint.h>

#include "runtime.h"
#include "runtime_object_selection.h"
#include "resource_node.h"

typedef struct RuntimeObjectSelectionSource {
    uint32_t object_pointer;      /* +0x00 */
    uint32_t count;               /* +0x04 */
    uint32_t scale;               /* +0x08 */
    uint32_t center_x;            /* +0x0C */
    uint32_t center_y;            /* +0x10 */
    uint32_t position_x;          /* +0x14, signed fixed-point bits */
    uint32_t position_y;          /* +0x18, signed fixed-point bits */
    uint32_t record_array;        /* +0x1C */
} RuntimeObjectSelectionSource;

typedef struct RuntimeObjectSelectionManager {
    uint32_t count;               /* +0x00 */
    uint32_t selected_index;      /* +0x04 */
    uint32_t angle_base;          /* +0x08 */
    uint32_t angle_step;          /* +0x0C */
    uint32_t zero10;              /* +0x10 */
    uint32_t selected_angle_base; /* +0x14 */
    uint32_t scale_copy_a;        /* +0x18 */
    uint32_t scale_copy_b;        /* +0x1C */
    uint32_t zero20;              /* +0x20 */
    uint32_t zero24;              /* +0x24 */
    uint32_t entries;             /* +0x28 */
    const uint8_t *source;        /* +0x2C */
    void *allocation_descriptor; /* +0x30 */
    uint32_t source_center_x;     /* +0x34 */
    uint32_t source_center_y;     /* +0x38 */
    uint16_t zero3c;              /* +0x3C */
} RuntimeObjectSelectionManager;

typedef struct RuntimeObjectSelectionEntry {
    uint32_t source_record;       /* +0x00 */
    uint32_t resolved_value;      /* +0x04 */
    uint32_t position_x;          /* +0x08 */
    uint32_t position_y;          /* +0x0C */
    uint32_t value_10;            /* +0x10 */
    uint32_t selected_value;      /* +0x14 */
    uint16_t zero18;              /* +0x18 */
    uint8_t reserved1a[2];
} RuntimeObjectSelectionEntry;

_Static_assert(offsetof(RuntimeObjectSelectionSource, count) == 0x04,
               "source count must be at +0x04");
_Static_assert(offsetof(RuntimeObjectSelectionSource, scale) == 0x08,
               "source scale must be at +0x08");
_Static_assert(offsetof(RuntimeObjectSelectionSource, center_x) == 0x0C,
               "source center X must be at +0x0C");
_Static_assert(offsetof(RuntimeObjectSelectionSource, center_y) == 0x10,
               "source center Y must be at +0x10");
_Static_assert(offsetof(RuntimeObjectSelectionSource, position_x) == 0x14,
               "source position X must be at +0x14");
_Static_assert(offsetof(RuntimeObjectSelectionSource, position_y) == 0x18,
               "source position Y must be at +0x18");
_Static_assert(offsetof(RuntimeObjectSelectionSource, record_array) == 0x1C,
               "source records pointer must be at +0x1C");
_Static_assert(offsetof(RuntimeObjectSelectionManager, entries) == 0x28,
               "entry payload must be at manager +0x28");
_Static_assert(offsetof(RuntimeObjectSelectionManager,
                         allocation_descriptor) == 0x30,
               "allocation descriptor must be at manager +0x30");
_Static_assert(sizeof(RuntimeObjectSelectionEntry) == 0x1C,
               "output entries use a 0x1C-byte stride");

typedef struct RuntimeObjectSelectionSourceRecord {
    uint32_t value00;
    uint32_t value04;
    uint8_t reserved08[0x10];
    uint32_t position_x;          /* +0x18 */
    uint32_t position_y;          /* +0x1C */
    uint32_t value20;             /* +0x20 */
    uint32_t selected_value;      /* +0x24 */
    uint16_t value28;             /* +0x28 */
    uint8_t reserved2a[6];
} RuntimeObjectSelectionSourceRecord;

_Static_assert(offsetof(RuntimeObjectSelectionSourceRecord, position_x) ==
                   0x18,
               "source record position X must be at +0x18");
_Static_assert(offsetof(RuntimeObjectSelectionSourceRecord, value28) ==
                   0x28,
               "source record halfword must be at +0x28");
_Static_assert(sizeof(RuntimeObjectSelectionSourceRecord) == 0x30,
               "source records use a 0x30-byte stride");

extern uint32_t sub_08061684(void *context, uint32_t selected_value,
                             uint32_t object_byte);

static int32_t RuntimeObject_ArithmeticShiftRight8(uint32_t value)
{
    uint32_t result = value >> 8;
    if ((value & 0x80000000u) != 0)
        result |= 0xFF000000u;
    return (int32_t)result;
}

static int32_t RuntimeObject_ExtractSignedHighHalf(uint32_t value)
{
    uint32_t shifted = value << 8;
    uint32_t result = shifted >> 16;
    if ((shifted & 0x80000000u) != 0)
        result |= 0xFFFF0000u;
    return (int32_t)result;
}

typedef struct RuntimeObjectSelectionContext {
    int32_t position_x_scaled;     /* +0x00 */
    int32_t context_scaled;        /* +0x04 */
    uint16_t extent;               /* +0x08 */
    uint16_t zero0a;
    uint16_t position_y;           /* +0x0C */
    uint8_t zero0e;
    uint8_t zero0f;
    uint16_t unit_x;               /* +0x10 */
    uint16_t unit_y;               /* +0x12 */
    uint32_t zero14;
    uint32_t zero18;
    uint32_t zero1c;
    uint32_t object_value4;        /* +0x20 */
    uint32_t object_value0;        /* +0x24 */
    uint8_t trailing_value;        /* +0x28 */
    uint8_t zero29;
    uint8_t object_byte_plus_four; /* +0x2A */
    uint8_t zero2b;
    uint32_t zero2c;
} RuntimeObjectSelectionContext;

_Static_assert(offsetof(RuntimeObjectSelectionContext, extent) == 0x08,
               "selection context extent must be at +0x08");
_Static_assert(offsetof(RuntimeObjectSelectionContext, position_y) == 0x0C,
               "selection context Y must be at +0x0C");
_Static_assert(offsetof(RuntimeObjectSelectionContext, unit_x) == 0x10,
               "selection context X unit must be at +0x10");
_Static_assert(offsetof(RuntimeObjectSelectionContext, object_value4) == 0x20,
               "selection context value must be at +0x20");
_Static_assert(offsetof(RuntimeObjectSelectionContext, object_value0) == 0x24,
               "selection context pointer must be at +0x24");
_Static_assert(offsetof(RuntimeObjectSelectionContext,
                        object_byte_plus_four) == 0x2A,
               "selection context byte must be at +0x2A");
_Static_assert(sizeof(RuntimeObjectSelectionContext) == 0x30,
               "selection context uses a 0x30-byte layout");

/* ROM 0x080611B4. Writes a fixed set of fields into the local selection
 * context. The final object word is read at +0x05 and incremented by four. */
void RuntimeObjectSelection_InitializeContext(
    void *context_pointer, uint32_t object_value0, uint32_t object_value4,
    int32_t position_x, int32_t position_y, uint32_t extent,
    uint32_t ignored_object_value8)
{
    RuntimeObjectSelectionContext *context =
        (RuntimeObjectSelectionContext *)context_pointer;
    const uint8_t *object = (const uint8_t *)(uintptr_t)object_value0;
    uint32_t scaled_context =
        (uint32_t)(uintptr_t)context_pointer << 16;
    uint32_t scaled_x = (uint32_t)position_x << 16;

    (void)ignored_object_value8;

    context->position_x_scaled = RuntimeObject_ArithmeticShiftRight8(scaled_x);
    context->context_scaled =
        RuntimeObject_ArithmeticShiftRight8(scaled_context);
    context->extent = (uint16_t)extent;
    context->zero0a = 0;
    context->position_y = (uint16_t)position_y;
    context->zero0e = 0;
    context->zero0f = 0;
    context->unit_x = 0x100u;
    context->unit_y = 0x100u;
    context->zero14 = 0;
    context->zero18 = 0;
    context->zero1c = 0;
    context->object_value4 = object_value4;
    context->object_value0 = object_value0;
    context->trailing_value = 5;
    context->zero29 = 0;
    context->object_byte_plus_four = (uint8_t)(object[5] + 4u);
    context->zero2b = 0;
    context->zero2c = 0;
}

static int32_t RuntimeObject_ScaledTableValue(const volatile int16_t *table,
                                             uint32_t index,
                                             uint32_t scale)
{
    uint32_t product = (uint32_t)(int32_t)table[index] * scale;
    return RuntimeObject_ArithmeticShiftRight8(product);
}

/* ROM 0x08050AA0. Builds one 0x1C-byte output entry per descriptor count,
 * using source records at a 0x30-byte stride. The final selection dispatcher
 * remains external until its downstream instruction range is recovered. */
uint32_t RuntimeObject_InitializeEntryTable(void *manager_pointer,
                                           const void *source_pointer,
                                           uint32_t selected_index)
{
    RuntimeObjectSelectionManager *manager =
        (RuntimeObjectSelectionManager *)manager_pointer;
    const RuntimeObjectSelectionSource *source =
        (const RuntimeObjectSelectionSource *)source_pointer;
    uint32_t allocation_size = source->count * 0x1Cu;
    void *allocation_descriptor = Heap_AllocAlt(allocation_size);

    manager->allocation_descriptor = allocation_descriptor;
    if (allocation_descriptor == 0) {
        sub_08057C5C((const void *)(uintptr_t)0x087293BCu,
                     allocation_size);
    }

    /* Heap_AllocAlt returns a descriptor; its first word is the payload. */
    manager->entries = *(const uint32_t *)allocation_descriptor;
    manager->count = source->count;
    manager->source = (const uint8_t *)source;
    manager->zero3c = 0;
    manager->source_center_x = source->center_x;
    manager->source_center_y = source->center_y;

    uint32_t angle_step = (uint32_t)Math_DivideSigned(0x10000,
                                                       (int32_t)source->count);
    manager->angle_step = angle_step;
    manager->zero10 = 0;
    manager->selected_index = selected_index;
    uint32_t angle_base = 0x0000FFFFu - selected_index * angle_step;
    manager->angle_base = angle_base;
    manager->selected_angle_base = angle_base;
    manager->zero20 = 0;
    manager->zero24 = 0;
    manager->scale_copy_a = source->scale;
    manager->scale_copy_b = source->scale;

    RuntimeObjectSelectionEntry *output =
        (RuntimeObjectSelectionEntry *)(uintptr_t)manager->entries;
    const RuntimeObjectSelectionSourceRecord *record =
        (const RuntimeObjectSelectionSourceRecord *)(uintptr_t)
            ((uint32_t)(uintptr_t)source + 0x1Cu);
    uint32_t angle = 0x80u;
    uint32_t context_pointer = (uint32_t)(uintptr_t)manager + 0x40u;
    volatile int16_t *trig_table = (volatile int16_t *)(uintptr_t)0x0874CC60u;

    int32_t loop_limit = (int32_t)source->count;
    for (uint32_t i = 0; (int32_t)i < loop_limit; ++i) {
        uint32_t phase = (angle >> 8) & 0xFFu;
        int32_t sine = RuntimeObject_ScaledTableValue(
            trig_table, phase, source->scale);
        int32_t cosine = RuntimeObject_ScaledTableValue(
            trig_table, phase + 64u, source->scale);

        output->source_record = (uint32_t)(uintptr_t)record;
        output->value_10 = record->value20;
        output->selected_value =
            (i == selected_index) ? record->selected_value : record->value20;
        output->position_x = record->position_x;
        output->position_y = record->position_y;
        output->resolved_value = (uint32_t)(uintptr_t)ResourceNode_AcquireByClass(
            (i == selected_index) ? 1u : 2u, selected_index);
        output->zero18 = 0;

        if (output->resolved_value != 0) {
            uint32_t relative_x = source->center_x - output->position_x +
                                  (uint32_t)sine;
            uint32_t relative_y = source->center_y - output->position_y +
                                  (uint32_t)cosine;
            ResourceNode_ConfigureSelectionEntry(
                (void *)(uintptr_t)output->resolved_value,
                (const void *)(uintptr_t)record->value00,
                relative_x, relative_y, 0, 2, 0, record->value28);
        }

        output = (RuntimeObjectSelectionEntry *)
            ((uint8_t *)output + sizeof(*output));
        record = (const RuntimeObjectSelectionSourceRecord *)
            ((const uint8_t *)record + 0x30u);
        angle += angle_step;
    }

    const uint8_t *object =
        (const uint8_t *)(uintptr_t)source->object_pointer;
    RuntimeObjectSelection_InitializeContext(
        (void *)(uintptr_t)context_pointer,
        *(const uint32_t *)(const void *)object,
        *(const uint32_t *)(const void *)(object + 4u),
        RuntimeObject_ExtractSignedHighHalf(source->position_x),
        RuntimeObject_ExtractSignedHighHalf(source->position_y),
        0xF0u, *(const uint16_t *)(const void *)(object + 8u));

    uint32_t selected_record_offset = selected_index * 0x30u;
    const uint8_t *selected_record =
        (const uint8_t *)(uintptr_t)((uint32_t)(uintptr_t)source->record_array +
                                     selected_record_offset);
    uint32_t selected_element =
        sub_08063AC4((uint32_t)(uintptr_t)selected_record);
    uint32_t selected_value = *(const uint32_t *)(const void *)(
        selected_record + 4u + selected_element * 4u);
    uint32_t object_byte = *(const uint8_t *)(const void *)(object + 0x0Au);
    return sub_08061684((void *)(uintptr_t)context_pointer,
                        selected_value, object_byte);
}

/* ROM 0x08063AC4. The entry computes a byte from the pointer stored at
 * 0x03005E98 plus the literal 0x03005E80; it ignores its incoming r0. */
uint32_t sub_08063AC4(uint32_t ignored_record_pointer)
{
    uint32_t base = *(volatile const uint32_t *)(uintptr_t)0x03005E98u;
    uint32_t address = base + 0x03005E80u;
    (void)ignored_record_pointer;
    return *(volatile const uint8_t *)(uintptr_t)address;
}
