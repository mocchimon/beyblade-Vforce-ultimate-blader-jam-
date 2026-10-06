#ifndef UBJ_GBA_H
#define UBJ_GBA_H
#include <stdint.h>
#define ROM_BASE   0x08000000u
#define EWRAM_BASE 0x02000000u
#define IWRAM_BASE 0x03000000u
#define IO_BASE    0x04000000u
#define REG_DISPCNT (*(volatile uint16_t *)0x04000000u)
#define REG_VCOUNT  (*(volatile uint16_t *)0x04000006u)
#endif
