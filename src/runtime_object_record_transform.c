#include <stddef.h>
#include <stdint.h>

#include "runtime_object_records.h"

#define RUNTIME_OBJECT_TRANSFORM_TABLE 0x03000D00u
#define RUNTIME_OBJECT_ROTATION_TABLE  0x0874CC60u
#define RUNTIME_OBJECT_POSITION_TABLE 0x0872CC60u

typedef struct RuntimeObjectRecordTransformView {
    uint8_t unknown00[0x14];
    uint32_t value14;
    uint32_t value18;
    uint32_t value1C;
    uint32_t value20;
    uint32_t scale24;
    uint32_t value28;
    uint32_t value2C;
    uint32_t value30;
    uint32_t value34;
    uint32_t value38;
    uint32_t value3C;
    uint8_t unknown40[8];
    int16_t value48;
    int16_t value4A;
    uint32_t value4C;
    uint32_t value50;
    uint32_t mirror54;
    uint32_t mirror58;
    uint8_t unknown5C[2];
    uint8_t transformMode5E;
    uint8_t unknown5F[5];
    uint16_t flags64;
} RuntimeObjectRecordTransformView;

typedef struct RuntimeObjectAffineEntry {
    uint8_t angle;
    uint8_t unknown01;
    uint16_t x;
    uint16_t y;
    uint16_t unknown06;
    int32_t pa;
    int32_t pb;
    int32_t pc;
    int32_t pd;
} RuntimeObjectAffineEntry;

_Static_assert(offsetof(RuntimeObjectRecordTransformView, value28) == 0x28,
               "record transform value must be at +0x28");
_Static_assert(offsetof(RuntimeObjectRecordTransformView, value48) == 0x48,
               "record transform halfwords must start at +0x48");
_Static_assert(offsetof(RuntimeObjectRecordTransformView, value4C) == 0x4C,
               "record transform coordinate must be at +0x4C");
_Static_assert(offsetof(RuntimeObjectRecordTransformView, transformMode5E) ==
                   0x5E,
               "record transform mode must be at +0x5E");
_Static_assert(sizeof(RuntimeObjectRecordTransformView) == 0x68,
               "record transform view must preserve the 0x68-byte prefix");
_Static_assert(offsetof(RuntimeObjectAffineEntry, pa) == 0x08,
               "affine coefficients must begin at entry +0x08");
_Static_assert(offsetof(RuntimeObjectAffineEntry, pd) == 0x14,
               "last affine coefficient must be at entry +0x14");
_Static_assert(sizeof(RuntimeObjectAffineEntry) == 0x18,
               "affine entries have a 0x18-byte stride");

static int32_t RuntimeObject_SignExtendHalfword(uint32_t value)
{
    uint16_t halfword = (uint16_t)value;

    if (halfword < 0x8000u)
        return (int32_t)halfword;
    return (int32_t)halfword - 0x10000;
}

static uint32_t RuntimeObject_ArithmeticShiftRight8(uint32_t value)
{
    uint32_t shifted = value >> 8;

    if ((value & 0x80000000u) != 0)
        shifted |= 0xFF000000u;
    return shifted;
}

/* 0x08059FC4. Inputs are sign-extended halfwords. The ROM's negative-value
 * correction makes the fixed-point division truncate toward zero; the final
 * halfword result wraps just as the low 16 result bits do in Thumb code. */
int32_t RuntimeObject_MultiplyAffineCoefficients(int32_t lhs, int32_t rhs)
{
    int32_t signed_lhs = RuntimeObject_SignExtendHalfword((uint32_t)lhs);
    int32_t signed_rhs = RuntimeObject_SignExtendHalfword((uint32_t)rhs);
    int32_t product = signed_lhs * signed_rhs;
    int32_t scaled = product / 256;

    return RuntimeObject_SignExtendHalfword((uint32_t)scaled);
}

/* 0x08059ADC. Writes PA/PB/PC/PD for background 2 or 3. Other modes have no
 * register writes, matching the ROM's two-way selector. */
void RuntimeObject_SetAffineCoefficients(uint8_t mode,
                                         uint16_t pa, uint16_t pb,
                                         uint16_t pc, uint16_t pd)
{
    uintptr_t register_address;
    volatile uint16_t *registers;

    if (mode == 2u)
        register_address = 0x04000020u;
    else if (mode == 3u)
        register_address = 0x04000030u;
    else
        return;

    registers = (volatile uint16_t *)register_address;
    registers[0] = pa;
    registers[1] = pb;
    registers[2] = pc;
    registers[3] = pd;
}

/* 0x08059A8C. The reference coordinates are 32-bit fixed-point values. */
void RuntimeObject_SetAffineReferencePoint(uint8_t mode,
                                           uint32_t x, uint32_t y)
{
    uintptr_t register_address;
    volatile uint16_t *registers;

    if (mode == 2u)
        register_address = 0x04000028u;
    else if (mode == 3u)
        register_address = 0x04000038u;
    else
        return;

    registers = (volatile uint16_t *)register_address;
    registers[0] = (uint16_t)x;
    registers[1] = (uint16_t)(x >> 16);
    registers[2] = (uint16_t)y;
    registers[3] = (uint16_t)(y >> 16);
}

