#include <stdint.h>
#include "gba.h"

/*
 * 0x08065C5C is a tiny register-selected tail-dispatch table.  The entries
 * are reached after the caller has loaded one of r9-r12 (or the stack/lr).
 * It is not itself a render routine.
 */
static void Render_TailDispatch(void);

/*
 * 0x08059334
 *
 * Prepares a rectangular transfer from the child source surface.  The ROM
 * clips the requested rectangle against the child dimensions, adjusts the
 * source/destination coordinates, and then enters the selected transfer
 * backend through 0x08065C5C.
 *
 * The original routine has a wider mixed register/stack ABI than this
 * reconstruction exposes; the exact ABI is preserved in the companion ASM.
 */
void Render_PrepareTransfer(void *child, int32_t x, int32_t y,
                            uint32_t width, uint32_t height,
                            uint32_t source_stride,
                            uint32_t source_offset)
{
    (void)child;
    (void)x;
    (void)y;
    (void)width;
    (void)height;
    (void)source_stride;
    (void)source_offset;
    Render_TailDispatch();
}

/*
 * 0x08059520 — DMA3-backed 16-bit rectangular copy.
 *
 * The original writes DMA3SAD/DMA3DAD/DMA3CNT for each row.  DMA count is in
 * 16-bit units and bit 31 is set to enable the transfer.  The exact clipped
 * argument ABI remains represented by the original assembly companion.
 */
void Render_CopyRect16_DMA3(uint32_t source, uint32_t destination,
                            uint16_t halfwords)
{
    REG_DMA3SAD = source;
    REG_DMA3DAD = destination;
    REG_DMA3CNT = 0x80000000u | halfwords;
}

static void Render_TailDispatch(void)
{
    /* The ROM reaches the selected backend through bx r9/r10/r11/r12. */
}

/* 0x08059428 — row-oriented DMA3 transfer routine. Its relationship to the
 * indirect IWRAM targets 0x0300646C and 0x0300682C is not proven yet. */
void sub_08059428(void *child,
                                int32_t x, int32_t y,
                                uint32_t width, uint32_t height,
                                uint32_t source_offset,
                                uint32_t row_count)
{
    (void)child;
    (void)x;
    (void)y;
    (void)width;
    (void)height;
    (void)source_offset;
    (void)row_count;
    /* Exact mixed register/stack ABI remains in ROM assembly. */
}
