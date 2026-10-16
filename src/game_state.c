#include <stdint.h>
#include "gba.h"
#include "runtime_record.h"

/* Context fields live at 0x03000650; 0x03000FB0 holds a separate object base. */
#define GAME_STATE_CONTEXT ((volatile uint8_t *)0x03000650u)
#define GAME_STATE_OBJECT_ROOT \
    (*(volatile uint32_t *)(uintptr_t)0x03000FB0u)

int32_t GameState_ScaleStep(int32_t value, int32_t limit)
{
    uint32_t magnitude = (value < 0) ? (uint32_t)-value : (uint32_t)value;
    uint32_t negative = ((uint32_t)value >> 31);

    if (magnitude == 0)
        return 0;
    while (limit != 0 && magnitude > ((uint32_t)limit << 8))
        limit >>= 1;
    if (limit == 0)
        limit = 1;
    return negative ? -limit : limit;
}

void GameState_SetActiveIndex(uint32_t index)
{
    volatile uint32_t *object =
        *(volatile uint32_t **)(GAME_STATE_CONTEXT + 0xB4);
    uint32_t limit = object ? *(volatile uint32_t *)(object + 0x1C) : 0;
    if (index >= limit)
        index = limit ? limit - 1 : 0;
    GAME_STATE_CONTEXT[0x7D] = (uint8_t)(index + 1);
}

void GameState_SetContextA(void *ptr) { *(volatile uint32_t *)(GAME_STATE_CONTEXT + 0x0C) = (uint32_t)ptr; }
void *GameState_GetContextA(void) { return (void *)(uintptr_t)*(volatile uint32_t *)(GAME_STATE_CONTEXT + 0x0C); }
void GameState_SetContextB(void *ptr) { *(volatile uint32_t *)(GAME_STATE_CONTEXT + 0x10) = (uint32_t)ptr; }
void *GameState_GetContextB(void) { return (void *)(uintptr_t)*(volatile uint32_t *)(GAME_STATE_CONTEXT + 0x10); }

/* 0x08049268: prepares the context at 0x03000650 for the next frame. */
void GameState_FramePrepare(void)
{
    volatile uint8_t *s = GAME_STATE_CONTEXT;
    volatile uint8_t *object =
        (volatile uint8_t *)(uintptr_t)GAME_STATE_OBJECT_ROOT;

    *(volatile uint16_t *)(object + 0xC26) = 0xFFFF;
    *(volatile uint32_t *)(s + 0x04) = 0;
    *(volatile uint32_t *)(s + 0x0C) = 0;
    *(volatile uint32_t *)(s + 0x10) = 7;
    *(volatile uint32_t *)(s + 0x00) = 0xFFFFFFFFu;
    *(volatile uint32_t *)(s + 0x08) = 0xFFFFFFFFu;
    s[0x7C] = 0;

    RuntimeRecord_Clear((volatile RuntimeRecordManager *)(s + 0x458));

    *(volatile uint32_t *)(s + 0x424) = 0;
    *(volatile uint32_t *)(s + 0x470) = 0;
    *(volatile uint16_t *)(s + 0x474) = 0;
    s[0x481] = 0;
    *(volatile uint32_t *)(s + 0x578) = 0;
    *(volatile uint32_t *)(s + 0x57C) = 0;
    *(volatile uint32_t *)(s + 0x580) = 0;
    s[0x80] = 0;
    s[0x7F] = 0;
    s[0x584] = 0;
    s[0x585] = 0;
    s[0x586] = 0;
    *(volatile uint32_t *)(s + 0x588) = 0;
    *(volatile uint32_t *)(s + 0x58C) = 0;
    s[0x81] = 0;
    *(volatile uint32_t *)(s + 0x5A8) = 0;
}

/* Five-way indirect dispatch. The selected addresses are shared-tail continuations, not ordinary C handlers. */
void GameState_Dispatch(uint32_t mode)
{
    static const uintptr_t handlers[5] = {
        0x0804937Cu, 0x080493B0u, 0x08049390u,
        0x080493B0u, 0x0804939Eu
    };
    if (mode <= 4)
        /* Preserve the ROM dispatch table here; exact shared register ABI is documented in pass8 assembly. */
        ((void (*)(void))handlers[mode])();
}
