/* Evidence notes for the ARM-state runtime image in the original ROM.
 * The original ROM bytes are intentionally not embedded in this project.
 *
 * Image source:       0x080641B8
 * Image end/table:    0x08064EDC
 * Image byte length:  0xD24
 * Relocation table:   0x08064EDC onward
 *
 * The first ARM words at 0x080641B8 are:
 *   E2014CFF  AND r4, r1, #0xFF00
 *   E0433002  SUB r3, r3, r2
 *   E1A03403  LSL r3, r3, #8
 *   E1A02402  LSL r2, r2, #8
 *   E0822204  ADD r2, r2, r4, LSL #4
 *
 * Loader at 0x0805EFC0 uses the allocated block descriptor:
 *   DMA3 source      <- 0x080641B8
 *   DMA3 destination <- descriptor[0] (address)
 *   DMA3 length      <- descriptor[1] (size), converted to words
 *   DMA3 control     <- 0x84000000 | (size >> 2)
 *
 * Potential address correspondence if (and only if) runtime image base is
 * 0x030061B8:
 *   0x0300646C - base = 0x2B4 -> ROM offset 0x0806446C
 *   0x0300682C - base = 0x674 -> ROM offset 0x0806482C
 * This offset match is a hypothesis, not yet a proven installation path.
 */
