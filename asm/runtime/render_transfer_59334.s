.syntax unified
.thumb

/*
 * 0x08059334 — rectangular transfer preparation / clipping.
 *
 * This is intentionally kept as assembly because the final tail-dispatch
 * ABI at 0x08065C5C is register-selected rather than a normal C call.
 * The ROM bytes themselves are not embedded here.
 *
 * Recovered behavior:
 *   - source base = child + 0x70
 *   - destination base derives from child + 0x5C and VRAM 0x06000000
 *   - clips requested width/height against child dimensions
 *   - adjusts source/destination offsets for negative/overflowing edges
 *   - dispatches via 0x08065C5C
 */
