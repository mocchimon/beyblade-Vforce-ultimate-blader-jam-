#include "gba.h"
#include <stdint.h>

/*
 * 0x0805A890 initializes the controller/control-state area.  It reads
 * KEYINPUT, stores its inverted value into the game's state globals, clears
 * several queue/counter fields, then initializes ten records at
 * 0x03005CB0 with a 0x18-byte stride.
 *
 * This is more than a simple "read keyboard" routine, so the previous
 * Input_Init name was too narrow.  The final semantic name remains
 * ControlState_Init until more callers are recovered.
 */
typedef struct ControlRecord {
    uint32_t word00;
    uint32_t word04;
    uint32_t word08;
    uint32_t value0C;
    uint32_t word10;
    uint32_t word14;
    uint16_t half16;
    uint16_t half18;
} ControlRecord;

void ControlState_Init(void)
{
    volatile uint16_t *keyInput = (volatile uint16_t *)0x04000130u;
    volatile uint16_t *state = (volatile uint16_t *)0x03005CA0u;
    volatile uint32_t *records = (volatile uint32_t *)0x03005CB0u;

    uint16_t held = (uint16_t)~(*keyInput);
    *state = held;
    *(volatile uint16_t *)0x03005DA0u = held;
    *(volatile uint16_t *)0x03005DACu = 0;
    *(volatile uint16_t *)0x03005DA4u = held;
    *(volatile uint32_t *)0x03005DBCu = 0;
    *(volatile uint32_t *)0x03005DB0u = 0;
    *(volatile uint32_t *)0x03005CA4u = 0;

    for (unsigned i = 0; i < 10; ++i) {
        uint8_t *base = (uint8_t *)records + i * 0x18;
        *(uint32_t *)(base + 0x00) = 0;
        *(uint32_t *)(base + 0x04) = 0;
        *(uint32_t *)(base + 0x14) = 0;
        *(uint32_t *)(base + 0x0C) = 100;
        *(uint32_t *)(base + 0x08) = 0;
        *(uint16_t *)(base + 0x10) = 0;
    }
}
