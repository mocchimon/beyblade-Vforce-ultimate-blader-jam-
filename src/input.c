#include "runtime.h"
#include <stdint.h>

/* 0x08063A74 */
void Input_ResetMappings(void)
{
    volatile uint8_t *table = (volatile uint8_t *)0x03005E80u;
    for (int i = 0x14; i >= 0; --i)
        table[i] = 0;
}

/* 0x08063A8C */
void Input_SetMapping(uint32_t index, uint32_t value)
{
    if (index <= 0x14)
        ((volatile uint8_t *)0x03005E80u)[index] = (uint8_t)value;
}

/* 0x08063AA0 */
void Input_SetState(uint32_t state)
{
    *(volatile uint32_t *)0x03005E98u = state;
}

/* 0x080517A4 */
uint32_t Input_TestMask(uint32_t mask)
{
    return *(volatile uint32_t *)0x03005E98u & mask;
}
