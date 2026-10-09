.syntax unified
.thumb

/*
 * 0x08059520 — recovered DMA3 transfer backend.
 *
 * This routine is called by the resource/render preparation path with a
 * child pointer and clipped transfer parameters.  It derives a 16-bit source
 * address from child + 0x70, uses child word +0x00 as the source row stride,
 * derives the VRAM destination from child +0x5C and the supplied X offset,
 * and programs DMA3 once per output row.
 *
 * The destination register block is 0x040000D4:
 *   +0x00 DMA3SAD
 *   +0x04 DMA3DAD
 *   +0x08 DMA3CNT
 *
 * DMA3CNT is written with bit 31 set; the low 16 bits are the halfword count.
 */
