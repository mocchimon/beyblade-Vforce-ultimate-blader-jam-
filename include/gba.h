#ifndef GBA_H
#define GBA_H
#include <stdint.h>

#define REG_DISPCNT (*(volatile uint16_t *)0x04000000u)
#define REG_DISPSTAT (*(volatile uint16_t *)0x04000004u)
#define REG_VCOUNT (*(volatile uint16_t *)0x04000006u)
#define REG_IE (*(volatile uint16_t *)0x04000200u)
#define REG_IF (*(volatile uint16_t *)0x04000202u)
#define REG_IME (*(volatile uint16_t *)0x04000208u)
#define REG_DMA3SAD (*(volatile uint32_t *)0x040000D4u)
#define REG_DMA3DAD (*(volatile uint32_t *)0x040000D8u)
#define REG_DMA3CNT (*(volatile uint32_t *)0x040000DCu)
#define REG_KEYINPUT (*(volatile uint16_t *)0x04000130u)

#endif
