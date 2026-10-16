#include <stdint.h>
#include "runtime.h"

/*
 * Bytecode interpreter recovered from 0x08062C48. Opcode families are named
 * by their observed high nibble; their game-facing intent is not assumed.
 */
typedef struct RuntimeScriptSlot {
    uint8_t active;       /* +0: slot occupied */
    uint8_t identifier;   /* +1: script-local identifier */
    uint8_t reserved[2];
    uint32_t entry_serial; /* +4: handle returned by RuntimeEntry_Alloc */
} RuntimeScriptSlot;

typedef struct RuntimeScriptRecord {
    uint32_t source_record; /* +0: resource/source record for this slot group */
    RuntimeScriptSlot slots[4];
} RuntimeScriptRecord;

_Static_assert(sizeof(RuntimeScriptSlot) == 8, "script slot stride mismatch");
_Static_assert(sizeof(RuntimeScriptRecord) == 0x24, "script record stride mismatch");

#define RAM32(address) (*(volatile uint32_t *)(uintptr_t)(address))
#define RAM16(address) (*(volatile uint16_t *)(uintptr_t)(address))
#define RAM8(address)  (*(volatile uint8_t *)(uintptr_t)(address))

extern int32_t RuntimeEntry_Alloc(uint32_t source, uint32_t index);
extern void RuntimeEntry_Deactivate(uint32_t serial);
extern void RuntimeEntry_SetLimit(uint32_t serial, uint32_t limit);

static uint8_t Script_ReadByte(uint32_t *cursor)
{
    const uint8_t *p = (const uint8_t *)(uintptr_t)*cursor;
    uint8_t value = *p;
    *cursor += 1u;
    RAM32(0x03005E00u) = *cursor;
    return value;
}

static void Script_SkipBytes(uint32_t *cursor, uint32_t count)
{
    *cursor += count;
    RAM32(0x03005E00u) = *cursor;
}

static void Script_RemoveEntry(uint32_t record_index, uint8_t identifier)
{
    RuntimeScriptRecord *records = (RuntimeScriptRecord *)(uintptr_t)
        RAM32(0x03005E28u);
    RuntimeScriptRecord *record = &records[record_index & 0x0Fu];
    unsigned i;

    for (i = 0; i < 4; ++i) {
        RuntimeScriptSlot *slot = &record->slots[i];
        if (slot->active != 0 && slot->identifier == identifier) {
            RuntimeEntry_Deactivate(slot->entry_serial);
            slot->active = 0;
            return;
        }
    }
}

static void Script_AddEntry(uint32_t record_index, uint8_t identifier,
                            uint8_t limit)
{
    RuntimeScriptRecord *records = (RuntimeScriptRecord *)(uintptr_t)
        RAM32(0x03005E28u);
    RuntimeScriptRecord *record = &records[record_index & 0x0Fu];
    unsigned i;

    /* Existing identifier: the original interpreter refuses to duplicate it. */
    for (i = 0; i < 4; ++i) {
        RuntimeScriptSlot *slot = &record->slots[i];
        if (slot->active != 0 && slot->identifier == identifier)
            return;
    }

    for (i = 0; i < 4; ++i) {
        RuntimeScriptSlot *slot = &record->slots[i];
        int32_t serial;
        if (slot->active != 0)
            continue;
        if (record->source_record == 0)
            return;
        serial = RuntimeEntry_Alloc(record->source_record, identifier);
        /* Pool exhaustion returns -1: never publish a phantom slot. */
        if (serial < 0)
            return;
        slot->entry_serial = (uint32_t)serial;
        RuntimeEntry_SetLimit(slot->entry_serial, limit);
        slot->active = 1;
        slot->identifier = identifier;
        return;
    }
}


/* 0x08062B44 — install the script descriptor used by start/select opcodes. */
void RuntimeScript_SetDescriptor(const void *descriptor)
{
    RAM32(0x03005E14u) = (uint32_t)(uintptr_t)descriptor;
}

