#include "gba.h"
#include <stdint.h>

/*
 * These are semantic reconstructions of small system routines.  Addresses
 * are retained in comments so the source can be matched back to the ROM.
 */

/* 0x08057940: initializes the game's DMA3 bookkeeping structure. */
void System_Dma3StateInit(void)
{
    volatile uint32_t *state = (volatile uint32_t *)0x03000E30u;
    state[0] = 0;
    state[1] = 0;
    state[2] = 0x10;
}

/* 0x08057968: installs a 0x104-byte IWRAM block through immediate DMA3. */
void System_InstallIwramBlock(void)
{
    const uint32_t *src = (const uint32_t *)0x08000168u;
    uint32_t *dst = (uint32_t *)0x03000FE0u;
    uint32_t words = (0x0800026Cu - 0x08000168u) >> 2; /* 0x41 words */

    REG_DMA3SAD = (uint32_t)src;
    REG_DMA3DAD = (uint32_t)dst;
    REG_DMA3CNT = 0x84000000u | words; /* enable + 32-bit + immediate */

    /* Runtime-visible pointer associated with the installed IWRAM block. */
    *(volatile uint32_t *)0x03007FFCu = (uint32_t)dst;
}

/* 0x080579CC: interrupt/display/DMA setup. */
void System_DisplayInit(uint16_t displayControl)
{
    REG_IME = 1;
    REG_IE = 0;
    REG_IF = 0;
    REG_DISPSTAT = displayControl;

    REG_DMA3SAD = 0x0872CB18u;
    REG_DMA3DAD = 0x03000DF0u;
    REG_DMA3CNT = 0x8400000Eu;
}

/* 0x08057A18: ORs display-control flags into DISPCNT. */
void System_SetDisplayFlags(uint16_t flags)
{
    REG_DISPCNT |= flags;
}

/* 0x080578E4: BIOS CpuSet wrapper. */
void System_CpuSet(const void *src, void *dst, uint32_t control);

/* 0x080578E8 / 0x080578EC: BIOS division and remainder wrappers. */
int32_t System_Div(int32_t a, int32_t b);
int32_t System_Mod(int32_t a, int32_t b);

/* 0x080578F4: BIOS LZ77 WRAM decompression wrapper. */
void *System_LZ77UnCompWram(const void *src, void *dst);

/* 0x080578F8: BIOS sqrt wrapper. */
uint32_t System_Sqrt(uint32_t value);

/* 0x080578FC: BIOS VBlank wait wrapper. */
void System_VBlankWait(void);
