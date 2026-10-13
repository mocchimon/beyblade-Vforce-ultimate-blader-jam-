#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint32_t Math_ModuloUnsigned(uint32_t numerator, uint32_t denominator);

int main(void)
{
    uint32_t a, b;
    for (a = 0; a < 2048; ++a) {
        for (b = 0; b < 257; ++b) {
            uint32_t expected = b ? a % b : 0;
            uint32_t actual = Math_ModuloUnsigned(a, b);
            if (actual != expected) {
                fprintf(stderr, "modulo mismatch: %u %% %u -> %u, expected %u\n",
                        a, b, actual, expected);
                return 1;
            }
        }
    }

    {
        static const uint32_t values[][2] = {
            { UINT32_MAX, 1u },
            { UINT32_MAX, 3u },
            { UINT32_MAX, 0x80000000u },
            { 0x80000000u, 0x7fffffffu },
            { 0xdeadbeefu, 0x10001u },
            { 123u, 0u }
        };
        unsigned i;
        for (i = 0; i < sizeof(values) / sizeof(values[0]); ++i) {
            uint32_t n = values[i][0], d = values[i][1];
            uint32_t expected = d ? n % d : 0;
            uint32_t actual = Math_ModuloUnsigned(n, d);
            if (actual != expected) {
                fprintf(stderr, "edge modulo mismatch at case %u\n", i);
                return 1;
            }
        }
    }

    puts("Math_ModuloUnsigned: exhaustive small-range and edge tests passed");
    return 0;
}
