#include <stdint.h>
#include "gba.h"

/* Main recovered state/context record rooted at 0x03000FB0. */
#define GAME_STATE ((volatile uint8_t *)0x03000FB0u)

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
    volatile uint32_t *object = *(volatile uint32_t **)(GAME_STATE + 0xB4);
    uint32_t limit = object ? *(volatile uint32_t *)(object + 0x1C) : 0;
    if (index >= limit)
        index = limit ? limit - 1 : 0;
    GAME_STATE[0x7D] = (uint8_t)(index + 1);
}

void GameState_SetContextA(void *ptr) { *(volatile uint32_t *)(GAME_STATE + 0x0C) = (uint32_t)ptr; }
void *GameState_GetContextA(void) { return *(volatile void **)(GAME_STATE + 0x0C); }
void GameState_SetContextB(void *ptr) { *(volatile uint32_t *)(GAME_STATE + 0x10) = (uint32_t)ptr; }
void *GameState_GetContextB(void) { return *(volatile void **)(GAME_STATE + 0x10); }

/* Exact field-level reconstruction where the current disassembly is unambiguous. */
void GameState_Init(void)
{
    volatile uint8_t *s = GAME_STATE;
    volatile uint32_t *sentinel = *(volatile uint32_t **)s;

    *(volatile uint16_t *)sentinel = 0xFFFF;
    *(volatile uint32_t *)(s + 0x04) = 0;
    *(volatile uint32_t *)(s + 0x0C) = 0;
    *(volatile uint32_t *)(s + 0x08) = 0xFFFFFFFFu;
    *(volatile uint32_t *)(s + 0x7C) = 0;
    s[0x7C] = 0;

    extern void sub_08050388(void *ctx);
    sub_08050388((void *)(s + 0x458));

    *(volatile uint32_t *)(s + 0x424) = 0;
    *(volatile uint32_t *)(s + 0x470) = 0;
    *(volatile uint16_t *)(s + 0x474) = 0;
    s[0x4D1] = 0;
    *(volatile uint32_t *)(s + 0x5E4) = 0;
    *(volatile uint32_t *)(s + 0x5E8) = 0;
    *(volatile uint32_t *)(s + 0x5EC) = 0;
    s[0x480] = 0;
    s[0x47F] = 0;
    s[0x489] = 0;
    s[0x48E] = 0;
    s[0x490] = 0;
    s[0x491] = 0;
    *(volatile uint32_t *)(s + 0x494) = 0;
    *(volatile uint32_t *)(s + 0x49A) = 0;
    s[0x501] = 0;
    *(volatile uint32_t *)(s + 0x4FC) = 0;
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
