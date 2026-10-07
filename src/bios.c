#include <stdint.h>

/* BIOS service wrappers recovered from the game's Thumb code. */

void Bios_CpuSet(const void *src, void *dst, uint32_t control)
{
    register const void *r0 __asm__("r0") = src;
    register void *r1 __asm__("r1") = dst;
    register uint32_t r2 __asm__("r2") = control;
    (void)r0; (void)r1; (void)r2;
    __asm__ volatile("swi 0x0B" : "+r"(r0), "+r"(r1) : "r"(r2) : "memory");
}

int32_t Bios_Div(int32_t numerator, int32_t denominator)
{
    register int32_t r0 __asm__("r0") = numerator;
    register int32_t r1 __asm__("r1") = denominator;
    __asm__ volatile("swi 0x06" : "+r"(r0), "+r"(r1) : : "memory");
    return r0;
}

int32_t Bios_Mod(int32_t numerator, int32_t denominator)
{
    register int32_t r0 __asm__("r0") = numerator;
    register int32_t r1 __asm__("r1") = denominator;
    __asm__ volatile("swi 0x06" : "+r"(r0), "+r"(r1) : : "memory");
    return r1;
}

void *Bios_LZ77UnCompWram(const void *src, void *dst)
{
    register const void *r0 __asm__("r0") = src;
    register void *r1 __asm__("r1") = dst;
    __asm__ volatile("swi 0x11" : "+r"(r0), "+r"(r1) : : "memory");
    return r1;
}

uint32_t Bios_Sqrt(uint32_t value)
{
    register uint32_t r0 __asm__("r0") = value;
    __asm__ volatile("swi 0x08" : "+r"(r0) : : "memory");
    return r0;
}

void Bios_VBlankIntrWait(void)
{
    __asm__ volatile("swi 0x05" ::: "memory");
}
