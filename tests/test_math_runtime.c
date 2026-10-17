#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint32_t Math_ModuloUnsigned(uint32_t numerator, uint32_t denominator);
uint32_t Math_DivideUnsigned(uint32_t numerator, uint32_t denominator);
int32_t Math_DivideSigned(int32_t numerator, int32_t denominator);
uint32_t __aeabi_uidiv(uint32_t numerator, uint32_t denominator);

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
            expected = b ? a / b : 0;
            actual = Math_DivideUnsigned(a, b);
            if (actual != expected) {
                fprintf(stderr, "division mismatch: %u / %u -> %u, expected %u\n",
                        a, b, actual, expected);
                return 1;
            }
            actual = __aeabi_uidiv(a, b);
            if (actual != expected) {
                fprintf(stderr, "ABI division mismatch: %u / %u -> %u, expected %u\n",
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
            expected = d ? n / d : 0;
            actual = Math_DivideUnsigned(n, d);
            if (actual != expected) {
                fprintf(stderr, "edge division mismatch at case %u\n", i);
                return 1;
            }
        }
    }

    {
        static const int32_t values[][2] = {
            { 7, 3 }, { -7, 3 }, { 7, -3 }, { -7, -3 },
            { INT32_MIN, 1 }, { INT32_MIN, -1 }, { INT32_MAX, -1 },
            { -1, INT32_MIN }, { 17, 0 }, { 0, -19 }
        };
        unsigned i;
        for (i = 0; i < sizeof(values) / sizeof(values[0]); ++i) {
            int32_t actual = Math_DivideSigned(values[i][0], values[i][1]);
            int32_t expected;
            if (values[i][1] == 0) {
                expected = 0;
            } else if (values[i][0] == INT32_MIN && values[i][1] == -1) {
                /* The recovered unsigned-magnitude path wraps to INT32_MIN. */
                expected = INT32_MIN;
            } else {
                expected = values[i][0] / values[i][1];
            }
            if (actual != expected) {
                fprintf(stderr, "signed division mismatch at case %u: %d / %d -> %d, expected %d\n",
                        i, values[i][0], values[i][1], actual, expected);
                return 1;
            }
        }
    }

    puts("recovered division and modulo helpers: exhaustive small-range and edge tests passed");
    return 0;
}
