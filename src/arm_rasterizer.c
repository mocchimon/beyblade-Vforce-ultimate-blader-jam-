#include <stddef.h>
#include <stdint.h>

/*
 * Recovered from ARM-state routine 0x08064E54.
 *
 * r0 = number of 64-byte output chunks
 * r1 = source row stride in bytes
 * r2 = source base
 * r3 = destination base
 *
 * Each iteration gathers eight 8-byte slices from source rows separated by
 * stride, then writes those slices contiguously. After each group of eight
 * iterations, the source advances to the next group of eight rows. The exact
 * caller-level texture/layout semantics are not yet proven.
 */
void ArmRaster_CopyEightRowSlices(uint32_t chunk_count,
                                  uint32_t source_stride,
                                  const uint8_t *source,
                                  uint8_t *destination)
{
    uint32_t remaining = chunk_count;

    while (remaining != 0) {
        for (uint32_t row = 0; row < 8; ++row) {
            const uint8_t *slice = source + row * source_stride;
            for (uint32_t byte = 0; byte < 8; ++byte)
                *destination++ = slice[byte];
        }

        source += 8;
        --remaining;

        /* Mirrors the ARM routine's stride correction at each 8-chunk edge. */
        if ((remaining & 7u) == 0) {
            source += source_stride * 8u;
            source -= 64u;
        }
    }
}
