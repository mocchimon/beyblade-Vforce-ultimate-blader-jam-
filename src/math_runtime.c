#include <stdint.h>

/*
 * Unsigned remainder helper recovered at 0x0806625C.
 *
 * The ROM uses a scaled subtract/bit-mask algorithm. This C equivalent
 * deliberately avoids signed arithmetic because callers can pass pointer
 * differences as raw 32-bit values. A zero divisor follows the ROM's
 * divide-by-zero path and returns zero.
 */
uint32_t Math_ModuloUnsigned(uint32_t numerator, uint32_t denominator)
{
    uint32_t remainder = numerator;
    int shift;

    if (denominator == 0)
        return 0;

    for (shift = 31; shift >= 0; --shift) {
        uint32_t shifted;
        if (denominator > (UINT32_MAX >> shift))
            continue;
        shifted = denominator << shift;
        if (shifted <= remainder)
            remainder -= shifted;
    }

    return remainder;
}
