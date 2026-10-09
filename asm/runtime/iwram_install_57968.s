/* 0x08057968, Thumb. Recovered from the ROM. */
/*
 * r2 = 0x040000D4 (DMA3 source register block)
 * [r2+0] = 0x08000168
 * [r2+4] = 0x03000FE0
 * [r2+8] = 0x84000041
 * [0x03007FFC] = 0x03000FE0
 *
 * This is an immediate 32-bit DMA3 install of [0x08000168,0x0800026C)
 * into IWRAM [0x03000FE0,0x030010E4). It does not install the renderer
 * targets at 0x0300646C/0x0300682C.
 */