/* 0x08059B24. The three-entry IWRAM table stores the current angle/position
 * inputs and four signed 8.8 matrix coefficients. The two ROM tables remain
 * unnamed because only their indexed behavior is established here. */
void RuntimeObject_UpdateAffineTransform(uint8_t mode, uint8_t angle,
                                         uint16_t x, uint16_t y)
{
    uint8_t table_index = (uint8_t)(mode - 2u);
    uintptr_t entry_address;
    volatile RuntimeObjectAffineEntry *entry;
    const volatile int16_t *table_0874cc60;
    const volatile int16_t *table_0872cc60;
    uint32_t angle_index = angle;
    int32_t rotation;
    int32_t position;

    if (table_index > 2u)
        return;

    entry_address = RUNTIME_OBJECT_TRANSFORM_TABLE +
                    (uintptr_t)table_index * 0x18u;
    entry = (volatile RuntimeObjectAffineEntry *)entry_address;
    entry->angle = angle;
    entry->x = x;
    entry->y = y;

    table_0874cc60 = (const volatile int16_t *)(uintptr_t)
                     RUNTIME_OBJECT_ROTATION_TABLE;
    table_0872cc60 = (const volatile int16_t *)(uintptr_t)
                     RUNTIME_OBJECT_POSITION_TABLE;

    rotation = table_0874cc60[angle_index + 64u];
    position = table_0872cc60[x];
    entry->pa = RuntimeObject_MultiplyAffineCoefficients(rotation, position);

    rotation = table_0874cc60[angle_index];
    position = table_0872cc60[x];
    entry->pb = RuntimeObject_MultiplyAffineCoefficients(rotation, position);

    rotation = -(int32_t)(uint16_t)table_0874cc60[angle_index];
    position = table_0872cc60[y];
    entry->pc = RuntimeObject_MultiplyAffineCoefficients(rotation, position);

    rotation = table_0874cc60[angle_index + 64u];
    position = table_0872cc60[y];
    entry->pd = RuntimeObject_MultiplyAffineCoefficients(rotation, position);

    RuntimeObject_SetAffineCoefficients(mode,
                                         (uint16_t)entry->pa,
                                         (uint16_t)entry->pb,
                                         (uint16_t)entry->pc,
                                         (uint16_t)entry->pd);
}

/* 0x08058F84. Updates the record's fixed-point coordinates, rebuilds its
 * affine transform, writes the selected BG2/BG3 registers, and applies the
 * record scale. Offsets and table slots are named neutrally. */
void RuntimeObject_ApplyRecordTransform(void *record_pointer)
{
    RuntimeObjectRecordTransformView *record =
        (RuntimeObjectRecordTransformView *)record_pointer;
    uint8_t mode = record->transformMode5E;
    uint8_t table_index = (uint8_t)(mode - 2u);
    uintptr_t entry_address;
    volatile RuntimeObjectAffineEntry *entry;
    uint32_t mapped_x;
    uint32_t mapped_y;
    uint32_t product_a;
    uint32_t product_b;
    uint32_t product_c;
    uint32_t product_d;

    record->value28 += record->value2C;
    if ((record->value28 & 0x80000000u) != 0)
        record->value28 += 0x00010000u;

    record->value30 += record->value38;
    record->value34 += record->value3C;

    RuntimeObject_UpdateAffineTransform(
        mode,
        (uint8_t)(record->value28 >> 8),
        (uint16_t)(record->value30 >> 8),
        (uint16_t)(record->value34 >> 8));

    entry_address = RUNTIME_OBJECT_TRANSFORM_TABLE +
                    (uintptr_t)table_index * 0x18u;
    entry = (volatile RuntimeObjectAffineEntry *)entry_address;

    product_a = (uint32_t)entry->pa * (uint32_t)(int32_t)record->value48;
    product_c = (uint32_t)entry->pc * (uint32_t)(int32_t)record->value4A;
    mapped_x = record->value4C - (product_a - product_c);

    product_b = (uint32_t)entry->pb * (uint32_t)(int32_t)record->value48;
    product_d = (uint32_t)entry->pd * (uint32_t)(int32_t)record->value4A;
    mapped_y = record->value50 + (product_b - product_d);

    RuntimeObject_SetAffineReferencePoint(mode, mapped_x, mapped_y);

    if (record->scale24 != 0) {
        uint32_t scaled2C = RuntimeObject_ArithmeticShiftRight8(
            record->value2C * record->scale24);
        uint32_t scaled38 = RuntimeObject_ArithmeticShiftRight8(
            record->value38 * record->scale24);
        uint32_t scaled3C = RuntimeObject_ArithmeticShiftRight8(
            record->value3C * record->scale24);
        uint32_t reduced2C = record->value2C - scaled2C;
        uint32_t reduced38 = record->value38 - scaled38;
        uint32_t reduced3C = record->value3C - scaled3C;

        record->value2C = reduced2C;
        record->value38 = reduced38;
        record->value3C = reduced3C;

        if (scaled2C == 0 && reduced2C != 0)
            record->value2C = scaled2C;
        if (scaled38 == 0 && reduced38 != 0)
            record->value38 = scaled38;
        if (scaled3C == 0 && reduced3C != 0)
            record->value3C = scaled3C;
    }
}
