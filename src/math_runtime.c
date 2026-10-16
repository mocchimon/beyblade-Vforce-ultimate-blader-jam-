#include <stdint.h>

/*
 * Unsigned quotient helper reconstructed from ROM 0x080661E4.
 * The routine uses a scaled subtract/shift sequence and returns zero for a
 * zero divisor through its shared divide-by-zero path at 0x0806613C.
 */
uint32_t Math_DivideUnsigned(uint32_t numerator, uint32_t denominator)
{
    uint32_t quotient = 0;
    int shift;

    if (denominator == 0)
        return 0;

    for (shift = 31; shift >= 0; --shift) {
        if (denominator <= (UINT32_MAX >> shift)) {
            uint32_t scaled = denominator << shift;
            if (scaled <= numerator) {
                numerator -= scaled;
                quotient |= (uint32_t)1u << shift;
            }
        }
    }

    return quotient;
}

/*
 * Signed quotient helper reconstructed from ROM 0x080660A8.  The original
 * routine divides unsigned magnitudes, then applies the sign of a^b.  Doing
 * the magnitude work in unsigned arithmetic also preserves INT32_MIN safely.
 */
int32_t Math_DivideSigned(int32_t numerator, int32_t denominator)
{
    uint32_t n = (uint32_t)numerator;
    uint32_t d = (uint32_t)denominator;
    uint32_t negative = (n ^ d) >> 31;
    uint32_t quotient;

    if ((n >> 31) != 0)
        n = 0u - n;
    if ((d >> 31) != 0)
        d = 0u - d;

    quotient = Math_DivideUnsigned(n, d);
    if (negative != 0)
        quotient = 0u - quotient;
    return (int32_t)quotient;
}

/* Compiler ABI support only; this name is not claimed as a game symbol. */
uint32_t __aeabi_uidiv(uint32_t numerator, uint32_t denominator)
{
    return Math_DivideUnsigned(numerator, denominator);
}

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