/* 0x08062B50 — shared implementation in runtime_pending_service.c.
 * Do not maintain a second independent copy of the ROM routine here.
 */
extern void sub_08062B50(void);
void RuntimeScript_Stop(void)
{
    sub_08062B50();
}

/* 0x08062BCC — start one descriptor entry (two 32-bit cursor values). */
void RuntimeScript_Start(uint32_t index)
{
    uint32_t descriptor = RAM32(0x03005E14u);
    uint32_t count;
    uint32_t table;
    uint32_t *entry;

    if (descriptor == 0)
        return;
    count = *(volatile uint32_t *)(uintptr_t)descriptor;
    if (index >= count)
        return;

    RuntimeScript_Stop();
    table = *(volatile uint32_t *)(uintptr_t)(descriptor + 8u);
    entry = (uint32_t *)(uintptr_t)(table + index * 8u);
    RAM32(0x03005E00u) = entry[0];
    RAM32(0x03005E20u) = entry[1];
    RAM32(0x03005E08u) = 0;
    RAM32(0x03005E10u) = 0;
    RAM32(0x03005E0Cu) = 1;
}

/* 0x08062C48 — consume script commands while the delay counter is <= 0. */
void RuntimeScript_Service(void)
{
    uint32_t state = RAM32(0x03005E0Cu);
    if (state != 1)
        return;

    RAM32(0x03005E08u) -= RAM32(0x03005E10u);
    if ((int32_t)RAM32(0x03005E08u) > 0)
        return;

    for (;;) {
        uint32_t cursor = RAM32(0x03005E00u);
        uint8_t opcode = Script_ReadByte(&cursor);
        uint8_t family;
        uint8_t operand;

        if ((opcode & 0x80u) == 0) {
            uint8_t low = Script_ReadByte(&cursor);
            uint32_t delay = ((uint32_t)opcode << 8 | low) << 16;
            RAM32(0x03005E08u) += delay;
        } else {
            family = (uint8_t)(opcode >> 4);
            operand = (uint8_t)(opcode & 0x0Fu);

            switch (family) {
            case 0x8: {
                uint8_t identifier = Script_ReadByte(&cursor);
                Script_SkipBytes(&cursor, 1);
                Script_RemoveEntry(operand, identifier);
                break;
            }
            case 0x9: {
                uint8_t identifier = Script_ReadByte(&cursor);
                uint8_t limit = Script_ReadByte(&cursor);
                Script_AddEntry(operand, identifier, limit);
                break;
            }
            case 0xA:
                /* Reserved/no-op family in the observed dispatch table. */
                break;
            case 0xB:
                switch (operand) {
                case 0:
                    RAM32(0x03005E00u) = RAM32(0x03005E20u);
                    break;
                case 1:
                    Script_SkipBytes(&cursor, 1);
                    break;
                case 2: {
                    uint32_t value = ((uint32_t)Script_ReadByte(&cursor) << 24);
                    value |= (uint32_t)Script_ReadByte(&cursor) << 16;
                    value |= (uint32_t)Script_ReadByte(&cursor) << 8;
                    value |= (uint32_t)Script_ReadByte(&cursor);
                    RAM32(0x03005E10u) = value;
                    break;
                }
                case 3:
                    sub_08057C5C((const void *)0x08755E38u, 0);
                    break;
                default:
                    break;
                }
                break;
            case 0xC: {
                uint8_t table_index = Script_ReadByte(&cursor);
                RuntimeScriptRecord *records = (RuntimeScriptRecord *)(uintptr_t)
                    RAM32(0x03005E28u);
                uint32_t descriptor = RAM32(0x03005E14u);
                uint32_t *pointer_table = (uint32_t *)(uintptr_t)
                    RAM32(descriptor + 0x0Cu);
                records[operand].source_record = pointer_table[table_index];
                break;
            }
            case 0xD:
                Script_SkipBytes(&cursor, 1);
                break;
            default:
                break;
            }
        }

        if ((int32_t)RAM32(0x03005E08u) > 0)
            return;
    }
}
